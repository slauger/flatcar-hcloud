# Butane Configuration Examples

This directory contains Butane configuration examples for Flatcar Container Linux on Hetzner Cloud.

## Overview

| Example | Description | Use Case |
|---------|-------------|----------|
| [basic.yaml](#basicyaml) | Minimal Flatcar setup | Base system, manual configuration |
| [docker-container.yaml](#docker-containeryaml) | Docker containers as systemd services | Single container workloads |
| [docker-compose.yaml](#docker-composeyaml) | Docker Compose stack | Multi-container applications |
| [k3s.yaml](#k3syaml) | Single K3s server | Development, small workloads |
| [k3s-internal.yaml](#k3s-internalyaml) | K3s in private network | Private cluster setup |

## Usage

### With Packer

These configs can be used directly with Packer:

```bash
# Build with custom config
packer build -var "user_data=$(cat examples/k3s.yaml)" .
```

### With Terraform

Use the `ct` provider to transpile Butane to Ignition:

```hcl
data "ct_config" "example" {
  content = file("${path.module}/examples/k3s.yaml")
  strict  = true
}
```

### Manual Testing

Transpile with the `butane` CLI:

```bash
# Install butane
brew install butane

# Transpile to Ignition
butane --strict < examples/k3s.yaml > ignition.json
```

## Examples

### basic.yaml

Minimal Flatcar setup with SSH access and hostname from Hetzner metadata.

**Features:**
- SSH key configuration
- Hostname from metadata API

**Use for:**
- Base system setup
- Manual service configuration
- Testing

### docker-container.yaml

Run Docker containers as systemd services.

**Features:**
- Docker enabled
- Nginx example container
- PostgreSQL example (disabled)
- Traefik reverse proxy example (disabled)
- Registry authentication template

**Use for:**
- Single container deployments
- Simple web applications
- Database servers
- Reverse proxies

**Example services:**
```bash
# Start Nginx
sudo systemctl start nginx-container

# Enable PostgreSQL
sudo systemctl enable --now postgres-container

# Check status
sudo systemctl status nginx-container
```

### docker-compose.yaml

Run a complete Docker Compose stack.

**Features:**
- Docker Compose setup
- Example stack (Nginx + Redis + PostgreSQL)
- Daily automatic updates
- Persistent volumes

**Use for:**
- Multi-container applications
- Full application stacks
- Development environments

**Manage the stack:**
```bash
# Check status
docker-compose -f /opt/docker-compose.yml ps

# View logs
docker-compose -f /opt/docker-compose.yml logs -f

# Restart services
sudo systemctl restart docker-compose-app
```

### k3s.yaml

Single K3s server with automatic installation.

**Features:**
- K3s installed on first boot
- Daily automatic updates
- Docker/Containerd disabled (K3s brings its own)
- Optional cluster mode

**Use for:**
- Development clusters
- Small production workloads
- Single-node Kubernetes

**Access the cluster:**
```bash
# Get kubeconfig
sudo cat /etc/rancher/k3s/k3s.yaml

# Check nodes
kubectl get nodes
```

**Enable cluster mode:**
Uncomment in the file:
```yaml
Environment="K3S_TOKEN=your-secret-token"
Environment="INSTALL_K3S_EXEC=server --cluster-init"
```

### k3s-internal.yaml

K3s server in a private network with custom routing.

**Features:**
- Private network configuration
- Custom routing setup
- K3s bound to private interface
- Flannel configuration for private networks

**Use for:**
- Private clusters
- Multi-server setups with private networking
- High-security deployments

**Network setup:**
- Bind address: `192.168.240.2`
- Gateway: `192.168.240.1`
- DNS: Cloudflare (1.1.1.1, 1.0.0.1)

## Customization

### SSH Keys

Replace the placeholder in each file:
```yaml
ssh_authorized_keys:
  - ssh-rsa AAAAB3... user@example.com  # Your actual SSH public key
```

### Docker Registry Authentication

For private images, add credentials to `docker-container.yaml`:
```yaml
- path: /home/core/.docker/config.json
  mode: 0600
  user:
    name: core
  contents:
    inline: |
      {
        "auths": {
          "registry.example.com": {
            "auth": "base64-encoded-username:password"
          }
        }
      }
```

Generate auth token:
```bash
echo -n "username:password" | base64
```

### Environment Variables

Add environment variables to services:
```yaml
ExecStart=/usr/bin/docker run \
  -e DATABASE_URL=postgres://... \
  -e API_KEY=secret \
  my-app:latest
```

## Best Practices

1. **Always use SSH keys** - Never use passwords
2. **Pin container versions** - Use `nginx:1.25-alpine` instead of `nginx:latest`
3. **Use volumes for data** - Keep data persistent across restarts
4. **Enable automatic updates** - For security patches
5. **Test configurations** - Transpile with `butane --strict` before deploying
6. **Use secrets management** - Don't hardcode passwords in configs

## Troubleshooting

### Check service status
```bash
sudo systemctl status service-name
```

### View logs
```bash
sudo journalctl -u service-name -f
```

### Restart service
```bash
sudo systemctl restart service-name
```

### Docker logs
```bash
docker logs -f container-name
```

## Resources

- [Butane Documentation](https://coreos.github.io/butane/)
- [Flatcar Documentation](https://www.flatcar.org/docs/latest/)
- [K3s Documentation](https://docs.k3s.io/)
- [Docker Documentation](https://docs.docker.com/)

## License

MIT
