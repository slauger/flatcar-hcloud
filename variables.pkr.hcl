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
  default     = "fsn1"
}

variable "server_type" {
  type        = string
  description = "hetzner cloud machine type used for building the snapshot (set to 'auto' to use smallest instance matching the desired arch)"
  default     = "auto"
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

variable "arch" {
  type        = string
  description = "architecture of the image"
  default     = "amd64"
  validation {
    condition     = contains(["amd64", "arm64"], var.arch)
    error_message = "The `arch` variable must be one of 'amd64', 'arm64'."
  }
}
