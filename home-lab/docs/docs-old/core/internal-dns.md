# Internal Domain Configuration

## Preferred Domain

The preferred top-level domain (TLD) for the homelab environment is `.internal`. This domain segments internal network services from the public DNS hierarchy.

## Optional Domains

Valid alternative TLDs for internal use include `.lan` and `.home.arpa`.

## Implementation

Manage the internal zone via the local DNS server (**TechnitiumDNS**).

1. **Zone Creation:** Create a new primary DNS zone for `.internal`.
2. **DNS Records:** Assign A, AAAA, and CNAME records to network hosts (e.g., `proxmox.internal`, `nas.internal`).
3. **DHCP Configuration:** Configure the DHCP server to distribute `.internal` as the default search domain to all network clients.
4. **Certificate Management:** Provision SSL/TLS certificates for `.internal` hostnames using a local Certificate Authority (CA).

## Note
> [!CAUTION]
> The `.local` TLD is strictly not recommended for internal unicast DNS configurations.

