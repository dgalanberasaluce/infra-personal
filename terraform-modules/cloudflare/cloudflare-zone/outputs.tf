output "standard_record_ids" {
  description = "A map matching the input standard record keys to their generated Cloudflare Record IDs."
  value       = { for key, record in cloudflare_dns_record.standard : key => record.id }
}

output "mx_record_ids" {
  description = "A map matching the input MX record keys to their generated Cloudflare Record IDs."
  value       = { for key, record in cloudflare_dns_record.mx : key => record.id }
}
