# Cloudflare Zone

This module manages a Cloudflare Zone and its associated DNS records. It allows you to create, update, and delete DNS records within a specified Cloudflare Zone.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | ~> 5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_dns_record.mx](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_dns_record.standard](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | The Cloudflare Zone ID where the DNS records will be created | `string` | n/a | yes |
| <a name="input_mx_records"></a> [mx\_records](#input\_mx\_records) | A map of Mail Exchange (MX) records | <pre>map(object({<br/>    name     = string<br/>    content  = string<br/>    priority = number<br/>    ttl      = optional(number, 1)<br/>    comment  = optional(string, "")<br/>  }))</pre> | `{}` | no |
| <a name="input_srv_records"></a> [srv\_records](#input\_srv\_records) | A map of Service Locator (SRV) records | <pre>map(object({<br/>    name     = string<br/>    priority = number<br/>    weight   = number<br/>    port     = number<br/>    target   = string<br/>    ttl      = optional(number, 1)<br/>    comment  = optional(string, "")<br/>  }))</pre> | `{}` | no |
| <a name="input_standard_records"></a> [standard\_records](#input\_standard\_records) | A map of standard DNS records (A, AAAA, CNAME, TXT, etc.) | <pre>map(object({<br/>    name    = string<br/>    type    = string<br/>    content = string<br/>    ttl     = optional(number, 1)<br/>    proxied = optional(bool, false)<br/>    comment = optional(string, "")<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mx_record_ids"></a> [mx\_record\_ids](#output\_mx\_record\_ids) | A map matching the input MX record keys to their generated Cloudflare Record IDs. |
| <a name="output_standard_record_ids"></a> [standard\_record\_ids](#output\_standard\_record\_ids) | A map matching the input standard record keys to their generated Cloudflare Record IDs. |
<!-- END_TF_DOCS -->