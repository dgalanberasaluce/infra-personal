# Ansible

## Folder Hierarchy
```text
/ansible
  ├── inventory/
  |   ├── group_vars/
  |   │   │   ├── all/ 
  |   |   │   ├── vars.yml
  |   |   │   ├── vault.yml  
  |   │   ├── all.yml               # Variables that apply to all hosts in the inventory
  |   │   ├── <group_name_01>.yml   # Variables specific to a group of hosts (e.g., webservers, databases)
  │   ├── host_vars/
  │   │   ├── <server_name_01>/
  │   │   │   ├── main.yml
  │   │   │   └── vault.yml
  │   └── hosts.proxmox.yml
  ├── playbooks/
  │   ├── generated/
  │   │   ├── caddy/
  │   │   │   └── <caddy_server_01>/
  │   │   │       └── example.internal.caddy
  │   │   └── <server_name_01>/ 
  │   │       └── docker-compose-<application>.yml
  │   ├── samples/  
  │   ├── site.yml                   # Main centralized playbook
  │   └── system-maintenance.yml     # Playbook for general system maintenance tasks
  ├── roles/
  │   └── <role_01>/
  │       ├── defaults/         # Default variables for the role, which can be overridden by the user
  │       │   └── main.yml
  │       ├── handlers/         # Handlers, which are tasks that are triggered by other tasks when certain conditions are met (e.g., restarting a service after a configuration change)
  │       │   └── main.yml
  │       ├── meta/             # Metadata about the role, such as dependencies on other roles
  │       │   └── main.yml
  │       ├── tasks/            # The main list of tasks to be executed by the role
  │       │   └── main.yml
  │       ├── templates/        # Jinja2 templates for configuration files or scripts that will be deployed to the target hosts
  │       │   ├── docker-compose.yml.j2
  │       │   └── env.j2 
  │       └── vars/             # Variables that are specific to this role and should not be overridden by the user
  │           └── main.yml
  └── ansible.cfg
```

## Configuration

Rules:
- Configuration of each host in `hosts` folder
- Keep as few playbooks as possible, and use tags to run specific components when needed

The name `site.yml` is a convention for the main playbook that orchestrates the execution of other playbooks. It serves as the entry point for running Ansible tasks and typically includes references to other playbooks, roles, or tasks that need to be executed in a specific order.

**How to run specific components**

>[!NOTE]
> When using OpenBao, it is required to set `export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES` otherwise it will error with `[ERROR]: A worker was found in a dead state`


To run only specific components of the Ansible setup without executing the whole thing, we use tags.

Run dns
```bash
ansible-playbook -i inventories/production/hosts.yml playbooks/site.yml --tags "dns"
```

Run the proxy
```bash
ansible-playbook -i inventories/production/hosts.yml playbooks/site.yml --tags "proxy"
```

Run dns and proxy
```bash
ansible-playbook -i inventories/production/hosts.yml playbooks/site.yml --tags "dns,proxy"
```

Run all except dns and proxy
```bash
ansible-playbook -i inventories/production/hosts.yml playbooks/site.yml
--skip-tags "dns,proxy"
```

Generate docker-compose files for one server using `--limit` (e.g `srv_prod_01`)
```bash
ansible-playbook -i ./inventory/hosts.proxmox.yml playbooks/site.yml \
  --limit srv_prod_01 \
  --tags generate_manifests
```


Generate docker-compose files for all servers
```bash
ansible-playbook -i ./inventory/hosts.proxmox.yml playbooks/site.yml \
  --tags generate_manifests
```

Update docker images
```bash
ansible-playbook -i ./inventory/hosts.proxmox.yml playbooks/site.yml \
--tags apps --skip-tags install_docker
```

Generate Caddyfiles
```bash
ansible-playbook -i ./inventory/hosts.proxmox.yml playbooks/site.yml  \
  --tags "generate_caddyfile"
```

Generate DNS files
```bash
ansible-playbook -i ./inventory/hosts.proxmox.yml playbooks/site.yml \
  --tags "dns"
```


## Legacy (Ansible Vault files)

Generate docker-compose files for one server using `--limit` (e.g `srv_prod_01`)
```bash
ansible-playbook -i ./inventory/hosts.proxmox.yml playbooks/site.yml \
  --vault-password-file ./playbooks/vault_pass/.srv-prod-01.vault_pass \
  --limit srv_prod_01 \
  --tags generate_manifests
```

Generate docker-compose files for all servers
```bash
ansible-playbook -i ./inventory/hosts.proxmox.yml playbooks/site.yml \
  --vault-password-file ./inventory/group_vars/all/.vault_pass \
  --vault-password-file ./playbooks/vault_pass/.srv-prod-01.vault_pass \
  --vault-password-file ./playbooks/vault_pass/.security-core.vault_pass \
  --vault-password-file ./playbooks/vault_pass/.forgejo-runner.vault_pass \
  --vault-password-file ./playbooks/vault_pass/.forgejo.vault_pass \
  --tags generate_manifests
```

Update docker images
```bash
ansible-playbook -i ./inventory/hosts.proxmox.yml playbooks/site.yml \
  --vault-password-file ./inventory/group_vars/all/.vault_pass \
  --vault-password-file ./playbooks/vault_pass/.srv-prod-01.vault_pass \
  --vault-password-file ./playbooks/vault_pass/.security-core.vault_pass \
  --vault-password-file ./playbooks/vault_pass/.forgejo-runner.vault_pass \
  --vault-password-file ./playbooks/vault_pass/.forgejo.vault_pass \
--tags apps --skip-tags install_docker
```

Generate Caddyfiles
```bash
ansible-playbook -i ./inventory/hosts.proxmox.yml playbooks/site.yml  \
  --vault-password-file ./inventory/group_vars/all/.vault_pass \
  --vault-id srv_prod_01@playbooks/vault_pass/.srv-prod-01.vault_pass \
  --tags "generate_caddyfile"
```

Generate DNS files
```bash
ansible-playbook -i ./inventory/hosts.proxmox.yml playbooks/site.yml \
  --vault-password-file ./inventory/group_vars/all/.vault_pass \
  --vault-password-file ./playbooks/vault_pass/.srv-prod-01.vault_pass  \
  --vault-pass-file inventory/group_vars/all/.vault_pass \
  --tags "dns"
```
