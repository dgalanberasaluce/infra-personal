# Forgejo Actions

Ansible Vault 

Forgejo (like GitHub Actions) doesn't easily let you do dynamic secret injection like `${{ secrets[SERVER_NAME] }}` directly in the bash script. The cleanest and most reliable way to handle this is to pass the entire secrets context into the step as a JSON object, and use jq to extract the correct password based on a naming convention.


Example:
pfsense.yml -> VAULT_PFSENSE
proxmox-01.yml -> VAULT_PROXMOX_01


Create Forgejo secrets:
- GITHUBREPO_PAT
- VAULT_<SERVER_NAME>

Settings > Actions Secrets > Add a new Secret


Permission to github_pat:
- Settings > Developer settings > Personal access token > Fine-grained tokens
  - Repository Access: choose "Only select repositories"
  - Repository Permissions: Add permissions > Contents - Access: Read and write