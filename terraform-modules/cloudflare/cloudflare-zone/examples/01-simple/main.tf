module "dns_records" {
  source = "../../../../../terraform-modules/cloudflare/cloudflare-zone"

  zone_id          = var.cloudflare_zone_id
  standard_records = var.standard_records
  mx_records       = var.mx_records
}