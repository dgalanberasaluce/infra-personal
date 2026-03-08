#!/usr/bin/env bash

set -e

# Defaults
VAULT_PASS_FILE="./ansible/inventory/group_vars/all/.vault_pass"
PREFIX=""
ALL=false
SKIP_VERIFY=false
DELETE=false
PURGE=false
SEARCH_DIR="./ansible/inventory" # Default search directory for --all

usage() {
    echo "Usage: $0 --prefix <PREFIX> [--all] [--delete] [--purge] [--skip-verify] [--vault-pass-file <FILE>] [--search-dir <DIR>]"
    echo "Example: $0 --prefix ansible --all --purge"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --prefix) PREFIX="$2"; shift ;;
        --all) ALL=true ;;
        --delete) DELETE=true ;;
        --purge) PURGE=true ;;
        --skip-verify) SKIP_VERIFY=true ;;
        --vault-pass-file) VAULT_PASS_FILE="$2"; shift ;;
        --search-dir) SEARCH_DIR="$2"; shift ;;
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

if [[ "$DELETE" == false && "$PURGE" == false && ! -f "$VAULT_PASS_FILE" ]]; then
    echo "Error: Vault password file not found at $VAULT_PASS_FILE"
    exit 1
fi

echo "Searching for vault.yml files..."

# Ensure we process either matching files or give an error if --all is not set
if [[ "$ALL" != true ]]; then
    echo "Error: Please specify --all to process all vault.yml files."
    exit 1
fi

find "$SEARCH_DIR" -type f -name "vault.yml" | while read -r vault_file; do
    echo "Processing $vault_file..."
    
    # Extract directory name (e.g. server01 or all)
    dir_name=$(basename $(dirname "$vault_file"))
    
    # Path sanitization: change underscore to dash as requested
    sanitized_dir=$(echo "$dir_name" | tr '_' '-')
    target_path="$PREFIX/$sanitized_dir/secrets"

    if [[ "$PURGE" == true ]]; then
        echo "  Purging secrets (metadata and all versions) at: $target_path"
        if bao kv metadata delete "$target_path" >/dev/null 2>&1; then
            echo "  Successfully purged $target_path"
        else
            echo "  Failed to purge $target_path (it may not exist)"
        fi
        continue
    fi

    if [[ "$DELETE" == true ]]; then
        echo "  Deleting secrets at: $target_path"
        if bao kv delete "$target_path" >/dev/null 2>&1; then
            echo "  Successfully deleted $target_path"
        else
            echo "  Failed to delete $target_path (it may not exist)"
        fi
        continue
    fi
    
    # Check if the vault file is actually encrypted or empty
    if ! grep -q "\$ANSIBLE_VAULT" "$vault_file"; then
        echo "  Skipping: not an encrypted ansible-vault file."
        continue
    fi
    
    # Determine vault password file
    CURRENT_PASS_FILE="$VAULT_PASS_FILE"
    SPECIFIC_PASS_FILE="./ansible/playbooks/vault_pass/.$dir_name.vault_pass"
    
    if [[ -f "$SPECIFIC_PASS_FILE" ]]; then
        CURRENT_PASS_FILE="$SPECIFIC_PASS_FILE"
    fi

    echo "  Using vault password file: $CURRENT_PASS_FILE"
    
    # Decrypt and format as JSON
    json_payload=$(mktemp)
    
    # ansible-vault view outputs YAML
    # yq converts it to JSON format, stripping 'vault_' prefix from keys
    if ! ansible-vault view --vault-password-file="$CURRENT_PASS_FILE" "$vault_file" | \
         yq -o=json 'with_entries(.key |= sub("^vault_", ""))' > "$json_payload" 2>/dev/null; then
        echo "  Error: Decryption failed for $vault_file using $CURRENT_PASS_FILE"
        rm -f "$json_payload"
        continue
    fi
    
    echo "  Migrating entire file to: $target_path (stripped 'vault_' prefixes)"
    
    # Put the JSON object into OpenBao
    if bao kv put "$target_path" "@$json_payload" >/dev/null; then
        echo "  Successfully migrated secrets to $target_path"
    else
        echo "  Failed to migrate secrets to $target_path"
    fi
    
    rm -f "$json_payload"
done

if [[ "$DELETE" == true || "$PURGE" == true ]]; then
    echo "Cleanup complete."
else
    echo "Migration complete."
fi
