# Telmate provider
variable "proxmox_url" {
  description = "The IP/URL and port of the proxmox server. For example: proxmox.local:8006"
  type        = string
  sensitive   = true
}

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