module "this" {
  source = "../../"

  proxmox_node = "proxmox"

  vm_name        = "terraform-ubuntu-clone"
  vm_description = "Managed by Terraform"
  vm_tags        = ["terraform", "ubuntu"]

  clone_vm = true
  clone_vm_target = {
    vm_id = 901
    full  = true
  }

  vm_enable_qemu_agent = true
}
