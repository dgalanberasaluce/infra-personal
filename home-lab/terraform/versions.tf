terraform {
  required_providers {
    # https://github.com/bpg/terraform-provider-proxmox
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.86.0"
    }

    # https://github.com/Telmate/terraform-provider-proxmox
    # LXC Containers
    telmate = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc05"
    }
  }
}

provider "proxmox" {
  endpoint = "https://proxmox.internal.local:8006"
  insecure = true

  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
}

provider "telmate" {
  pm_api_url      = "https://proxmox.internal.local:8006/api2/json"
  pm_tls_insecure = true

  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret

  pm_debug = true
}