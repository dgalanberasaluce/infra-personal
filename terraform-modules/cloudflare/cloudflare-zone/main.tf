# Standard DNS Records (A, AAAA, CNAME, TXT, etc.)
resource "cloudflare_dns_record" "standard" {
  for_each = var.standard_records

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.content
  ttl     = each.value.ttl
  proxied = each.value.proxied
  comment = each.value.comment
}

# MX Records (Mail Exchange)
resource "cloudflare_dns_record" "mx" {
  for_each = var.mx_records

  zone_id  = var.zone_id
  name     = each.value.name
  type     = "MX"
  content  = each.value.content
  priority = each.value.priority
  ttl      = each.value.ttl
  comment  = each.value.comment

  # Cloudflare does not proxy MX records
  proxied = false
}
