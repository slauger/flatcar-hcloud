output "server_ids" {
  description = "K3s server node IDs"
  value       = module.k3s_cluster.server_ids
}

output "server_names" {
  description = "K3s server node FQDNs"
  value       = module.k3s_cluster.server_names
}

output "server_ips" {
  description = "K3s server node IPv4 addresses"
  value       = module.k3s_cluster.server_ipv4_addresses
}

output "load_balancer_id" {
  description = "Load balancer ID"
  value       = module.k3s_cluster.load_balancer_id
}

output "load_balancer_ip" {
  description = "Load balancer IPv4 address"
  value       = module.k3s_cluster.load_balancer_ipv4
}

output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = module.k3s_cluster.load_balancer_dns_name
}

output "firewall_id" {
  description = "Firewall ID"
  value       = module.k3s_cluster.firewall_id
}

output "k3s_token" {
  description = "K3s cluster token (use: terraform output -raw k3s_token)"
  value       = module.k3s_cluster.k3s_token
  sensitive   = true
}

output "kubeconfig_command" {
  description = "Command to retrieve kubeconfig from first server"
  value       = module.k3s_cluster.kubeconfig_command
}

output "connection_info" {
  description = "Connection information"
  value = <<-EOT

    K3s Cluster deployed successfully!

    Server IPs: ${join(", ", module.k3s_cluster.server_ipv4_addresses)}
    Load Balancer IP: ${module.k3s_cluster.load_balancer_ipv4}
    ${module.k3s_cluster.load_balancer_dns_name != null ? "Load Balancer DNS: ${module.k3s_cluster.load_balancer_dns_name}" : ""}

    Get kubeconfig:
      ${module.k3s_cluster.kubeconfig_command} > kubeconfig.yaml
      # Replace server IP with load balancer IP:
      sed -i 's|https://.*:6443|https://${module.k3s_cluster.load_balancer_ipv4}:6443|' kubeconfig.yaml

    Get K3s token:
      terraform output -raw k3s_token

    Connect to first server:
      ssh core@${module.k3s_cluster.server_ipv4_addresses[0]}
  EOT
}
