# Single Flatcar Server

Deployment of a single Flatcar Container Linux server with integrated firewall.

## Features

- Single Flatcar server
- Firewall with HTTP/HTTPS (configurable)
- Optional Cloudflare DNS
- Optional additional volume
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
   # Add your SSH public key to ssh_public_keys
   vim terraform.tfvars
   ```

3. **Deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Connect:**
   ```bash
   terraform output ssh_command
   # Or directly:
   ssh core@<ip-address>
   ```

## Configuration

Edit `terraform.tfvars`:

```hcl
name       = "web01"
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
firewall_allowed_ports = [80, 443]

# Restrict SSH to your IP (recommended)
# firewall_ssh_sources = ["1.2.3.4/32"]
```

## Firewall Rules

Default firewall configuration:
- ✅ SSH (22) - from all IPs
- ✅ HTTP (80)
- ✅ HTTPS (443)
- ✅ ICMP

To restrict SSH to your IP only:
```hcl
firewall_ssh_sources = ["YOUR_IP/32"]
```

## Optional: Volume

Enable an additional volume:

```hcl
volume_enabled = true
volume_size    = 50
volume_format  = "ext4"
```

Configure mounting in `config.yaml`:
```yaml
storage:
  filesystems:
    - device: /dev/sdb
      format: ext4
      path: /mnt/data
```

## Architecture

Using ARM64:
```hcl
arch        = "arm64"
server_type = "cax11"  # ARM instance
```

## Cleanup

```bash
terraform destroy
```
