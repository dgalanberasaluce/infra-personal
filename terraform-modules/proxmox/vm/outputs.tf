# # VM Information Outputs
output "vm_id" {
  description = "The ID of the created VM"
  value       = proxmox_virtual_environment_vm.this.vm_id
}

output "vm_name" {
  description = "The name of the created VM"
  value       = proxmox_virtual_environment_vm.this.name
}

output "vm_node" {
  description = "The Proxmox node where the VM is running"
  value       = proxmox_virtual_environment_vm.this.node_name
}

output "vm_template_name" {
  description = "The template name used to create the VM"
  value       = var.vm_template_name
}

output "vm_template_id" {
  description = "The template ID used to create the VM"
  value       = var.clone_vm ? (var.clone_vm_target != null ? var.clone_vm_target.vm_id : local.vm_template_id) : null
}

# # VM Configuration Outputs
output "vm_cores" {
  description = "Number of CPU cores assigned to the VM"
  value       = proxmox_virtual_environment_vm.this.cpu[0].cores
}

output "vm_sockets" {
  description = "Number of CPU sockets assigned to the VM"
  value       = proxmox_virtual_environment_vm.this.cpu[0].sockets
}

output "vm_memory" {
  description = "Amount of memory (MB) assigned to the VM"
  value       = proxmox_virtual_environment_vm.this.memory[0].dedicated
}

# Network Information
output "vm_network" {
  description = "Network configuration of the VM"
  value       = proxmox_virtual_environment_vm.this.network_device
}

# VM Status and Connection Info
output "vm_tags" {
  description = "Tags assigned to the VM"
  value       = proxmox_virtual_environment_vm.this.tags
}
