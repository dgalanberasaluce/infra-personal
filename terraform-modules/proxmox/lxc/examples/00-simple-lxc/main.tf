terraform {
  required_providers {
    # https://github.com/Telmate/terraform-provider-proxmox
    # LXC Containers
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.2-rc05"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://${var.proxmox_url}/api2/json"
  pm_tls_insecure = true

  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret

  # pm_debug = true
}

module "lxc_example" {
  source = "../../"

  node_name      = "proxmox"
  lxc_ostemplate = "ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
}

output "lxc_example" {
  value = module.lxc_example
}