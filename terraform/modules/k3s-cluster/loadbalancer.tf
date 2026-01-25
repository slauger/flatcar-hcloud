resource "hcloud_load_balancer" "k3s_lb" {
  count              = var.load_balancer_enabled ? 1 : 0
  name               = "${var.name}-lb"
  load_balancer_type = var.load_balancer_type
  location           = var.location

  labels = merge(
    var.labels,
    {
      managed_by = "terraform"
      cluster    = var.cluster_name
    }
  )
}

# HTTP Service (optional)
resource "hcloud_load_balancer_service" "http" {
  count            = var.load_balancer_enabled && contains(var.load_balancer_services, "http") ? 1 : 0
  load_balancer_id = hcloud_load_balancer.k3s_lb[0].id
  protocol         = "tcp"
  listen_port      = 80
  destination_port = 80

  health_check {
    protocol = "tcp"
    port     = 80
    interval = 10
    timeout  = 5
    retries  = 3
  }
}

# HTTPS Service (optional)
resource "hcloud_load_balancer_service" "https" {
  count            = var.load_balancer_enabled && contains(var.load_balancer_services, "https") ? 1 : 0
  load_balancer_id = hcloud_load_balancer.k3s_lb[0].id
  protocol         = "tcp"
  listen_port      = 443
  destination_port = 443

  health_check {
    protocol = "tcp"
    port     = 443
    interval = 10
    timeout  = 5
    retries  = 3
  }
}

# K3s API Service
resource "hcloud_load_balancer_service" "k3s_api" {
  count            = var.load_balancer_enabled && var.load_balancer_expose_k3s_api ? 1 : 0
  load_balancer_id = hcloud_load_balancer.k3s_lb[0].id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443

  health_check {
    protocol = "tcp"
    port     = 6443
    interval = 10
    timeout  = 5
    retries  = 3
  }
}

# Attach servers to load balancer
resource "hcloud_load_balancer_target" "k3s_servers" {
  count            = var.load_balancer_enabled ? var.server_count : 0
  load_balancer_id = hcloud_load_balancer.k3s_lb[0].id
  type             = "server"
  server_id        = module.k3s_servers.server_ids[count.index]
  use_private_ip   = var.network_id != null
}

# Cloudflare DNS for Load Balancer
data "cloudflare_zone" "lb_zone" {
  count = var.load_balancer_enabled && var.cloudflare_enabled && var.load_balancer_dns_name != "" ? 1 : 0

  filter = {
    name = var.cloudflare_domain
  }
}

resource "cloudflare_dns_record" "lb_a" {
  count   = var.load_balancer_enabled && var.cloudflare_enabled && var.load_balancer_dns_name != "" ? 1 : 0
  zone_id = data.cloudflare_zone.lb_zone[0].id
  name    = var.load_balancer_dns_name
  content = hcloud_load_balancer.k3s_lb[0].ipv4
  type    = "A"
  ttl     = 1
  proxied = false
}

resource "cloudflare_dns_record" "lb_aaaa" {
  count   = var.load_balancer_enabled && var.cloudflare_enabled && var.load_balancer_dns_name != "" ? 1 : 0
  zone_id = data.cloudflare_zone.lb_zone[0].id
  name    = var.load_balancer_dns_name
  content = hcloud_load_balancer.k3s_lb[0].ipv6
  type    = "AAAA"
  ttl     = 1
  proxied = false
}

# Additional DNS records for Load Balancer (e.g., *.apps.example.com)
resource "cloudflare_dns_record" "lb_additional_a" {
  for_each = var.load_balancer_enabled && var.cloudflare_enabled ? toset(var.cloudflare_additional_records) : []
  zone_id  = data.cloudflare_zone.lb_zone[0].id
  name     = each.value
  content  = hcloud_load_balancer.k3s_lb[0].ipv4
  type     = "A"
  ttl      = 1
  proxied  = false
}

resource "cloudflare_dns_record" "lb_additional_aaaa" {
  for_each = var.load_balancer_enabled && var.cloudflare_enabled ? toset(var.cloudflare_additional_records) : []
  zone_id  = data.cloudflare_zone.lb_zone[0].id
  name     = each.value
  content  = hcloud_load_balancer.k3s_lb[0].ipv6
  type     = "AAAA"
  ttl      = 1
  proxied  = false
}
