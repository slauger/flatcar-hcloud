# Create a map of volumes per server instance
locals {
  volume_map = merge([
    for idx in range(var.instance_count) : {
      for vol in var.volumes :
      "${hcloud_server.server[idx].name}-${vol.name}" => {
        server_index = idx
        server_id    = hcloud_server.server[idx].id
        server_name  = hcloud_server.server[idx].name
        name         = vol.name
        size         = vol.size
        mount_path   = vol.mount_path
      }
    }
  ]...)
}

resource "hcloud_volume" "volumes" {
  for_each  = local.volume_map
  name      = each.key
  size      = each.value.size
  format    = "xfs"
  automount = false
  server_id = each.value.server_id
  # Location is inherited from server when server_id is set

  labels = merge(
    var.labels,
    {
      managed_by = "terraform"
      server     = each.value.server_name
      volume     = each.value.name
    }
  )
}
