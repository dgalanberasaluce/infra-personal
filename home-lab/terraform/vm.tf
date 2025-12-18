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


module "windows11" {
  source = "../../terraform-modules/proxmox/vm"

  proxmox_node = "proxmox"

  vm_name        = "Win11"
  vm_description = "Managed by Terraform"

  vm_cpu_flags = []
  # vm_cpu_units = 0
  vm_memory = 4096

  vm_scsihw            = "virtio-scsi-single"
  vm_enable_qemu_agent = true
  vm_bios_type         = "ovmf" # UEFI

  vm_display = {
    type = "std"
  }

  vm_disks = [
    # CD/DVD ide0 virtio-win
    {
      backup       = true
      datastore_id = "local"
      interface    = "ide0"
      replicate    = true
      # The size is around 0.7GB but the tf proxmox provider
      # (bpg/proxmox:v0.89.1) requires a minimum of 1GB
      # I have to manually update the tfstate
      size = 1
    },
    # CD/DVD ide2 Win11.iso
    {
      backup       = true
      datastore_id = "local"
      interface    = "ide2"
      replicate    = true
      size         = 7
    },
    # Hard disk scsi0
    {
      backup       = true
      datastore_id = "local-lvm"
      interface    = "scsi0"
      replicate    = true
      size         = 64
      iothread     = true
    },
  ]

  vm_network_devices = [
    {
      bridge          = "vmbr0"
      enable_firewall = true
    },
  ]

  operating_system_type = "win11"
  vm_machine_type       = "pc-q35-10.0+pve1"

  efi_disk = {
    datastore_id      = "local-lvm"
    file_format       = "raw"
    pre_enrolled_keys = true
    type              = "4m"
  }

  vm_tags = ["windows"]
}