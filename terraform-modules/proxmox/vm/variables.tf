# Proxmox Provider Configuration
variable "proxmox_node" {
  description = "Proxmox node name where VM will be created"
  type        = string
  default     = "proxmox"
}

variable "proxmox_vm_id" {
  description = "The identifier for the source VM"
  type        = number
  default     = null
}

# VM Template Configuration
variable "clone_vm" {
  description = "Whether to clone an existing VM"
  type        = bool
  default     = false
}

variable "vm_template_name" {
  description = "Name of the Proxmox template to clone"
  type        = string
  default     = null
}

variable "clone_vm_target" {
  description = <<EOT
Object defining the source vm template to be cloned. 

- 'vm_id' is the identifier of the source VM to clone.
- 'datastore' is the target datastore where the cloned VM will be stored.
- 'full' indicates whether to perform a full clone (true) or linked clone (false).

In addition 'clone_vm' needs to be enabled.
Use this variable if you know the source VM ID or use vm_template_name instead
  EOT

  type = object({
    vm_id     = number
    datastore = optional(string, null)
    full      = bool
  })
  default = null
}

# VM Basic Configuration
variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string

  validation {
    condition     = length(var.vm_name) > 0
    error_message = "VM name cannot be empty."
  }
}

variable "vm_description" {
  description = "Description of the usage of the virtual machine"
  type        = string
}

variable "vm_cores" {
  description = "Number of CPU cores for the VM"
  type        = number
  default     = 2

  validation {
    condition     = var.vm_cores > 0 && var.vm_cores <= 32
    error_message = "VM cores must be between 1 and 32."
  }
}

variable "vm_sockets" {
  description = "Number of CPU sockets for the VM"
  type        = number
  default     = 1

  validation {
    condition     = var.vm_sockets > 0 && var.vm_sockets <= 4
    error_message = "VM sockets must be between 1 and 4."
  }
}

variable "vm_cpu_type" {
  description = "CPU type for the VM"
  type        = string
  default     = "x86-64-v2-AES"
}

variable "vm_memory" {
  description = "Amount of memory in MB for the VM"
  type        = number
  default     = 2048

  validation {
    condition     = var.vm_memory >= 512
    error_message = "VM memory must be at least 512 MB."
  }
}

variable "vm_start_on_boot" {
  description = "Whether the VM should start on boot"
  type        = bool
  default     = false
}

variable "vm_started" {
  description = "Whether the VM should be started"
  type        = bool
  default     = false
}

# VM Hardware Configuration
variable "vm_boot_order" {
  description = "Boot order for the VM. List of devices to boot from in the order they appear in the list."
  type        = list(string)
  default     = null
  # default     = ["ide0", "net0"]
}

variable "vm_boot_from_disk" {
  description = "Whether to boot the VM from disk"
  type        = bool
  default     = false
}

variable "vm_scsihw" {
  description = "SCSI hardware type"
  type        = string
  default     = "virtio-scsi-pci"

  validation {
    condition     = contains(["virtio-scsi-pci", "lsi", "lsi53c895a", "megasas", "virtio-scsi-single"], var.vm_scsihw)
    error_message = "Invalid SCSI hardware type."
  }
}

variable "vm_enable_qemu_agent" {
  description = "Enable QEMU guest agent"
  type        = bool
  default     = null
}

variable "vm_display" {
  description = "The VGA configuration for the VM"
  type = object({
    type   = string
    memory = optional(number)
  })

  default = {
    type   = "serial0"
    memory = 0
  }

  validation {
    condition     = var.vm_display == null || contains(local.vga_hardware_without_memory, var.vm_display.type) || (var.vm_display.memory >= 8 && contains(local.vga_hardware_with_memory, var.vm_display.type))
    error_message = "If vm_display is set, memory must be at least 8 MB and type must be one of 'std', 'qxl', 'virtio', 'vmware', or 'none'."
  }
}

variable "operating_system_type" {
  description = "The operating system configuration"
  type        = string
  default     = null

  validation {
    condition     = var.operating_system_type == null || contains(["l26", "l24", "l23", "win10", "win11", "other"], var.operating_system_type)
    error_message = "If operating_system_type is set, it must be one of 'l26', 'l24', 'l23', 'win10', 'win11', or 'other'."
  }
}

variable "vm_machine_type" {
  description = "The machine type for the VM. Defaults of module to `pc`"
  type        = string
  default     = null
}

# Network Configuration
variable "enable_network" {
  description = "Whether to enable network interface for the VM"
  type        = bool
  default     = true
}

variable "vm_network_model" {
  description = "Network model for the VM"
  type        = string
  default     = "virtio"
}

variable "vm_network_bridge" {
  description = "Network bridge for the VM"
  type        = string
  default     = "vmbr0"
}

variable "vm_network_devices" {
  description = ""
  type = list(object({
    bridge          = string
    enable_firewall = bool
  }))
  default = []
}

# Disk Configuration
variable "vm_disk_type" {
  description = "Disk type for the VM"
  type        = string
  default     = "scsi"
}

variable "vm_disk_storage" {
  description = "Storage location for the VM disk"
  type        = string
  default     = "local-lvm"
}

variable "vm_disk_size" {
  description = "Size of the VM disk (GB)"
  type        = number
  default     = 10
}

variable "vm_disks" {
  description = "List of disk configurations for the VM"
  type = list(object({
    aio          = optional(string)
    backup       = optional(bool)
    cache        = optional(string)
    iothread     = optional(bool)
    datastore_id = optional(string)
    interface    = optional(string)
    size         = number
    replicate    = optional(bool)
  }))
  default = []
}

# Cloud-Init Configuration
variable "vm_ci_user" {
  description = "Cloud-init username"
  type        = string
  default     = "ubuntu"
}

variable "vm_ci_password" {
  description = "Cloud-init password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "vm_tags" {
  description = "Tags for the VM"
  type        = list(string)
  default     = ["managed-by-terraform"]
}
