variable "name" {
  description = "Instance name (without domain)"
  type        = string
}

variable "dns_domain" {
  description = "DNS domain to append to instance name"
  type        = string
}

variable "cloudflare_enabled" {
  description = "Enable Cloudflare DNS integration"
  type        = bool
  default     = false
}

variable "cloudflare_domain" {
  description = "Cloudflare domain for DNS records (only used if cloudflare_enabled is true)"
  type        = string
  default     = ""
}

variable "cloudflare_additional_records" {
  description = "Additional DNS records to create (e.g., ['*.apps', 'api', '*.dev'])"
  type        = list(string)
  default     = []
}

variable "dns_ttl" {
  description = "TTL for DNS records"
  type        = number
  default     = 1
}

variable "instance_count" {
  description = "Number of instances to deploy"
  type        = number
  default     = 1
}

variable "server_type" {
  description = "Hetzner Cloud instance type"
  type        = string
  default     = "cx23"
}

variable "arch" {
  description = "CPU architecture (amd64 or arm64)"
  type        = string
  default     = "amd64"
  validation {
    condition     = contains(["amd64", "arm64"], var.arch)
    error_message = "The arch variable must be either 'amd64' or 'arm64'."
  }
}

variable "ignition_config" {
  description = "Ignition config (JSON format) to use during server creation"
  type        = string
}

variable "ssh_keys" {
  description = "SSH key IDs or names which should be injected into the server at creation time"
  type        = list(string)
  default     = []
}

variable "keep_disk" {
  description = "If true, do not upgrade the disk. This allows downgrading the server type later."
  type        = bool
  default     = true
}

variable "location" {
  description = "The location name to create the server in (nbg1, fsn1, hel1, ash, hil)"
  type        = string
  default     = "nbg1"
}

variable "backups" {
  description = "Enable or disable backups"
  type        = bool
  default     = false
}

variable "volumes" {
  description = "List of volumes to attach and mount to the server"
  type = list(object({
    name       = string
    size       = number
    mount_path = string
  }))
  default = []
}

variable "network_id" {
  description = "Network ID to attach server to (optional)"
  type        = number
  default     = null
}

variable "public_net" {
  description = "Enable public network interface"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Additional labels to apply to the server"
  type        = map(string)
  default     = {}
}

# Firewall variables
variable "firewall_enabled" {
  description = "Enable firewall for the servers"
  type        = bool
  default     = true
}

variable "firewall_allow_ssh" {
  description = "Allow SSH access through firewall"
  type        = bool
  default     = true
}

variable "firewall_ssh_sources" {
  description = "Source IP ranges allowed for SSH (only used if firewall_allow_ssh is true)"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "firewall_allowed_ports" {
  description = "List of TCP ports to allow through firewall (80, 443, 6443, etc.)"
  type        = list(number)
  default     = [80, 443]
}

variable "firewall_allowed_udp_ports" {
  description = "List of UDP ports to allow through firewall"
  type        = list(number)
  default     = []
}

variable "firewall_k3s_api_sources" {
  description = "Source IP ranges allowed for K3s API (port 6443)"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}
