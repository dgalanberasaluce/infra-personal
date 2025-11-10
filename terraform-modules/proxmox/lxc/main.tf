locals {
  ostemplates = {
    "ubuntu-24.04" = "ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
    "debian-12"    = "debian-12-standard_12.0-1_amd64.tar.gz"
    "centos-8"     = "centos-8-standard_8.3-1_amd64.tar.gz"
    "alpine-3.22"  = "alpine-3.22-default_20250617_amd64.tar.xz"
  }
  cmode = "tty"
}

resource "proxmox_lxc" "this" {

  # General Settings
  target_node = var.node_name
  hostname    = var.lxc_hostname
  vmid        = var.vm_id # Ensure unique VMIDs
  ostemplate  = var.lxc_ostemplate != null ? "local:vztmpl/${var.lxc_ostemplate}" : null
  password    = var.lxc_password

  ############## 
  # Resources #
  ##############
  # cpu
  cores    = var.lxc_cores
  cpulimit = var.lxc_cpulimit
  cpuunits = var.lxc_cpuunits

  # memory
  memory = var.lxc_memory
  swap   = var.lxc_memory_swap

  # storage
  dynamic "rootfs" {
    for_each = var.rootfs_storage == null ? [] : [var.rootfs_storage]

    content {
      acl       = false
      quota     = false
      replicate = false
      ro        = false
      shared    = false
      storage   = lookup(rootfs.value, "storage", null)
      size      = lookup(rootfs.value, "size", null)
    }
  }

  ##############
  # Options   #
  ##############

  # Automatic start and shutdown
  onboot = true
  start  = true

  arch    = "amd64"
  cmode   = local.cmode
  console = local.cmode == "tty" ? false : true
  tty     = local.cmode == "tty" ? 2 : 0

  protection   = false
  unprivileged = true

  # features {
  #   nesting = true # Activate only if docker or systemd-nspawn is required
  #   keyctl  = true # Activate if the app needs IPC
  #   fuse    = true  # Required only if sshfs, encfs or mergerfs is required
  # }

  ##############
  # Network   #
  ##############
  dynamic "network" {
    for_each = var.lxc_networks
    content {
      name   = network.value.name
      bridge = network.value.bridge
      ip     = network.value.ip
    }
  }

  description = var.lxc_description

  tags = join(
    ";",
    concat(
      ["managed-by-terraform"],
      var.lxc_tags
    )
  )
}
