output "vmid" {
  description = "The VMID of the created LXC container."
  value       = proxmox_lxc.this.vmid
}

output "ip_address" {
  description = "The IP address of the created LXC container."
  value = element(
    coalescelist(proxmox_lxc.this.network.*.ip, [""]),
    0
  )
}

output "hostname" {
  description = "The hostname of the created LXC container."
  value       = proxmox_lxc.this.hostname
}

output "node" {
  description = "The Proxmox node where the LXC container is created."
  value       = proxmox_lxc.this.target_node
}