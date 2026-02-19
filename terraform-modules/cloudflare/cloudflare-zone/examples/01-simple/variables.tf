########################################
### Cloudflare TF Provider
########################################

variable "cloudflare_api_token" {
  description = "Cloudflare API token with permissions to manage DNS records"
  type        = string
}

########################################
### Cloudflare Configuration
########################################

variable "cloudflare_zone_id" {
  description = "The target Cloudflare Zone ID"
  type        = string
}

variable "standard_records" {
  description = "Standard records to pass to the DNS module"
  type        = any
  default     = {}
}

variable "mx_records" {
  description = "MX records to pass to the DNS module"
  type        = any
  default     = {}
}
