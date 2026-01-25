resource "hcloud_firewall" "firewall" {
  count = var.firewall_enabled ? 1 : 0
  name  = "${var.name}-firewall"

  # SSH access
  dynamic "rule" {
    for_each = var.firewall_allow_ssh ? [1] : []
    content {
      direction  = "in"
      protocol   = "tcp"
      port       = "22"
      source_ips = var.firewall_ssh_sources
    }
  }

  # HTTP
  dynamic "rule" {
    for_each = contains(var.firewall_allowed_ports, 80) ? [1] : []
    content {
      direction  = "in"
      protocol   = "tcp"
      port       = "80"
      source_ips = ["0.0.0.0/0", "::/0"]
    }
  }

  # HTTPS
  dynamic "rule" {
    for_each = contains(var.firewall_allowed_ports, 443) ? [1] : []
    content {
      direction  = "in"
      protocol   = "tcp"
      port       = "443"
      source_ips = ["0.0.0.0/0", "::/0"]
    }
  }

  # K3s API (6443)
  dynamic "rule" {
    for_each = contains(var.firewall_allowed_ports, 6443) ? [1] : []
    content {
      direction  = "in"
      protocol   = "tcp"
      port       = "6443"
      source_ips = var.firewall_k3s_api_sources
    }
  }

  # Custom TCP ports
  dynamic "rule" {
    for_each = [for port in var.firewall_allowed_ports : port if !contains([22, 80, 443, 6443], port)]
    content {
      direction  = "in"
      protocol   = "tcp"
      port       = tostring(rule.value)
      source_ips = ["0.0.0.0/0", "::/0"]
    }
  }

  # Custom UDP ports
  dynamic "rule" {
    for_each = var.firewall_allowed_udp_ports
    content {
      direction  = "in"
      protocol   = "udp"
      port       = tostring(rule.value)
      source_ips = ["0.0.0.0/0", "::/0"]
    }
  }

  # ICMP
  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  labels = merge(
    var.labels,
    {
      managed_by = "terraform"
    }
  )
}

resource "hcloud_firewall_attachment" "firewall" {
  count       = var.firewall_enabled ? 1 : 0
  firewall_id = hcloud_firewall.firewall[0].id
  server_ids  = hcloud_server.server[*].id
}
