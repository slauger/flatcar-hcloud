# Single K3s Server

Deployment of a single K3s server on Flatcar Container Linux with integrated firewall.

## Features

- Single K3s server (non-HA)
- Automatic K3s installation on first boot
- Daily K3s updates via systemd timer
- Firewall with K3s API (6443), HTTP/HTTPS
- Optional Cloudflare DNS
- SSH access control

## Quick Start

1. **Set environment variables:**
   ```bash
   export HCLOUD_TOKEN="your-hetzner-token"
   export CLOUDFLARE_API_TOKEN="your-cloudflare-token"  # optional
   ```

2. **Configure:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your settings
   vim terraform.tfvars
   ```

3. **Deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Get kubeconfig:**
   ```bash
   # SSH to server
   ssh core@$(terraform output -raw ipv4_address)

   # Get kubeconfig
   sudo cat /etc/rancher/k3s/k3s.yaml

   # Copy to local machine and update server IP
   ```

## Configuration

Edit `terraform.tfvars`:

```hcl
name       = "k3s01"
dns_domain = "example.com"

server_type = "cx23"
location    = "nbg1"

# SSH keys from Hetzner Cloud (for server creation)
ssh_keys = ["your-ssh-key-name"]

# SSH key selector (fetches public keys from Hetzner Cloud)
# Leave empty to use all SSH keys
ssh_key_selector = ""

# Firewall
firewall_enabled       = true
firewall_allowed_ports = [80, 443, 6443]  # HTTP, HTTPS, K3s API

# Restrict SSH to your IP (recommended)
# firewall_ssh_sources = ["1.2.3.4/32"]
```

## Firewall Rules

Default firewall configuration:
- ✅ SSH (22) - from all IPs
- ✅ HTTP (80)
- ✅ HTTPS (443)
- ✅ K3s API (6443)
- ✅ ICMP

To restrict SSH to your IP only:
```hcl
firewall_ssh_sources = ["YOUR_IP/32"]
```

## Getting kubeconfig

```bash
# Get kubeconfig with terraform output (recommended)
terraform output -raw kubeconfig_command | sh
export KUBECONFIG=kubeconfig.yaml
kubectl get nodes

# Or manually with sed
ssh core@$(terraform output -raw ipv4_address) "sudo cat /etc/rancher/k3s/k3s.yaml" | \
  sed "s/127.0.0.1/$(terraform output -raw ipv4_address)/" > kubeconfig.yaml

# Or using DNS name (if configured)
ssh core@$(terraform output -raw server_name) "sudo cat /etc/rancher/k3s/k3s.yaml" | \
  sed "s/127.0.0.1/$(terraform output -raw server_name)/" > kubeconfig.yaml
```

## Wildcard DNS for Applications

Create wildcard DNS records for Ingress/Traefik (like OpenShift's `*.apps.example.com`):

```hcl
# In terraform.tfvars
cloudflare_enabled = true
cloudflare_domain  = "example.com"

# Additional DNS records (all point to the K3s server)
cloudflare_additional_records = [
  "*.apps",      # *.apps.example.com -> for application ingress
  "*.dev",       # *.dev.example.com  -> for dev apps
  "api"          # api.example.com    -> for API endpoint
]
```

This creates:
- `*.apps.example.com` → K3s server IP (for apps like `myapp.apps.example.com`)
- `*.dev.example.com` → K3s server IP (for dev deployments)
- `api.example.com` → K3s server IP (for API access)

Perfect for cert-manager with Let's Encrypt wildcard certificates!

## Architecture

Using ARM64:
```hcl
arch        = "arm64"
server_type = "cax11"  # ARM instance
```

## K3s Updates

K3s is automatically updated daily via systemd timer. To disable:
- Remove the `k3s-updater.timer` unit from `config.yaml`

## Cleanup

```bash
terraform destroy
```
