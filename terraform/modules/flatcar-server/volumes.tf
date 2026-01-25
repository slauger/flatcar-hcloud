resource "hcloud_volume" "volumes" {
  count     = var.volume ? var.instance_count : 0
  name      = "${element(hcloud_server.server[*].name, count.index)}-data"
  size      = var.volume_size
  format    = var.volume_format
  automount = false
  server_id = element(hcloud_server.server[*].id, count.index)
  location  = var.location

  labels = merge(
    var.labels,
    {
      managed_by = "terraform"
      server     = element(hcloud_server.server[*].name, count.index)
    }
  )
}
