# Proxmox VMs module
Terraform modules that manages Virtual Machines running on Proxmox

## Usage
```hcl
module "vm" {
  source = "terraform-modules/proxmox/vm"

  proxmox_node = "proxmox"
}
```

## Examples
- [Basic Example](./examples/00-simple-vm/)
- [Setting up a VM using a VM Template](./examples/01-clone-vm/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | 0.89.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_proxmox"></a> [proxmox](#provider\_proxmox) | 0.89.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [proxmox_virtual_environment_vm.this](https://registry.terraform.io/providers/bpg/proxmox/0.89.1/docs/resources/virtual_environment_vm) | resource |
| [proxmox_virtual_environment_vms.all_vms](https://registry.terraform.io/providers/bpg/proxmox/0.89.1/docs/data-sources/virtual_environment_vms) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vm_description"></a> [vm\_description](#input\_vm\_description) | Description of the usage of the virtual machine | `string` | n/a | yes |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | Name of the virtual machine | `string` | n/a | yes |
| <a name="input_clone_vm"></a> [clone\_vm](#input\_clone\_vm) | Whether to clone an existing VM | `bool` | `false` | no |
| <a name="input_clone_vm_target"></a> [clone\_vm\_target](#input\_clone\_vm\_target) | Object defining the source vm template to be cloned. <br/><br/>- 'vm\_id' is the identifier of the source VM to clone.<br/>- 'datastore' is the target datastore where the cloned VM will be stored.<br/>- 'full' indicates whether to perform a full clone (true) or linked clone (false).<br/><br/>In addition 'clone\_vm' needs to be enabled.<br/>Use this variable if you know the source VM ID or use vm\_template\_name instead | <pre>object({<br/>    vm_id     = number<br/>    datastore = optional(string, null)<br/>    full      = bool<br/>  })</pre> | `null` | no |
| <a name="input_efi_disk"></a> [efi\_disk](#input\_efi\_disk) | EFI disk configuration for the VM | <pre>object({<br/>    datastore_id      = string<br/>    file_format       = string<br/>    pre_enrolled_keys = optional(bool)<br/>    type              = string<br/>  })</pre> | `null` | no |
| <a name="input_enable_network"></a> [enable\_network](#input\_enable\_network) | Whether to enable network interface for the VM | `bool` | `true` | no |
| <a name="input_operating_system_type"></a> [operating\_system\_type](#input\_operating\_system\_type) | The operating system configuration | `string` | `null` | no |
| <a name="input_proxmox_node"></a> [proxmox\_node](#input\_proxmox\_node) | Proxmox node name where VM will be created | `string` | `"proxmox"` | no |
| <a name="input_proxmox_vm_id"></a> [proxmox\_vm\_id](#input\_proxmox\_vm\_id) | The identifier for the source VM | `number` | `null` | no |
| <a name="input_vm_bios_type"></a> [vm\_bios\_type](#input\_vm\_bios\_type) | The BIOS implementation for the VM | `string` | `null` | no |
| <a name="input_vm_boot_from_disk"></a> [vm\_boot\_from\_disk](#input\_vm\_boot\_from\_disk) | Whether to boot the VM from disk | `bool` | `false` | no |
| <a name="input_vm_boot_order"></a> [vm\_boot\_order](#input\_vm\_boot\_order) | Boot order for the VM. List of devices to boot from in the order they appear in the list. | `list(string)` | `null` | no |
| <a name="input_vm_cd_drive"></a> [vm\_cd\_drive](#input\_vm\_cd\_drive) | CD/DVD drive configuration for the VM. It requires both clone\_vm to be false and vm\_boot\_from\_disk to be true. | <pre>object({<br/>    interface = optional(string)<br/>    file_id     = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_vm_ci_password"></a> [vm\_ci\_password](#input\_vm\_ci\_password) | Cloud-init password | `string` | `""` | no |
| <a name="input_vm_ci_user"></a> [vm\_ci\_user](#input\_vm\_ci\_user) | Cloud-init username | `string` | `"ubuntu"` | no |
| <a name="input_vm_cores"></a> [vm\_cores](#input\_vm\_cores) | Number of CPU cores for the VM | `number` | `2` | no |
| <a name="input_vm_cpu_flags"></a> [vm\_cpu\_flags](#input\_vm\_cpu\_flags) | List of CPU flags for the VM | `list(string)` | `null` | no |
| <a name="input_vm_cpu_type"></a> [vm\_cpu\_type](#input\_vm\_cpu\_type) | CPU type for the VM | `string` | `"x86-64-v2-AES"` | no |
| <a name="input_vm_cpu_units"></a> [vm\_cpu\_units](#input\_vm\_cpu\_units) | CPU units for the VM | `number` | `null` | no |
| <a name="input_vm_disk_size"></a> [vm\_disk\_size](#input\_vm\_disk\_size) | Size of the VM disk (GB) | `number` | `10` | no |
| <a name="input_vm_disk_storage"></a> [vm\_disk\_storage](#input\_vm\_disk\_storage) | Storage location for the VM disk | `string` | `"local-lvm"` | no |
| <a name="input_vm_disk_type"></a> [vm\_disk\_type](#input\_vm\_disk\_type) | Disk type for the VM | `string` | `"scsi"` | no |
| <a name="input_vm_disks"></a> [vm\_disks](#input\_vm\_disks) | List of disk configurations for the VM | <pre>list(object({<br/>    aio          = optional(string)<br/>    backup       = optional(bool)<br/>    cache        = optional(string)<br/>    iothread     = optional(bool)<br/>    datastore_id = optional(string)<br/>    interface    = optional(string)<br/>    size         = optional(number)<br/>    replicate    = optional(bool)<br/>  }))</pre> | `[]` | no |
| <a name="input_vm_display"></a> [vm\_display](#input\_vm\_display) | The VGA configuration for the VM | <pre>object({<br/>    type   = string<br/>    memory = optional(number)<br/>  })</pre> | <pre>{<br/>  "memory": 0,<br/>  "type": "serial0"<br/>}</pre> | no |
| <a name="input_vm_enable_qemu_agent"></a> [vm\_enable\_qemu\_agent](#input\_vm\_enable\_qemu\_agent) | Enable QEMU guest agent | `bool` | `null` | no |
| <a name="input_vm_machine_type"></a> [vm\_machine\_type](#input\_vm\_machine\_type) | The machine type for the VM. Defaults of module to `pc` | `string` | `null` | no |
| <a name="input_vm_memory"></a> [vm\_memory](#input\_vm\_memory) | Amount of memory in MB for the VM | `number` | `2048` | no |
| <a name="input_vm_network_bridge"></a> [vm\_network\_bridge](#input\_vm\_network\_bridge) | Network bridge for the VM | `string` | `"vmbr0"` | no |
| <a name="input_vm_network_devices"></a> [vm\_network\_devices](#input\_vm\_network\_devices) | n/a | <pre>list(object({<br/>    bridge          = string<br/>    enable_firewall = bool<br/>  }))</pre> | `[]` | no |
| <a name="input_vm_network_model"></a> [vm\_network\_model](#input\_vm\_network\_model) | Network model for the VM | `string` | `"virtio"` | no |
| <a name="input_vm_scsihw"></a> [vm\_scsihw](#input\_vm\_scsihw) | SCSI hardware type | `string` | `"virtio-scsi-pci"` | no |
| <a name="input_vm_sockets"></a> [vm\_sockets](#input\_vm\_sockets) | Number of CPU sockets for the VM | `number` | `1` | no |
| <a name="input_vm_start_on_boot"></a> [vm\_start\_on\_boot](#input\_vm\_start\_on\_boot) | Whether the VM should start on boot | `bool` | `false` | no |
| <a name="input_vm_started"></a> [vm\_started](#input\_vm\_started) | Whether the VM should be started | `bool` | `false` | no |
| <a name="input_vm_tags"></a> [vm\_tags](#input\_vm\_tags) | Tags for the VM | `list(string)` | <pre>[<br/>  "managed-by-terraform"<br/>]</pre> | no |
| <a name="input_vm_template_name"></a> [vm\_template\_name](#input\_vm\_template\_name) | Name of the Proxmox template to clone | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_cores"></a> [vm\_cores](#output\_vm\_cores) | Number of CPU cores assigned to the VM |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | The ID of the created VM |
| <a name="output_vm_memory"></a> [vm\_memory](#output\_vm\_memory) | Amount of memory (MB) assigned to the VM |
| <a name="output_vm_name"></a> [vm\_name](#output\_vm\_name) | The name of the created VM |
| <a name="output_vm_network"></a> [vm\_network](#output\_vm\_network) | Network configuration of the VM |
| <a name="output_vm_node"></a> [vm\_node](#output\_vm\_node) | The Proxmox node where the VM is running |
| <a name="output_vm_sockets"></a> [vm\_sockets](#output\_vm\_sockets) | Number of CPU sockets assigned to the VM |
| <a name="output_vm_tags"></a> [vm\_tags](#output\_vm\_tags) | Tags assigned to the VM |
| <a name="output_vm_template_id"></a> [vm\_template\_id](#output\_vm\_template\_id) | The template ID used to create the VM |
| <a name="output_vm_template_name"></a> [vm\_template\_name](#output\_vm\_template\_name) | The template name used to create the VM |
<!-- END_TF_DOCS -->