# Proxmox LXC module
Terraform modules which creates LXC (Linux Containers) on Proxmox

## Usage
```hcl
module "lxc" {
  source = "terraform-modules/proxmox/lxc"

  node_name = "proxmox"
}
```

## Examples
- [Basic Example](./examples/00-simple-lxc/)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->