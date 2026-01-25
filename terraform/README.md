# Flatcar on Hetzner Cloud - Terraform

Terraform modules and examples for deploying Flatcar Container Linux on Hetzner Cloud, with built-in firewall and load balancer support.

## Quick Start

1. **Build Flatcar image** (if you haven't already):
   ```bash
   cd ..
   export HCLOUD_TOKEN="your-token"
   packer init .
   packer build .
   ```

2. **Copy an example and deploy**:
   ```bash
   cd terraform
   mkdir -p environments

   # Copy example
   cp -r examples/flatcar-single environments/my-server
   cd environments/my-server

   # Configure
   cp terraform.tfvars.example terraform.tfvars
   vim terraform.tfvars

   # Deploy
   terraform init
   terraform apply
   ```

## Examples

Each example includes a detailed README with full documentation:

| Example | Description | Use Case |
|---------|-------------|----------|
| **[flatcar-single](examples/flatcar-single/)** | Minimal Flatcar server with firewall | Base system, manual setup |
| **[flatcar-container](examples/flatcar-container/)** | Flatcar running Docker containers | Single container apps, Docker workloads |
| **[k3s-single](examples/k3s-single/)** | Single K3s server | Development, testing, small workloads |
| **[k3s-cluster](examples/k3s-cluster/)** | HA K3s cluster with load balancer | Production, high availability |

**See each example's README for:**
- Detailed setup instructions
- Configuration options
- Architecture examples
- Use case guides

## Structure

```
terraform/
├── modules/
│   ├── flatcar-server/    # Base module for Flatcar servers
│   └── k3s-cluster/       # K3s cluster with load balancer
├── examples/
│   ├── flatcar-single/    # Minimal Flatcar server
│   ├── flatcar-container/ # Flatcar with Docker
│   ├── k3s-single/        # Single K3s server
│   └── k3s-cluster/       # HA K3s cluster
└── environments/          # Your deployments (gitignored)
    └── my-server/         # Copy from examples/
```

## Modules

### flatcar-server

Base module for deploying Flatcar Container Linux servers.

**Features:**
- Automatic Flatcar image selection (amd64/arm64)
- Integrated firewall with configurable rules
- Optional Cloudflare DNS integration
- Optional volume attachment
- Private network support

**Basic Usage:**

```hcl
module "webserver" {
  source = "./modules/flatcar-server"

  name            = "web"
  dns_domain      = "example.com"
  server_type     = "cx23"
  ignition_config = data.ct_config.basic.rendered
  ssh_keys        = ["your-ssh-key-name"]

  # Firewall
  firewall_enabled       = true
  firewall_allowed_ports = [80, 443]
}
```

See [flatcar-server module README](modules/flatcar-server/README.md) for full documentation.

### k3s-cluster

Module for deploying HA K3s clusters with load balancer.

**Features:**
- HA K3s cluster (3+ servers)
- Integrated Hetzner Load Balancer
- Automatic firewall configuration
- Cloudflare DNS integration
- Daily K3s updates

**Basic Usage:**

```hcl
module "k3s" {
  source = "./modules/k3s-cluster"

  name         = "k3s-server"
  dns_domain   = "example.com"
  cluster_name = "production"

  server_count = 3
  server_type  = "cx32"
  ssh_keys     = ["your-ssh-key-name"]

  # Load Balancer
  load_balancer_enabled  = true
  load_balancer_services = ["http", "https"]

  # Firewall
  firewall_enabled       = true
  firewall_allowed_ports = [80, 443]
}
```

See [k3s-cluster module README](modules/k3s-cluster/README.md) for full documentation.

## Common Features

### Firewall Configuration

All examples include integrated firewall support:

```hcl
# Basic firewall
firewall_enabled       = true
firewall_allowed_ports = [80, 443]

# Restrict SSH access
firewall_allow_ssh   = true
firewall_ssh_sources = ["1.2.3.4/32"]  # Your IP only

# Custom ports
firewall_allowed_ports     = [80, 443, 8080]
firewall_allowed_udp_ports = [51820]  # WireGuard
```

### Architecture Support

Both amd64 and arm64 architectures are supported:

```hcl
arch        = "arm64"
server_type = "cax11"  # ARM instance type
```

### Private Networks

Deploy servers in private networks:

```hcl
resource "hcloud_network" "private" {
  name     = "private-network"
  ip_range = "10.0.0.0/16"
}

module "server" {
  # ...
  network_id = hcloud_network.private.id
  public_net = false  # Private only
}
```

### Cloudflare DNS Integration

Automatic DNS record creation:

```hcl
cloudflare_enabled = true
cloudflare_domain  = "example.com"
```

## Requirements

| Provider | Version |
|----------|---------|
| terraform | >= 1.0 |
| hcloud | ~> 1.45 |
| cloudflare | ~> 4.0 (optional) |
| ct | ~> 0.13 |
| random | ~> 3.6 |

## Environment Variables

```bash
export HCLOUD_TOKEN="your-hetzner-token"
export CLOUDFLARE_API_TOKEN="your-cloudflare-token"  # optional
```

## License

MIT
