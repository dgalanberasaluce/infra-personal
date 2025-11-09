locals {
  ostemplates = {
    "ubuntu-24.04" = "ubuntu-24.04-standard_24.04-1_amd64.tar.gz"
    "debian-12"    = "debian-12-standard_12.0-1_amd64.tar.gz"
    "centos-8"     = "centos-8-standard_8.3-1_amd64.tar.gz"
  }
  cmode = "tty"
}

resource "proxmox_lxc" "this" {

  # General Settings
  target_node = var.node_name
  hostname    = var.lxc_hostname
  vmid        = var.vm_id # Ensure unique VMIDs
  ostemplate  = "local:vztmpl/${var.lxc_template}"
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
  rootfs {
    storage = var.rootfs_storage
    size    = var.rootfs_storage_size
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
      type   = lookup(network.value, "type", "veth")
    }
  }

  tags = join(
    ";",
    concat(
      ["managed-by-terraform"],
      var.lxc_tags
    )
  )
}
