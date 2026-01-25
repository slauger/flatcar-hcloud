variable "name" {
  description = "Server name (without domain)"
  type        = string
  default     = "web"
}

variable "dns_domain" {
  description = "DNS domain to append to server name"
  type        = string
  default     = "example.com"
}

variable "server_type" {
  description = "Hetzner Cloud instance type"
  type        = string
  default     = "cx23"
}

variable "location" {
  description = "Hetzner Cloud location"
  type        = string
  default     = "nbg1"
}

variable "arch" {
  description = "CPU architecture (amd64 or arm64)"
  type        = string
  default     = "amd64"
}

variable "ssh_keys" {
  description = "SSH key IDs or names from Hetzner Cloud"
  type        = list(string)
  default     = []
}

variable "ssh_key_selector" {
  description = "Selector to filter SSH keys from Hetzner Cloud (e.g., 'environment=production' or leave empty for all)"
  type        = string
  default     = ""
}

# Firewall Configuration
variable "firewall_enabled" {
  description = "Enable firewall"
  type        = bool
  default     = true
}

variable "firewall_allow_ssh" {
  description = "Allow SSH access through firewall"
  type        = bool
  default     = true
}

variable "firewall_ssh_sources" {
  description = "Source IP ranges allowed for SSH (restrict to your IP for security)"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "firewall_allowed_ports" {
  description = "TCP ports to allow through firewall"
  type        = list(number)
  default     = [80, 443, 6443]  # HTTP, HTTPS, K3s API
}

# Volume Configuration
variable "volume_enabled" {
  description = "Enable additional volume"
  type        = bool
  default     = false
}

variable "volume_size" {
  description = "Size of volume in GB"
  type        = number
  default     = 20
}

variable "volume_format" {
  description = "Filesystem format (xfs or ext4)"
  type        = string
  default     = "ext4"
}

# Cloudflare DNS
variable "cloudflare_enabled" {
  description = "Enable Cloudflare DNS integration"
  type        = bool
  default     = false
}

variable "cloudflare_domain" {
  description = "Cloudflare domain for DNS records"
  type        = string
  default     = ""
}

variable "cloudflare_additional_records" {
  description = "Additional DNS records to create (e.g., ['*.apps', 'api', '*.dev'])"
  type        = list(string)
  default     = []
}

# Labels
variable "labels" {
  description = "Additional labels to apply"
  type        = map(string)
  default = {
    environment = "production"
    purpose     = "webserver"
  }
}
