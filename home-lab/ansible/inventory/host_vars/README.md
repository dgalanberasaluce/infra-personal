# Host-Specific Ansible Variables

This directory contains the ansible variable values for each server mapping to its correspondent Ansible playbook. Create a folder per server, this ensures that every host has an isolated and dedicated configuration.

## Directory Structure

The directory is organized so that every server has its own folder. Inside each folder, YAML files define the variables specific to that server. For example

```text
host_vars/
├── srv_prod_01/      # Folder for srv_prod_01
│   ├── main.yml      # Variables
│   └── secrets.yml   # Encrypted secrets (Ansible-vault)
├── srv_prod_02/      # Folder for srv_prod_02
│   └── main.yml
├── forgejo_runner/      
│   └── vault.yml
└── README.md
```

## Managing Secrets
Do not commit cleartext passwords. If a server requires sensitive data (API keuys, database passwords), use Ansible Vault

```bash
# Encrypt a file
ansible-vault encrypt host_vars/server_prod_01/secrets.yml

# Edit an encrypted file
ansible-vault edit host_vars/server_prod_01/secrets.yml

# Retrieve secrets from encrypted file
ansible-vault view host_vars/server_prod_01/secrets.yml

# Run playbook
ansible-playbook -i <inventory> --ask-vault-pass ./playbooks/<playbook>
ansible-playbook -i <inventory> --vault-password-file ./playbooks/.<host_name> ./playbooks/<host_name>
```
