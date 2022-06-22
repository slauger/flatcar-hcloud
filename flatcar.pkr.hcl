variable "grub_config" {
  type    = string
  default = "grub.cfg"
}

variable "image_type" {
  type    = string
  default = "generic"
}

variable "location" {
  type    = string
  default = "nbg1"
}

variable "server_type" {
  type    = string
  default = "cx11"
}

variable "snapshot_prefix" {
  type    = string
  default = "flatcar-hcloud"
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "hcloud" "builder" {
  image           = "ubuntu-22.04"
  location        = "${var.location}"
  rescue          = "linux64"
  server_type     = "${var.server_type}"
  snapshot_labels = {
    image_type = "${var.image_type}"
    os         = "flatcar"
  }
  snapshot_name = "${var.snapshot_prefix}-${local.timestamp}"
  ssh_username  = "root"
}

build {
  sources = ["source.hcloud.builder"]

  provisioner "shell" {
    inline = [
      "curl -fsSL https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_image.bin.bz2 | bzcat | dd if=/dev/stdin of=/dev/sda bs=64k",
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
