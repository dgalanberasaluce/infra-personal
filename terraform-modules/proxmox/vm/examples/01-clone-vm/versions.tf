terraform {
  required_version = ">= 1.0"

  required_providers {
    # https://github.com/bpg/terraform-provider-proxmox
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.89.1"
    }
  }
}

provider "proxmox" {
  endpoint = "https://proxmox.internal.local:8006"
  insecure = var.proxmox_tls_insecure

  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
}