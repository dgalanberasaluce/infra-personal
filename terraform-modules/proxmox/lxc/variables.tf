# Required
variable "node_name" {
  description = "The Proxmox node where the LXC container will be created. It is not required if the lxc tf resource was imported."
  type        = string
  default     = null
}

variable "lxc_ostemplate" {
  description = "The LXC template to use for creating the container."
  type        = string
  default     = null
}

# Storage
variable "rootfs_storage" {
  description = "List of network configurations for the LXC container."
  type = object({
    storage = optional(string, null)
    size    = optional(string, null)
  })
  default = {
    storage = "local-lvm"
    size    = "8G"
  }
}

# Optional
variable "lxc_hostname" {
  description = "The hostname for the LXC container."
  type        = string
  default     = "lxc-core-01"
}

variable "vm_id" {
  description = "The unique VMID for the LXC container."
  type        = number
  default     = null
}

variable "lxc_cores" {
  description = "Number of CPU cores for the LXC container."
  type        = number
  default     = 1
}

variable "lxc_cpulimit" {
  description = "Option to further limit assigned CPU time"
  type        = number
  # The provider does not allow floating point number
  # default     = 0.5 
  default = 1
}

variable "lxc_cpuunits" {
  description = "Relative CPU weight for the LXC container."
  type        = number
  default     = 100 # cgroup v2
}

variable "lxc_memory" {
  description = "Amount of memory (in MB) for the LXC container."
  type        = number
  default     = 512
}

variable "lxc_memory_swap" {
  description = "Amount of swap memory (in MB) for the LXC container."
  type        = number
  default     = 0
}

variable "lxc_password" {
  description = "Password for the LXC container root user."
  type        = string
  default     = null
  sensitive   = true
}

variable "ssh_public_keys" {
  description = "SSH public keys to be added to the root user's authorized_keys file"
  type        = string
  default     = null
}

variable "lxc_networks" {
  description = "List of network configurations for the LXC container."
  type = list(object({
    name   = string
    bridge = string
    ip     = string
    type   = optional(string, "veth")
  }))
  default = [
    {
      name   = "eth0"
      bridge = "vmbr0"
      ip     = "dhcp"
    }
  ]
}

variable "lxc_description" {
  description = "Description for the LXC container seen in the proxmox web interface"
  type        = string
  default     = ""
}

variable "lxc_tags" {
  description = "Tags to assign to the LXC container."
  type        = list(string)
  default     = []
}

variable "lxc_features_nesting" {
  description = "Enable nesting feature for the LXC container."
  type        = bool
  default     = false
}