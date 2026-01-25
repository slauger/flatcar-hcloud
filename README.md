# Flatcar Container Linux on Hetzner Cloud

Build Flatcar Container Linux images on Hetzner Cloud with Packer.

## Overview

This project provides Packer templates to build custom Flatcar Container Linux images on Hetzner Cloud with Ignition support for the Hetzner Cloud metadata service.

Built images can be deployed using the included [Terraform modules](terraform/README.md).

## Quick Start

```bash
# Set Hetzner Cloud API token
export HCLOUD_TOKEN="your-hetzner-token"

# Initialize Packer
packer init .

# Build image (amd64)
packer build .

# Or build ARM64 image
packer build -var arch=arm64 .
```

The built images will have these labels:
- `os=flatcar`
- `arch=amd64` or `arch=arm64`
- `version=<flatcar-version>` (e.g., 4459.2.2)

## Project Structure

```
.
├── flatcar.pkr.hcl          # Packer build configuration
├── variables.pkr.hcl        # Packer variables
├── versions.pkr.hcl         # Packer provider requirements
├── grub.cfg                 # GRUB config with Hetzner userdata
├── examples/                # Container Linux Config examples
│   ├── basic.yaml
│   ├── k3s.yaml
│   └── k3s-internal.yaml
└── terraform/               # Terraform modules for deployment
    └── README.md           # See Terraform documentation
```

## Requirements

- Hetzner Cloud API token
- Packer >= 1.7.0

## Build Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `arch` | CPU architecture (amd64, arm64) | `amd64` |
| `version` | Flatcar version (empty = latest) | `""` |
| `location` | Hetzner Cloud location | `fsn1` |
| `server_type` | Server type for build (auto = smallest for arch) | `auto` |
| `snapshot_prefix` | Prefix for snapshot name | `flatcar-` |

## Build Examples

```bash
# Latest amd64
packer build .

# Latest ARM64
packer build -var arch=arm64 .

# Specific version
packer build -var version=4459.2.2 .

# Different location
packer build -var location=nbg1 .
```

## Image Labels

Built images include these labels for easy selection in Terraform:

```hcl
labels = {
  os      = "flatcar"
  arch    = "amd64"      # or "arm64"
  version = "4459.2.2"   # actual Flatcar version
}
```

Terraform modules automatically select the latest image with `os=flatcar` and the specified architecture.

## Architecture Support

Both amd64 and arm64 are fully supported:

```bash
# Build amd64 (uses cx23 for building)
packer build .

# Build ARM64 (uses cax11 for building)
packer build -var arch=arm64 .
```

## Container Linux Configs

Example Ignition configs are provided in `examples/`:
- `basic.yaml` - Basic Flatcar setup
- `k3s.yaml` - K3s server installation
- `k3s-internal.yaml` - K3s with private network

These can be used as templates for your own configurations.

## Deployment with Terraform

After building an image, you can deploy it using the included Terraform modules:

- **Single Server** - Flatcar server with integrated firewall
- **K3s Cluster** - HA K3s cluster with load balancer

See the [Terraform README](terraform/README.md) for detailed documentation and examples.

### Quick Deploy

```bash
# Single server
cp -r terraform/examples/k3s-single terraform/environments/my-server
cd terraform/environments/my-server
# Edit terraform.tfvars and config.yaml
terraform init && terraform apply

# K3s cluster
cp -r terraform/examples/k3s-cluster terraform/environments/my-cluster
cd terraform/environments/my-cluster
# Edit terraform.tfvars
terraform init && terraform apply
```

## How it Works

1. **Download**: Fetches the official Flatcar image from `stable.release.flatcar-linux.net`
2. **Write**: Writes the image directly to disk using `dd`
3. **Configure**: Injects custom `grub.cfg` that points to Hetzner Cloud metadata service
4. **Snapshot**: Creates a Hetzner Cloud snapshot with proper labels

The GRUB config configures Ignition to read from `http://169.254.169.254/hetzner/v1/userdata`, allowing you to pass Ignition configs via Hetzner Cloud user data.

## Environment Variables

### Required
- `HCLOUD_TOKEN` - Hetzner Cloud API token

## License

MIT
