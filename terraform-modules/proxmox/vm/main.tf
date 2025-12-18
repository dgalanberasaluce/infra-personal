data "proxmox_virtual_environment_vms" "all_vms" {
  node_name = var.proxmox_node
}

locals {
  default_tags                = ["managed-by-terraform"]
  vga_hardware_with_memory    = ["std", "vmware", "qxl", "cirrus", "virtio"]
  vga_hardware_without_memory = ["none", "serial0", "serial1", "serial2", "serial3"]
  vga_hardware                = concat(local.vga_hardware_with_memory, local.vga_hardware_without_memory)
  available_storage           = ["nvme4tb", "local-lvm"]

  template_vms = var.clone_vm && var.clone_vm_target != null ? [
    for vm in data.proxmox_virtual_environment_vms.all_vms.vms : vm
    if vm.name == var.vm_template_name
  ] : []
  vm_template_id = length(local.template_vms) > 0 ? local.template_vms[0].vm_id : null
}

resource "proxmox_virtual_environment_vm" "this" {
  name        = var.vm_name
  description = var.vm_description
  tags        = distinct(concat(local.default_tags, var.vm_tags))

  node_name = var.proxmox_node
  vm_id     = var.proxmox_vm_id

  on_boot = var.vm_start_on_boot
  started = var.vm_started

  cpu {
    cores   = var.vm_cores
    sockets = var.vm_sockets
    type    = var.vm_cpu_type
  }

  memory {
    dedicated = var.vm_memory
    # floating  = var.vm_memory # set equal to dedicated to enable ballooning
  }

  # VM Hardware Configuration
  dynamic "agent" { # qemu guest agent
    for_each = var.vm_enable_qemu_agent != null ? [1] : []

    content {
      enabled = var.vm_enable_qemu_agent
    }
  }
  boot_order    = var.vm_boot_order
  scsi_hardware = var.vm_scsihw

  dynamic "vga" {
    for_each = var.vm_display != null ? [var.vm_display] : []

    content {
      type   = vga.value.type
      memory = contains(local.vga_hardware_without_memory, vga.value.type) ? null : vga.value.memory
    }
  }

  # if agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  # https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm#qemu-guest-agent
  stop_on_destroy = var.vm_enable_qemu_agent != null ? !var.vm_enable_qemu_agent : true

  # Clone or boot from disk (cdrom)
  dynamic "cdrom" {
    for_each = var.clone_vm || !var.vm_boot_from_disk ? [] : [1]

    content {
      #<datastore_id>:<content_type>/<file_name>
      # proxmox_virtual_environment_download_file
      file_id   = "local:iso/ubuntu-24.04.3-desktop-amd64.iso"
      interface = "ide2"
    }
  }

  dynamic "clone" {
    for_each = var.clone_vm ? [var.clone_vm_target] : []

    content {
      vm_id        = var.clone_vm_target != null ? clone.value.vm_id : local.vm_template_id
      datastore_id = var.clone_vm_target != null ? clone.value.datastore : null
      full         = var.clone_vm_target != null ? clone.value.full : true
    }
  }

  # Disk Configuration
  dynamic "disk" {
    for_each = var.clone_vm ? [] : (length(var.vm_disks) > 0 ? var.vm_disks : [{}])

    content {
      backup       = length(var.vm_disks) > 0 && disk.value.backup != null ? disk.value.backup : false
      cache        = length(var.vm_disks) > 0 && disk.value.cache != null ? disk.value.cache : "none"
      iothread     = length(var.vm_disks) > 0 && disk.value.iothread != null ? disk.value.iothread : false
      datastore_id = length(var.vm_disks) > 0 && disk.value.datastore_id != null ? disk.value.datastore_id : contains(local.available_storage, "nvme4tb") ? "nvme4tb" : null
      interface    = length(var.vm_disks) > 0 && disk.value.interface != null ? disk.value.interface : "scsi0"
      size         = length(var.vm_disks) > 0 && disk.value.size != null ? disk.value.size : "32"
      replicate    = length(var.vm_disks) > 0 && disk.value.replicate != null ? disk.value.replicate : false
    }
  }

  # Network Configuration
  dynamic "network_device" {
    for_each = var.enable_network ? (length(var.vm_network_devices) > 0 ? var.vm_network_devices : [{}]) : []

    content {
      bridge   = length(var.vm_network_devices) > 0 ? network_device.value.bridge : var.vm_network_bridge
      firewall = length(var.vm_network_devices) > 0 ? network_device.value.enable_firewall : true
    }
  }

  dynamic "operating_system" {
    for_each = var.operating_system_type != null ? [1] : []

    content {
      type = var.operating_system_type
    }
  }

  machine = var.vm_machine_type
}
