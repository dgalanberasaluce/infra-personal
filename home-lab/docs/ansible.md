# Ansible

## Folder Hierarchy
```text
/ansible
  ├── inventory/
  |   ├── group_vars/
  |   │   ├── all.yml
  |   │   ├── <group_name_01>.yml
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
  │   ├── <server-name-01>.yml       # Playbook for a specific server
  │   └── system-maintenance.yml     # Playbook for general system maintenance tasks
  ├── roles/
  │   └── <role_01>/
  │       ├── defaults/
  │       │   └── main.yml
  │       ├── handlers/ 
  │       │   └── main.yml
  │       ├── meta/
  │       │   └── main.yml
  │       ├── tasks/
  │       │   └── main.yml
  │       ├── templates/
  │       │   ├── docker-compose.yml.j2
  │       │   └── env.j2 
  │       └── vars/
  │           └── main.yml
  └── ansible.cfg
```