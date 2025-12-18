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