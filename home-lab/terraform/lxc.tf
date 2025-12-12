module "caddy_lxc" {
  source = "../../terraform-modules/proxmox/lxc"

  lxc_hostname = "alpine-caddy"
  vm_id        = 107

  lxc_cores       = 1
  lxc_cpulimit    = 0
  lxc_memory      = 256
  lxc_memory_swap = 512

  rootfs_storage = {
    storage = "nvme4tb"
    size    = "3G"
  }

  lxc_networks = [
    {
      name   = "eth0"
      bridge = "vmbr0"
      ip     = "dhcp"
    }
  ]

  lxc_description = <<-EOT
            <div align='center'>
              <a href='https://Helper-Scripts.com' target='_blank' rel='noopener noreferrer'>
                <img src='https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/images/logo-81x112.png' alt='Logo' style='width:81px;height:112px;'/>
              </a>

              <h2 style='font-size: 24px; margin: 20px 0;'>Alpine-Caddy LXC</h2>

              <p style='margin: 16px 0;'>
                <a href='https://ko-fi.com/community_scripts' target='_blank' rel='noopener noreferrer'>
                  <img src='https://img.shields.io/badge/&#x2615;-Buy us a coffee-blue' alt='spend Coffee' />
                </a>
              </p>

              <span style='margin: 0 10px;'>
                <i class="fa fa-github fa-fw" style="color: #f5f5f5;"></i>
                <a href='https://github.com/community-scripts/ProxmoxVE' target='_blank' rel='noopener noreferrer' style='text-decoration: none; color: #00617f;'>GitHub</a>
              </span>
              <span style='margin: 0 10px;'>
                <i class="fa fa-comments fa-fw" style="color: #f5f5f5;"></i>
                <a href='https://github.com/community-scripts/ProxmoxVE/discussions' target='_blank' rel='noopener noreferrer' style='text-decoration: none; color: #00617f;'>Discussions</a>
              </span>
              <span style='margin: 0 10px;'>
                <i class="fa fa-exclamation-circle fa-fw" style="color: #f5f5f5;"></i>
                <a href='https://github.com/community-scripts/ProxmoxVE/issues' target='_blank' rel='noopener noreferrer' style='text-decoration: none; color: #00617f;'>Issues</a>
              </span>
            </div>
        EOT

  lxc_tags = [
    "community-script", "webserver"
  ]
}

module "minio_lxc" {
  source       = "../../terraform-modules/proxmox/lxc"
  lxc_hostname = "minio"
  vm_id        = 103

  lxc_cores       = 1
  lxc_cpulimit    = 0
  lxc_memory      = 1024
  lxc_memory_swap = 512

  rootfs_storage = {
    storage = "nvme4tb"
    size    = "5G"
  }

  lxc_networks = [
    {
      name   = "eth0"
      bridge = "vmbr0"
      ip     = "dhcp"
    }
  ]
  lxc_tags = [
    "object-storage"
  ]

}

module "technitiumdns_lxc" {
  source = "../../terraform-modules/proxmox/lxc"

  lxc_hostname = "technitiumdns"
  vm_id        = 110

  lxc_cores       = 1
  lxc_cpulimit    = 0
  lxc_memory      = 512
  lxc_memory_swap = 512

  rootfs_storage = {
    storage = "nvme4tb"
    size    = "2G"
  }

  lxc_networks = [
    {
      name   = "eth0"
      bridge = "vmbr0"
      ip     = "dhcp"
    }
  ]

  lxc_tags = [
    "dns"
  ]
}

module "immich_lxc" {
  source       = "../../terraform-modules/proxmox/lxc"
  lxc_hostname = "immich"
  vm_id        = 104

  lxc_cores       = 4
  lxc_cpulimit    = 0
  lxc_memory      = 1024 * 4
  lxc_memory_swap = 512

  rootfs_storage = {
    storage = "nvme4tb"
    size    = "50G"
  }

  lxc_networks = [
    {
      name   = "eth0"
      bridge = "vmbr0"
      ip     = "dhcp"
    }
  ]

  lxc_tags = [
    "photos"
  ]
}

module "bitwarden_lxc" {
  source       = "../../terraform-modules/proxmox/lxc"

  node_name      = "proxmox"

  lxc_hostname = "vaultwarden"
  # vm_id        = 114


  lxc_ostemplate = "debian-13-standard_13.1-2_amd64.tar.zst"

  lxc_cores = 1
  # lxc_cpulimit    = 0
  lxc_memory = 1024
  # lxc_memory_swap = 512

  lxc_password   = var.default_password
  ssh_public_keys = local.default_ssh_public_key

  lxc_features_nesting = true

  rootfs_storage = {
    storage = "nvme4tb"
    size    = "10G"
  }

  lxc_networks = [
    {
      name   = "eth0"
      bridge = "vmbr0"
      ip     = "dhcp"
    }
  ]

  lxc_tags = [
    "password-manager"
  ]
}