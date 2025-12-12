terraform {
  required_version = ">= 1.0"

  required_providers {
    # https://github.com/bpg/terraform-provider-proxmox
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc06"
    }
  }
}