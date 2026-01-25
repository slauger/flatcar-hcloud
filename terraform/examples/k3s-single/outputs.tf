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

output "volume_id" {
  description = "Volume ID (if enabled)"
  value       = length(module.server.volume_ids) > 0 ? module.server.volume_ids[0] : null
}

output "ssh_command" {
  description = "SSH command to connect to server"
  value       = "ssh core@${module.server.ipv4_addresses[0]}"
}

output "kubeconfig_command" {
  description = "Command to retrieve kubeconfig"
  value       = "ssh core@${module.server.ipv4_addresses[0]} \"sudo cat /etc/rancher/k3s/k3s.yaml\" | sed 's/127.0.0.1/${module.server.ipv4_addresses[0]}/g' > kubeconfig.yaml"
}
