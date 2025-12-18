module "opnsense" {
  source = "../../terraform-modules/proxmox/vm"

  proxmox_node = "proxmox"

  vm_name        = "opnsense"
  vm_description = "Managed by Terraform"

  vm_cpu_type = "host"
  vm_cores    = 2
  vm_sockets  = 1

  vm_memory = 4096

  vm_scsihw = "virtio-scsi-single"

  vm_display = {
    type = "serial0"
  }

  vm_disks = [
    {
      backup       = true
      datastore_id = "local"
      interface    = "ide2"
      replicate    = true
      size         = 2
    },
    {
      aio          = "io_uring"
      backup       = true
      cache        = "writeback"
      datastore_id = "nvme4tb"
      size         = 30
      iothread     = true
      replicate    = true
    }
  ]

  vm_network_devices = [
    {
      bridge          = "vmbr0"
      enable_firewall = false
    },
    {
      bridge          = "vmbr1"
      enable_firewall = false
    }
  ]

  operating_system_type = "l26"
  vm_machine_type       = "q35"

  vm_tags = ["firewall"]
}