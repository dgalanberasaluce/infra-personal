variable "zone_id" {
  description = "The Cloudflare Zone ID where the DNS records will be created"
  type        = string
}

variable "standard_records" {
  description = "A map of standard DNS records (A, AAAA, CNAME, TXT, etc.)"
  type = map(object({
    name    = string
    type    = string
    content = string
    ttl     = optional(number, 1)
    proxied = optional(bool, false)
    comment = optional(string, "")
  }))
  default = {}
}

variable "mx_records" {
  description = "A map of Mail Exchange (MX) records"
  type = map(object({
    name     = string
    content  = string
    priority = number
    ttl      = optional(number, 1)
    comment  = optional(string, "")
  }))
  default = {}
}

variable "srv_records" {
  description = "A map of Service Locator (SRV) records"
  type = map(object({
    name     = string
    priority = number
    weight   = number
    port     = number
    target   = string
    ttl      = optional(number, 1)
    comment  = optional(string, "")
  }))
  default = {}
}