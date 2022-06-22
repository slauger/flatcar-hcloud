variable "grub_config" {
  type        = string
  description = "path to grub.cfg which should be added to the image"
  default     = "grub.cfg"
}

variable "image_type" {
  type        = string
  description = "content of image_type label"
  default     = "generic"
}

variable "location" {
  type        = string
  description = "hetzner cloud location where to provision the builder vm"
  default     = "nbg1"
}

variable "server_type" {
  type        = string
  description = "hetzner cloud machine type used for building the snapshot"
  default     = "cx11"
}

variable "snapshot_prefix" {
  type        = string
  description = "prefix for the snapshot name (the version number will be appended)"
  default     = "flatcar-"
}

variable "version" {
  type        = string
  description = "version that should be installed (leave empty to install latest stable version)"
  default     = ""
}
