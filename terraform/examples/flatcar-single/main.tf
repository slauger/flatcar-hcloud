# Single Flatcar server deployment
# This example deploys a single Flatcar server with firewall (HTTP/HTTPS)

# Fetch SSH keys from Hetzner Cloud
data "hcloud_ssh_keys" "keys" {
  with_selector = var.ssh_key_selector
}

# Convert Container Linux Config to Ignition
data "ct_config" "server" {
  content = templatefile("${path.module}/config.yaml", {
    ssh_public_keys = [for key in data.hcloud_ssh_keys.keys.ssh_keys : key.public_key]
  })
  strict = true
}

module "server" {
  source = "../../modules/flatcar-server"

  name       = var.name
  dns_domain = var.dns_domain

  server_type = var.server_type
  location    = var.location
  arch        = var.arch

  ignition_config = data.ct_config.server.rendered

  ssh_keys = var.ssh_keys

  # Firewall Configuration
  firewall_enabled       = var.firewall_enabled
  firewall_allow_ssh     = var.firewall_allow_ssh
  firewall_ssh_sources   = var.firewall_ssh_sources
  firewall_allowed_ports = var.firewall_allowed_ports

  # Optional: Volume
  volume        = var.volume_enabled
  volume_size   = var.volume_size
  volume_format = var.volume_format

  # Cloudflare DNS
  cloudflare_enabled            = var.cloudflare_enabled
  cloudflare_domain             = var.cloudflare_domain
  cloudflare_additional_records = var.cloudflare_additional_records

  labels = var.labels
}
