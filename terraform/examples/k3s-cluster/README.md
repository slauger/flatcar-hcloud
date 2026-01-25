# K3s HA Cluster

Deployment of a highly available K3s cluster with integrated load balancer and firewall.

## Features

- HA K3s cluster (3 server nodes)
- Hetzner Load Balancer for HTTP/HTTPS/K3s API
- Integrated firewall
- Automatic K3s token generation
- Daily K3s updates
- Optional Cloudflare DNS

## Architecture

```
                   Internet
                      │
                      ▼
              [Load Balancer]
               :80, :443, :6443
                      │
         ┌────────────┼────────────┐
         ▼            ▼            ▼
    [K3s Server 1] [K3s Server 2] [K3s Server 3]
         │            │            │
    [Firewall]   [Firewall]   [Firewall]
```

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
   ```

3. **Deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Get kubeconfig:**
   ```bash
   # Get kubeconfig from first server
   terraform output -raw kubeconfig_command | sh > kubeconfig.yaml

   # Update server IP to load balancer IP
   LB_IP=$(terraform output -raw load_balancer_ip)
   sed -i "s|https://.*:6443|https://${LB_IP}:6443|" kubeconfig.yaml

   # Test connection
   kubectl --kubeconfig=kubeconfig.yaml get nodes
   ```

5. **View cluster info:**
   ```bash
   terraform output connection_info
   ```

## Configuration

### Basic Configuration

Edit `terraform.tfvars`:

```hcl
name         = "k3s-server"
dns_domain   = "example.com"
cluster_name = "production"

server_count = 3  # 3 for HA
server_type  = "cx32"
location     = "nbg1"

ssh_keys = ["your-ssh-key-name"]
ssh_public_keys = ["ssh-rsa AAAAB3..."]
```

### Load Balancer

```hcl
load_balancer_enabled        = true
load_balancer_type           = "lb11"
load_balancer_services       = ["http", "https"]
load_balancer_expose_k3s_api = true
load_balancer_dns_name       = "k3s"  # Creates k3s.example.com
```

The load balancer distributes traffic to all K3s servers:
- **HTTP** (80) - Traefik ingress
- **HTTPS** (443) - Traefik ingress
- **K3s API** (6443) - Kubernetes API

### Firewall

Default firewall rules:
- ✅ SSH (22) - configurable sources
- ✅ HTTP (80)
- ✅ HTTPS (443)
- ✅ K3s API (6443) - configurable sources
- ✅ ICMP

Restrict access (recommended):
```hcl
firewall_ssh_sources     = ["YOUR_IP/32"]
firewall_k3s_api_sources = ["YOUR_IP/32"]
```

### Cloudflare DNS

Enable Cloudflare DNS for load balancer:

```hcl
cloudflare_enabled = true
cloudflare_domain  = "example.com"
load_balancer_dns_name = "k3s"  # Creates k3s.example.com
```

## Scaling

### Single Node (for testing)

```hcl
server_count = 1
```

### High Availability (recommended)

```hcl
server_count = 3  # or more (odd numbers recommended)
```

## ARM64 Support

Deploy on ARM instances:

```hcl
arch        = "arm64"
server_type = "cax21"  # ARM instance type
```

## Working with the Cluster

### Deploy an application

```bash
kubectl --kubeconfig=kubeconfig.yaml apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  selector:
    app: nginx
  ports:
  - port: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF
```

### Access K3s nodes

```bash
# First server
ssh core@$(terraform output -json server_ips | jq -r '.[0]')

# Check K3s status
sudo kubectl get nodes
sudo systemctl status k3s
```

## Monitoring

Check load balancer health:

```bash
# In Hetzner Cloud Console or via CLI
hcloud load-balancer describe $(terraform output -raw load_balancer_id)
```

## Upgrade K3s

K3s updates automatically via systemd timer (daily). To trigger manually:

```bash
ssh core@<server-ip>
sudo systemctl start k3s-updater.service
```

## Costs

Estimated monthly costs (Hetzner Cloud):
- 3x CX32 servers: ~3 × €11 = €33
- 1x LB11 load balancer: ~€6
- **Total: ~€39/month**

## Cleanup

```bash
terraform destroy
```

## Troubleshooting

### K3s not starting

```bash
ssh core@<server-ip>
sudo journalctl -u k3s -f
```

### Load balancer health check failing

Check if K3s is running and ports are accessible:
```bash
ssh core@<server-ip>
sudo systemctl status k3s
sudo netstat -tulpn | grep -E ':(80|443|6443)'
```

### Unable to access cluster

Ensure your IP is allowed in firewall:
```hcl
firewall_k3s_api_sources = ["YOUR_IP/32"]
```
