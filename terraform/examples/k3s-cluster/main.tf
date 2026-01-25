# K3s HA Cluster with Load Balancer
# This example deploys a highly available K3s cluster with integrated load balancer and firewall

module "k3s_cluster" {
  source = "../../modules/k3s-cluster"

  name         = var.name
  dns_domain   = var.dns_domain
  cluster_name = var.cluster_name

  server_count = var.server_count
  server_type  = var.server_type
  location     = var.location
  arch         = var.arch

  ssh_keys        = var.ssh_keys
  ssh_public_keys = var.ssh_public_keys

  # K3s Configuration
  cluster_init = true
  k3s_config   = var.k3s_config

  # Firewall Configuration
  firewall_enabled         = var.firewall_enabled
  firewall_allow_ssh       = var.firewall_allow_ssh
  firewall_ssh_sources     = var.firewall_ssh_sources
  firewall_allowed_ports   = var.firewall_allowed_ports
  firewall_k3s_api_sources = var.firewall_k3s_api_sources

  # Load Balancer Configuration
  load_balancer_enabled        = var.load_balancer_enabled
  load_balancer_type           = var.load_balancer_type
  load_balancer_services       = var.load_balancer_services
  load_balancer_expose_k3s_api = var.load_balancer_expose_k3s_api
  load_balancer_dns_name       = var.load_balancer_dns_name

  # Cloudflare DNS
  cloudflare_enabled = var.cloudflare_enabled
  cloudflare_domain  = var.cloudflare_domain

  labels = var.labels
}
