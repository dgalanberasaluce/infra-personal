# Ansible Vault to OpenBao Migration

This set of scripts facilitates the migration of secrets from Ansible Vault (`vault.yml`) to OpenBao, and the subsequent update of Ansible variable references.

## Prerequisites

1.  **OpenBao**: Access to an OpenBao server with a KV2 engine enabled.
2.  **CLI Tools**: `bao`, `yq`, `ansible-vault`.
3.  **Authentication**:
    ```bash
    export VAULT_ADDR="https://vault.internal"
    export VAULT_TOKEN="your-token"
    # If using self-signed certs:
    export VAULT_SKIP_VERIFY=true
    ```

---

## Script 1: Migration (`migrate_vault_to_bao.sh`)

Migrates all `vault.yml` files found in the inventory (`group_vars` and `host_vars`) to OpenBao.

### Key Features:
- All variables from a `vault.yml` are stored in a single (OpenBao) secret named `secrets` within the `<MOUNT>` kv secret engine
- Removes the `vault_` prefix from variable names (e.g., `vault_pass` -> `pass`)
- Replaces underscores in directory names with dashes (e.g., `sec_prod_01` -> `sec-prod-01`)
- Lookups for `.vault_pass` files in `./ansible/playbooks/vault_pass/`

### Usage:
```bash
./scripts/migrate_vault_to_bao.sh --prefix <PREFIX> --all [--delete] [--purge] [--skip-verify]
```
- `--prefix`: Base path in OpenBao (e.g., `ansible/proxmox`)
- `--all`: Process all `vault.yml` files found
- `--purge`: Permanently deletes metadata and all versions of the secrets
- `--delete`: (Optional) Soft-deletes the secrets at the calculated paths in OpenBao (can be undeleted)
- `--purge`: (Optional) Permanently deletes the secrets, including all versions and metadata
- `--skip-verify`: (Optional) Skips TLS certificate verification (useful for self-signed certificates)
- `--vault-pass-file <FILE>`: (Optional) Default local password file. The script will first try to find specific files in `./ansible/playbooks/vault_pass/.<DIR_NAME>.vault_pass`
- `--search-dir <DIR>`: (Optional) The folder to search for `vault.yml`. Defaults to `./ansible/inventory`

---

## Script 2: Replacement (`replace_vault_refs.sh`)

Updates the Ansible files (within `host_vars`, `group_vars`, etc.) to use OpenBao lookups (`{{ lookup('community.hashi_vault.vault_kv2_get', ...) }}`) instead of Ansible Vault variables (`{{ vault_VAR }}`).

The script transforms this:
```yaml
db_pass: "{{ vault_db_pass }}"
```
into this (assuming host `srv_prod_01` and prefix `ansible/proxmox`):
```yaml
db_pass: "{{ lookup('community.hashi_vault.vault_kv2_get', 
                'ansible/proxmox/srv-prod-01/secrets',          
                 engine_mount_point='secret'
                ).data.data }}"
```

### Usage:
```bash
./scripts/replace_vault_refs.sh --path <PATH_WITHOUT_MOUNT> --mount <KV_MOUNT> [--search-dir <DIR>]
```
Example:
```bash
./scripts/replace_vault_refs.sh --path ansible/proxmox --mount secret --search-dir ./ansible/inventory/host_vars/
```


## Script 3: Restoration (`restore_bao_to_vault.sh`)

Recreates local `vault.yml` files from OpenBao data.

### Features:
- Re-adds `vault_` prefix
- Re-encrypts files
- Generates missing `.vault_pass` files

### Usage:
```bash
./scripts/restore_bao_to_vault.sh --prefix <MOUNT/PATH> [--skip-verify]
```

**Options:**
- `--prefix <PREFIX>`: **(Required)** The OpenBao base path where your secrets are stored
- `--skip-verify`: (Optional) Skips TLS certificate verification
- `--vault-pass-dir <DIR>`: (Optional) Where to find/store the `.vault_pass` files. Defaults to `./ansible/playbooks/vault_pass`
- `--search-dir <DIR>`: (Optional) The folder to search for host/group directories. Defaults to `./ansible/inventory`

