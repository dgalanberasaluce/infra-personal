#!/usr/bin/env bash

set -e

# Defaults
PREFIX=""
SKIP_VERIFY=false
SEARCH_DIR="./ansible/inventory"
VAULT_PASS_DIR="./ansible/playbooks/vault_pass"

usage() {
    echo "Usage: $0 --prefix <PREFIX> [--skip-verify] [--search-dir <DIR>] [--vault-pass-dir <DIR>]"
    echo "Example: $0 --prefix ansible/proxmox --skip-verify"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --prefix) PREFIX="$2"; shift ;;
        --skip-verify) SKIP_VERIFY=true ;;
        --search-dir) SEARCH_DIR="$2"; shift ;;
        --vault-pass-dir) VAULT_PASS_DIR="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z "$PREFIX" ]]; then
    echo "Error: --prefix is required"
    usage
fi

if [[ "$SKIP_VERIFY" == true ]]; then
    export BAO_SKIP_VERIFY=true
fi

if [[ -z "$BAO_ADDR" ]] || [[ -z "$BAO_TOKEN" ]]; then
    echo "Error: BAO_ADDR and BAO_TOKEN environment variables must be set."
    exit 1
fi

mkdir -p "$VAULT_PASS_DIR"

echo "Listing entities in OpenBao under $PREFIX..."

# List subdirectories (hosts/groups) under the prefix
entities=$(bao kv list -format=json "$PREFIX" | yq -o=json '.[]' -)

if [[ -z "$entities" || "$entities" == "null" ]]; then
    echo "No entities found under $PREFIX"
    exit 0
fi

for entity in $entities; do
    # Remove trailing slash if present in entity name from list
    entity=$(echo "$entity" | sed 's/\/$//')
    
    echo "Processing entity: $entity..."
    
    # Try to find the corresponding directory in inventory
    # We check for host_vars or group_vars, allowing for both underscore and dash versions
    # But usually, the inventory used the underscore version.
    
    # Check underscore version
    u_entity=$(echo "$entity" | tr '-' '_')
    
    target_dir=""
    if [[ -d "$SEARCH_DIR/host_vars/$u_entity" ]]; then
        target_dir="$SEARCH_DIR/host_vars/$u_entity"
    elif [[ -d "$SEARCH_DIR/group_vars/$u_entity" ]]; then
        target_dir="$SEARCH_DIR/group_vars/$u_entity"
    elif [[ -d "$SEARCH_DIR/host_vars/$entity" ]]; then
        target_dir="$SEARCH_DIR/host_vars/$entity"
    elif [[ -d "$SEARCH_DIR/group_vars/$entity" ]]; then
        target_dir="$SEARCH_DIR/group_vars/$entity"
    fi
    
    if [[ -z "$target_dir" ]]; then
        echo "  Warning: Could not find inventory directory for entity $entity (tried $u_entity and $entity in host_vars/group_vars). Skipping."
        continue
    fi
    
    echo "  Target directory: $target_dir"
    
    # Fetch secrets from OpenBao
    # Secrets are at <PREFIX>/<ENTITY>/secrets
    secrets_json=$(mktemp)
    if ! bao kv get -format=json "$PREFIX/$entity/secrets" | yq '.data.data' -o=json > "$secrets_json" 2>/dev/null; then
        echo "  Error: Failed to fetch secrets for $entity at $PREFIX/$entity/secrets"
        rm -f "$secrets_json"
        continue
    fi
    
    # Re-build YAML with vault_ prefix
    vault_yaml="$target_dir/vault.yml"
    yq -P 'with_entries(.key |= "vault_" + .)' "$secrets_json" > "$vault_yaml"
    
    # Determine/Generate vault pass file
    # Format: .<u_entity>.vault_pass
    pass_file="$VAULT_PASS_DIR/.$u_entity.vault_pass"
    if [[ ! -f "$pass_file" ]]; then
        echo "  Vault pass file missing. Generating: $pass_file"
        openssl rand -base64 16 > "$pass_file"
        chmod 600 "$pass_file"
    fi
    
    # Encrypt the vault.yml
    if ansible-vault encrypt --vault-password-file="$pass_file" "$vault_yaml" >/dev/null 2>&1; then
        echo "  Successfully restored and encrypted $vault_yaml"
    else
        echo "  Error: Failed to encrypt $vault_yaml"
    fi
    
    rm -f "$secrets_json"
done

echo "Restoration complete."
