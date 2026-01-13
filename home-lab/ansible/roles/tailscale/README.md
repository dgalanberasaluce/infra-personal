# Tailscale
- Requires an account on `login.tailscale.com`

# Set up Tailscale on LXC

Allow unprivileged LXC access to tunnel interfaces (`/dev/net/tun`):
- Go to Proxmox (Host)
- Edit container config file (e.g `/etc/pve/lxc/105.conf`)
- Add the following lines
```txt
lxc.cgroup2.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file 0 0
```