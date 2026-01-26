variable "name" {
  description = "Base name for K3s servers (without domain)"
  type        = string
}

variable "dns_domain" {
  description = "DNS domain to append to instance names"
  type        = string
}

variable "cluster_name" {
  description = "Name of the K3s cluster (used for labels)"
  type        = string
  default     = "main"
}

variable "server_count" {
  description = "Number of K3s server nodes"
  type        = number
  default     = 3
  validation {
    condition     = var.server_count >= 1
    error_message = "At least 1 server node is required."
  }
}

variable "server_type" {
  description = "Hetzner Cloud instance type for servers"
  type        = string
  default     = "cx32"
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

variable "location" {
  description = "Hetzner Cloud location"
  type        = string
  default     = "nbg1"
}

variable "ssh_keys" {
  description = "SSH key IDs or names to inject"
  type        = list(string)
  default     = []
}

variable "ssh_public_keys" {
  description = "SSH public keys to add to Ignition config"
  type        = list(string)
}

variable "keep_disk" {
  description = "Don't upgrade disk (allows downgrading)"
  type        = bool
  default     = true
}

variable "backups" {
  description = "Enable backups"
  type        = bool
  default     = false
}

variable "network_id" {
  description = "Network ID to attach servers to (optional)"
  type        = number
  default     = null
}

variable "public_net" {
  description = "Enable public network interface"
  type        = bool
  default     = true
}

# K3s Configuration
variable "cluster_init" {
  description = "Initialize a new cluster (first server only)"
  type        = bool
  default     = true
}

variable "cluster_init_server" {
  description = "Address of the first server to join (required if cluster_init is false)"
  type        = string
  default     = ""
}

variable "k3s_config" {
  description = "Additional K3s config.yaml content"
  type        = string
  default     = ""
}

variable "ct_strict" {
  description = "Strict mode for ct config transpiler"
  type        = bool
  default     = true
}

# Firewall Configuration
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
  description = "Source IP ranges allowed for SSH"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "firewall_allowed_ports" {
  description = "Additional TCP ports to allow through firewall"
  type        = list(number)
  default     = [80, 443]
}

variable "firewall_k3s_api_sources" {
  description = "Source IP ranges allowed for K3s API (port 6443)"
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

# Load Balancer Configuration
variable "load_balancer_enabled" {
  description = "Enable load balancer in front of K3s servers"
  type        = bool
  default     = true
}

variable "load_balancer_type" {
  description = "Hetzner Cloud load balancer type"
  type        = string
  default     = "lb11"
}

variable "load_balancer_services" {
  description = "Services to expose on load balancer (http, https)"
  type        = list(string)
  default     = ["http", "https"]
  validation {
    condition     = alltrue([for s in var.load_balancer_services : contains(["http", "https"], s)])
    error_message = "Services must be 'http' or 'https'."
  }
}

variable "load_balancer_expose_k3s_api" {
  description = "Expose K3s API (port 6443) through load balancer"
  type        = bool
  default     = true
}

variable "load_balancer_dns_name" {
  description = "DNS name for load balancer (e.g., 'k3s-lb' or 'k3s-lb.example.com')"
  type        = string
  default     = ""
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
  description = "Additional DNS records pointing to load balancer (e.g., ['*.apps', 'api'])"
  type        = list(string)
  default     = []
}

variable "volumes" {
  description = "List of volumes to attach and mount to each server (device names are assigned as /dev/sdb, /dev/sdc, etc. in order)"
  type = list(object({
    name       = string
    size       = number
    mount_path = string
  }))
  default = []
}

variable "labels" {
  description = "Additional labels to apply"
  type        = map(string)
  default     = {}
}
