data "hcloud_image" "flatcar" {
  with_selector     = "os=flatcar,arch=${var.arch}"
  most_recent       = true
}

resource "hcloud_server" "server" {
  count       = var.instance_count
  name        = var.instance_count > 1 ? "${format("${var.name}%02d", count.index + 1)}.${var.dns_domain}" : "${var.name}.${var.dns_domain}"
  image       = data.hcloud_image.flatcar.id
  server_type = var.server_type
  keep_disk   = var.keep_disk
  ssh_keys    = var.ssh_keys
  user_data   = var.ignition_config
  location    = var.location
  backups     = var.backups

  dynamic "network" {
    for_each = var.network_id != null ? [1] : []
    content {
      network_id = var.network_id
    }
  }

  dynamic "public_net" {
    for_each = var.public_net == false ? [1] : []
    content {
      ipv4_enabled = false
      ipv6_enabled = false
    }
  }

  lifecycle {
    ignore_changes = [user_data, ssh_keys]
  }

  labels = merge(
    var.labels,
    {
      managed_by = "terraform"
      os         = "flatcar"
    }
  )
}

data "cloudflare_zone" "zone" {
  count = var.cloudflare_enabled ? 1 : 0

  filter = {
    name = var.cloudflare_domain
  }
}

resource "cloudflare_dns_record" "dns-a" {
  count   = var.cloudflare_enabled && var.public_net ? var.instance_count : 0
  zone_id = data.cloudflare_zone.zone[0].id
  name    = element(hcloud_server.server.*.name, count.index)
  content = element(hcloud_server.server.*.ipv4_address, count.index)
  type    = "A"
  ttl     = var.dns_ttl
}

resource "cloudflare_dns_record" "dns-aaaa" {
  count   = var.cloudflare_enabled && var.public_net ? var.instance_count : 0
  zone_id = data.cloudflare_zone.zone[0].id
  name    = element(hcloud_server.server.*.name, count.index)
  content = element(hcloud_server.server.*.ipv6_address, count.index)
  type    = "AAAA"
  ttl     = var.dns_ttl
}

resource "hcloud_rdns" "dns-ptr-ipv4" {
  count      = var.public_net ? var.instance_count : 0
  server_id  = element(hcloud_server.server.*.id, count.index)
  ip_address = element(hcloud_server.server.*.ipv4_address, count.index)
  dns_ptr    = element(hcloud_server.server.*.name, count.index)
}

resource "hcloud_rdns" "dns-ptr-ipv6" {
  count      = var.public_net ? var.instance_count : 0
  server_id  = element(hcloud_server.server.*.id, count.index)
  ip_address = element(hcloud_server.server.*.ipv6_address, count.index)
  dns_ptr    = element(hcloud_server.server.*.name, count.index)
}
