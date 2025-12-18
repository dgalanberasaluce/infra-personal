module "this" {
  source = "../../"

  proxmox_node = "proxmox"

  vm_name        = "terraform-provider-proxmox-ubuntu-vm"
  vm_description = "Managed by Terraform"
  vm_tags        = ["ubuntu"]

  enable_network = false
}