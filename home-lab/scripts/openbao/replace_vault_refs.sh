#!/usr/bin/env bash

set -e

BAO_KV_PATH=""
MOUNT_POINT=""
SEARCH_DIR="."

usage() {
    echo "Usage: $0 --path <BAO_KV_BASE_PATH> --mount <MOUNT_POINT> [--search-dir <DIR>]"
    echo "Example: $0 --path ansible/proxmox --mount secret"
    echo "This replaces {{ vault_VAR }} with {{ lookup('community.hashi_vault.vault_kv2_get', '<BAO_KV_BASE_PATH>/<HOST_OR_GROUP>/secrets', engine_mount_point='<MOUNT_POINT>').data.data.VAR }}"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --path) BAO_KV_PATH="$2"; shift ;;
        --mount) MOUNT_POINT="$2"; shift ;;
        --search-dir) SEARCH_DIR="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [[ -z "$BAO_KV_PATH" ]] || [[ -z "$MOUNT_POINT" ]]; then
    echo "Error: --path and --mount are required"
    usage
fi

export BAO_KV_PATH
export MOUNT_POINT

echo "Replacing vault variables in YAML files in $SEARCH_DIR..."

# Find all yaml/yml files except the vault.yml files themselves and .vault_pass
find "$SEARCH_DIR" -type f \( -name "*.yml" -o -name "*.yaml" \) ! -name "vault.yml" | while read -r file; do
    # Check if file contains {{ vault_
    if grep -q "{{ vault_" "$file"; then
        echo "Updating $file..."
        
        # Extract the directory name that would be the "host" or "group" name
        # We assume the file is inside host_vars/NAME/ or group_vars/NAME/
        # or similar structure used in the migration.
        dir_name=$(basename $(dirname "$file"))
        sanitized_dir=$(echo "$dir_name" | tr '_' '-')
        
        # We need to replace {{ vault_VAR }} with the lookup.
        # The key name should have vault_ removed.
        # Example: {{ vault_ssh_key }} -> {{ lookup('...', '<PATH>/<SAN_DIR>/secrets', ...).data.data.ssh_key }}
        
        # We can use perl with a variable for the path
        export CURRENT_TARGET_PATH="$BAO_KV_PATH/$sanitized_dir/secrets"
        
        perl -pi -e 's/\{\{\s*vault_([a-zA-Z0-9_]+)\s*\}\}/{{ lookup('\''community.hashi_vault.vault_kv2_get'\'', '\''$ENV{CURRENT_TARGET_PATH}'\'', engine_mount_point='\''$ENV{MOUNT_POINT}'\'').data.data.$1 }}/g' "$file"
    fi
done

echo "Replacement complete."
