# Generate K3s token
resource "random_password" "k3s_token" {
  length  = 32
  special = false
}

# K3s server Ignition config
data "ct_config" "k3s_server" {
  content = templatefile("${path.module}/templates/k3s-server.yaml", {
    k3s_token       = random_password.k3s_token.result
    install_exec    = var.cluster_init ? "--cluster-init" : "--server https://${var.cluster_init_server}:6443"
    k3s_config      = var.k3s_config
    ssh_public_keys = var.ssh_public_keys
    volumes         = var.volumes
  })
  strict = var.ct_strict
}

# Deploy K3s servers using flatcar-server module
module "k3s_servers" {
  source = "../flatcar-server"

  name       = var.name
  dns_domain = var.dns_domain

  instance_count = var.server_count
  server_type    = var.server_type
  arch           = var.arch
  location       = var.location

  ignition_config = data.ct_config.k3s_server.rendered

  ssh_keys   = var.ssh_keys
  keep_disk  = var.keep_disk
  backups    = var.backups
  network_id = var.network_id
  public_net = var.public_net

  # Firewall configuration
  firewall_enabled        = var.firewall_enabled
  firewall_allow_ssh      = var.firewall_allow_ssh
  firewall_ssh_sources    = var.firewall_ssh_sources
  firewall_allowed_ports  = concat(var.firewall_allowed_ports, [6443]) # Always allow K3s API
  firewall_k3s_api_sources = var.load_balancer_enabled ? [for ip in hcloud_load_balancer.k3s_lb[0].ipv4 : "${ip}/32"] : var.firewall_k3s_api_sources

  # Volumes
  volumes = var.volumes

  # Cloudflare DNS
  cloudflare_enabled = var.cloudflare_enabled
  cloudflare_domain  = var.cloudflare_domain

  labels = merge(
    var.labels,
    {
      role    = "k3s-server"
      cluster = var.cluster_name
    }
  )
}
