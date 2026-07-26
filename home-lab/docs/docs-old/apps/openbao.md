# OpenBao

OpenBao is a platform for managing secrets and sensitive data, similar to HashiCorp Vault. It provides a secure way to store and access secrets, such as API keys, passwords, and certificates. OpenBao can be deployed using Docker, making it easy to set up and manage in various environments.

## Infrastructure
In this homelab, OpenBao is deployed on a LXC Container running Debian 12.

## Operating OpenBao (Initial Setup)
There are 5 keys. Only 3 are required to unseal it.

1. Create admin user
- Define `admin` policy that allows `create`, `read`, `update`, and `delete` permissions on all secrets in the `*` path.
- Enable `userpass` authentication method.
- Create identity `admin`
- Bind `admin` identity to `admin` policy

2. Create `ansible` identity
- Use an `AppRole`
- Policy that allows `read` permissions on secrets in the `secret/data/ansible/*` path
- Create ansible role `ansible-deployer` and attach the readonly policy to it
- Retrieve credentials:
    - Role ID
    - Secret ID

```hcl
# Permite leer los secretos almacenados
path "ansible/data/*" {
  capabilities = ["read", "list"]
}

# Permite listar las carpetas para poder iterar en Ansible
path "ansible/metadata/*" {
  capabilities = ["read", "list"]
}
```

```bash
openbao bao write auth/approle/role/ansible-deployer \
    token_policies="ansible-readonly" \
    token_ttl=1h \
    token_max_ttl=4h
```

3. Revoke root token
- Init session with root token
- Auto-revoke token `bao token revoke -self`


## OpenBao Operations

Administration:
- `bao list auth/token/accessors`
- `bao token lookup -accessor "<ACCESSOR_ID>"`
Retrieve secrets:
- `bao kv get ansible/proxmox/srv-prod-01/secrets`

TODO:
- Enable audit logs `/bao/logs/audit.log`

## Ansible: Retrieve data

To retrieve data from OpenBao using Ansible, you can use the `hashivault` lookup plugin.  

```bash
# Retrieve hashivault collection
ansible-galaxy collection install community.hashi_vault
```

_`hashivault` collection requires `hvac` Python library_


Ensure you have the necessary environment variables set to authenticate with OpenBao:
```bash
# export global environment variables for OpenBao
export VAULT_ADDR="https://vault.internal"
export VAULT_SKIP_VERIFY=true

# export AppRole credentials for ansible
export VAULT_ROLE_ID="<APP_ROLE_ID>"
export VAULT_SECRET_ID="<APP_SECRET_ID>"

export VAULT_TOKEN=$(bao write -field=token auth/approle/login role_id="${VAULT_ROLE_ID}" secret_id="${VAULT_SECRET_ID}")
```

> Very common for a CI/CD pipeline to log in only once using its AppRole (obtaining its parent session token) and then, within that same process, generate 5 different child tokens with a lifespan of 5 minutes (one for each server or container it will configure), thus ensuring the minimum privilege for each task.

Here's an example of how to use `hashivault` in a playbook:

```bash
ansible-playbook playbook.yml
```

```bash
# playbook.yml
---
- name: Prueba de conexión a OpenBao
  hosts: localhost
  gather_facts: false
  
  tasks:
    - name: Get a specific secret from KV2
      set_fact:
        my_secret: "{{ lookup('community.hashi_vault.vault_kv2_get', 
                        'proxmox/srv-prod-01/secrets', 
                        engine_mount_point='ansible',
                        validate_certs=false) }}"

    - name: Show the secret content
      debug:
        msg: "The retrieved value is: {{ my_secret.data.data }}"
```

## Utilities

**Set up ansible using pipx (instead of brew, since ansible is a python package)**

```bash
brew install pipx
pipx install --include-deps ansible
pipx inject ansible hvac

# Upgrade ansible
pipx upgrade ansible
# Upgrade ansible and hvac
pipx upgrade ansible --include-injected
# Upgrade all pipx packages
pipx upgrade-all

# list packages and apps installed with pipx
pipx list
```

**`ansible.cfg` configuration to setup collections in a local directory**
```ini
[defaults]
collections_path = ./collections
```

## Resources
- [OpenBao Environment Variables](https://openbao.org/docs/commands/#environment-variables)