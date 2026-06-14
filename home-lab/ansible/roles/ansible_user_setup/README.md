# ansible_user_setup

Creates a secure, dedicated Ansible automation user with:
- SSH key-based authentication only (password login disabled)
- Passwordless `sudo` access
- Sudoers file validated by `visudo` before deployment

## Requirements

- `ansible.posix` collection (for `authorized_key` module)

Install with:
```bash
ansible-galaxy collection install ansible.posix
```

## Role Variables

| Variable | Default | Description |
|---|---|---|
| `ansible_setup_username` | `ansible` | Username to create |
| `ansible_setup_shell` | `/bin/ash` (Alpine) / `/bin/bash` (others) | Shell for the user |
| `ansible_setup_ssh_public_keys` | `[]` | List of SSH public keys to authorize |
| `ansible_setup_passwordless_sudo` | `true` | Enable passwordless sudo |
| `ansible_setup_lock_password` | `true` | Lock the password (SSH key only) |
| `ansible_setup_uid` | `null` | Optional UID to assign |

## Example Playbook

```yaml
- hosts: all
  become: true
  roles:
    - role: ansible_user_setup
      vars:
        ansible_setup_ssh_public_keys:
          - "ssh-ed25519 AAAA... user@workstation"
```

## Security Notes

- The user's password is locked by default, enforcing SSH key-based login.
- The sudoers file is deployed via Jinja2 template and validated with `visudo -cf` before applying.
- A warning is emitted if no SSH public keys are provided.
- **Alpine Linux**: Because a locked password (`!`) also blocks SSH in Alpine's OpenSSH build, the role runs `passwd -u` after user creation to unlock the account entry without setting a real password. Key-based login works; password login remains impossible.
