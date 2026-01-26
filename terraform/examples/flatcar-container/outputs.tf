output "server_id" {
  description = "Server ID"
  value       = module.server.server_ids[0]
}

output "server_name" {
  description = "Server FQDN"
  value       = module.server.server_names[0]
}

output "ipv4_address" {
  description = "IPv4 address"
  value       = module.server.ipv4_addresses[0]
}

output "ipv6_address" {
  description = "IPv6 address"
  value       = module.server.ipv6_addresses[0]
}

output "firewall_id" {
  description = "Firewall ID"
  value       = module.server.firewall_id
}

output "volume_ids" {
  description = "Map of volume names to IDs"
  value       = module.server.volume_ids
}

output "volume_info" {
  description = "Detailed volume information"
  value       = module.server.volume_info
}

output "ssh_command" {
  description = "SSH command to connect to server"
  value       = "ssh core@${module.server.ipv4_addresses[0]}"
}
