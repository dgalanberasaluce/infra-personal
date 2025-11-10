# Telmate provider
variable "proxmox_api_token_id" {
  description = "The API Token ID for proxmox"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "The API Secret for proxmox"
  type        = string
  sensitive   = true
}

# bgp provider
variable "proxmox_api_token_full" {
  description = "The full token for proxmox"
  type        = string
  sensitive   = true
}

variable "vm_ssh_key" {
  description = "Key used to ssh as the 'admin' user to the virtual machine"
  type        = string
  sensitive   = true
}

# VM Template Configuration
# Copy https://www.virtualizationhowto.com/2025/08/instant-vms-and-lxcs-on-proxmox-my-go-to-terraform-templates-for-quick-deployments/
variable "vm_template" {
  description = "Name of the Proxmox template to clone"
  type        = string
  default     = "ubuntu-2404-template-nvme4tb"
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
  type        = string
  default     = "terraform,ubuntu"
}

