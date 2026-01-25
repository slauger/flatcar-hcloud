variable "name" {
  description = "Base name for K3s servers (without domain)"
  type        = string
  default     = "k3s-server"
}

variable "dns_domain" {
  description = "DNS domain to append to server names"
  type        = string
  default     = "example.com"
}

variable "cluster_name" {
  description = "Name of the K3s cluster (used for labels)"
  type        = string
  default     = "production"
}

variable "server_count" {
  description = "Number of K3s server nodes (3 for HA)"
  type        = number
  default     = 3
}

variable "server_type" {
  description = "Hetzner Cloud instance type"
  type        = string
  default     = "cx32"
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

variable "ssh_public_keys" {
  description = "SSH public keys to add to Ignition config"
  type        = list(string)
}

variable "k3s_config" {
  description = "Additional K3s config.yaml content"
  type        = string
  default     = "cluster-init: true"
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
  description = "Additional TCP ports to allow (HTTP/HTTPS for ingress)"
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
  description = "Enable load balancer"
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
}

variable "load_balancer_expose_k3s_api" {
  description = "Expose K3s API (port 6443) through load balancer"
  type        = bool
  default     = true
}

variable "load_balancer_dns_name" {
  description = "DNS name for load balancer (e.g., 'k3s' for k3s.example.com)"
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

# Labels
variable "labels" {
  description = "Additional labels to apply"
  type        = map(string)
  default = {
    environment = "production"
  }
}
