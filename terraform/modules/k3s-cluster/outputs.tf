output "server_ids" {
  description = "List of K3s server IDs"
  value       = module.k3s_servers.server_ids
}

output "server_names" {
  description = "List of K3s server FQDNs"
  value       = module.k3s_servers.server_names
}

output "server_ipv4_addresses" {
  description = "List of K3s server IPv4 addresses"
  value       = module.k3s_servers.ipv4_addresses
}

output "server_ipv6_addresses" {
  description = "List of K3s server IPv6 addresses"
  value       = module.k3s_servers.ipv6_addresses
}

output "k3s_token" {
  description = "K3s cluster token (sensitive)"
  value       = random_password.k3s_token.result
  sensitive   = true
}

output "load_balancer_id" {
  description = "Load balancer ID (if enabled)"
  value       = var.load_balancer_enabled ? hcloud_load_balancer.k3s_lb[0].id : null
}

output "load_balancer_ipv4" {
  description = "Load balancer IPv4 address (if enabled)"
  value       = var.load_balancer_enabled ? hcloud_load_balancer.k3s_lb[0].ipv4 : null
}

output "load_balancer_ipv6" {
  description = "Load balancer IPv6 address (if enabled)"
  value       = var.load_balancer_enabled ? hcloud_load_balancer.k3s_lb[0].ipv6 : null
}

output "load_balancer_dns_name" {
  description = "Load balancer DNS name (if configured)"
  value       = var.load_balancer_enabled && var.cloudflare_enabled && var.load_balancer_dns_name != "" ? var.load_balancer_dns_name : null
}

output "kubeconfig_command" {
  description = "Command to retrieve kubeconfig from first server"
  value       = "ssh core@${module.k3s_servers.ipv4_addresses[0]} sudo cat /etc/rancher/k3s/k3s.yaml"
}

output "firewall_id" {
  description = "Firewall ID (if enabled)"
  value       = module.k3s_servers.firewall_id
}
