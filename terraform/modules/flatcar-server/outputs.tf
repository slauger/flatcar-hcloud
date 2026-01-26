output "server_ids" {
  description = "List of server IDs"
  value       = hcloud_server.server[*].id
}

output "server_names" {
  description = "List of server FQDNs"
  value       = hcloud_server.server[*].name
}

output "ipv4_addresses" {
  description = "List of IPv4 addresses"
  value       = hcloud_server.server[*].ipv4_address
}

output "ipv6_addresses" {
  description = "List of IPv6 addresses"
  value       = hcloud_server.server[*].ipv6_address
}

output "ipv6_networks" {
  description = "List of IPv6 network addresses"
  value       = hcloud_server.server[*].ipv6_network
}

output "volume_ids" {
  description = "Map of volume names to IDs"
  value       = { for k, v in hcloud_volume.volumes : k => v.id }
}

output "volume_info" {
  description = "Map of volume information including names, IDs, and device paths"
  value = {
    for k, v in hcloud_volume.volumes : k => {
      id          = v.id
      name        = v.name
      size        = v.size
      device_path = v.linux_device
    }
  }
}

output "image_id" {
  description = "ID of the Flatcar image used"
  value       = data.hcloud_image.flatcar.id
}

output "image_name" {
  description = "Name of the Flatcar image used"
  value       = data.hcloud_image.flatcar.name
}

output "firewall_id" {
  description = "ID of the firewall (if enabled)"
  value       = var.firewall_enabled ? hcloud_firewall.firewall[0].id : null
}
