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
  description = "List of volume IDs (if volumes are enabled)"
  value       = var.volume ? hcloud_volume.volumes[*].id : []
}

output "volume_device_paths" {
  description = "List of volume device paths (if volumes are enabled)"
  value       = var.volume ? hcloud_volume.volumes[*].linux_device : []
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
