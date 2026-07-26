# Forgejo

Git clone from virtual machine
1. Generate ssh key 
```bash
ssh-keygen -t ed25519 -C "srv-prod-01"
```

2. Change permission of the keys
```bash
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

3. Add the public key to the Forgejo Repository
- Go to the repository
- Settings > Deploy Keys > Add deploy key