locals {
  version       = var.version != "" ? var.version : local.flatcar_version_info.FLATCAR_VERSION_ID
  download_url  = "https://stable.release.flatcar-linux.net/amd64-usr/${var.version != "" ? var.version : "current"}/flatcar_production_image.bin.bz2"
  snapshot_name = "${var.snapshot_prefix}${local.version}"
}

source "hcloud" "builder" {
  image         = "ubuntu-22.04"
  location      = "${var.location}"
  rescue        = "linux64"
  server_type   = "${var.server_type}"
  snapshot_name = "${local.snapshot_name}"
  ssh_username  = "root"

  snapshot_labels = {
    image_type = "${var.image_type}"
    os         = "flatcar"
  }
}

build {
  sources = ["source.hcloud.builder"]

  provisioner "shell" {
    inline = [
      "curl -fsSL ${local.download_url} | bzcat | dd if=/dev/stdin of=/dev/sda bs=64k",
      "mount /dev/sda6 /mnt"
    ]
  }

  provisioner "file" {
    destination = "/mnt/grub.cfg"
    source      = "${var.grub_config}"
  }

  provisioner "shell" {
    inline = [
      "umount /mnt"
    ]
  }
}
