# Flatcar Container Example

Deployment of a single Flatcar Container Linux server running a Docker container.

## Features

- Single Flatcar server
- Docker enabled
- Example nginx container running on port 80/443
- Firewall with HTTP/HTTPS
- Automatic container restart on failure
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

   # Customize container in config.yaml
   vim config.yaml
   ```

3. **Deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Test:**
   ```bash
   # Get server IP
   terraform output ipv4_address

   # Test nginx
   curl http://$(terraform output -raw ipv4_address)
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

## Private Docker Registries

If you're using private container images, you need to configure Docker registry authentication.

### Method 1: Docker config.json (Recommended)

Add your registry credentials to `config.yaml`:

```yaml
storage:
  files:
    - path: /home/core/.docker/config.json
      mode: 0600
      user:
        name: core
      contents:
        inline: |
          {
            "auths": {
              "registry.example.com": {
                "auth": "dXNlcm5hbWU6cGFzc3dvcmQ="
              }
            }
          }
```

**Generate the auth token:**
```bash
echo -n "username:password" | base64
```

### Method 2: Docker login in systemd service

```yaml
systemd:
  units:
    - name: my-app.service
      enabled: true
      contents: |
        [Unit]
        Description=My Application
        After=docker.service
        Requires=docker.service

        [Service]
        TimeoutStartSec=0
        Restart=always
        Environment="REGISTRY_USER=myuser"
        Environment="REGISTRY_PASS=mypassword"
        ExecStartPre=/bin/sh -c 'echo $REGISTRY_PASS | docker login registry.example.com -u $REGISTRY_USER --password-stdin'
        ExecStartPre=/usr/bin/docker pull registry.example.com/my-app:latest
        ExecStart=/usr/bin/docker run --name my-app --rm -p 8080:8080 registry.example.com/my-app:latest
```

### GitHub Container Registry (ghcr.io)

```yaml
storage:
  files:
    - path: /home/core/.docker/config.json
      mode: 0600
      user:
        name: core
      contents:
        inline: |
          {
            "auths": {
              "ghcr.io": {
                "auth": "base64-encoded-github-token"
              }
            }
          }
```

**Generate GitHub token:**
1. Go to GitHub Settings → Developer Settings → Personal Access Tokens
2. Create token with `read:packages` scope
3. Encode: `echo -n "USERNAME:TOKEN" | base64`

### Docker Hub Private Images

```yaml
storage:
  files:
    - path: /home/core/.docker/config.json
      mode: 0600
      user:
        name: core
      contents:
        inline: |
          {
            "auths": {
              "https://index.docker.io/v1/": {
                "auth": "base64-encoded-username:password"
              }
            }
          }
```

## Customizing the Container

Edit `config.yaml` to run your own container. The example runs nginx:

```yaml
systemd:
  units:
    - name: docker.service
      enabled: true

    - name: my-app.service
      enabled: true
      contents: |
        [Unit]
        Description=My Application Container
        After=docker.service
        Requires=docker.service

        [Service]
        TimeoutStartSec=0
        Restart=always
        ExecStartPre=-/usr/bin/docker stop my-app
        ExecStartPre=-/usr/bin/docker rm my-app
        ExecStartPre=/usr/bin/docker pull my-registry/my-app:latest
        ExecStart=/usr/bin/docker run --name my-app \
          --rm \
          -p 8080:8080 \
          -e ENV_VAR=value \
          my-registry/my-app:latest
        ExecStop=/usr/bin/docker stop my-app

        [Install]
        WantedBy=multi-user.target
```

## Container Examples

### Traefik Reverse Proxy

```yaml
- name: traefik.service
  enabled: true
  contents: |
    [Unit]
    Description=Traefik Reverse Proxy
    After=docker.service
    Requires=docker.service

    [Service]
    TimeoutStartSec=0
    Restart=always
    ExecStartPre=-/usr/bin/docker stop traefik
    ExecStartPre=-/usr/bin/docker rm traefik
    ExecStartPre=/usr/bin/docker pull traefik:latest
    ExecStart=/usr/bin/docker run --name traefik \
      --rm \
      -p 80:80 \
      -p 443:443 \
      -v /var/run/docker.sock:/var/run/docker.sock \
      traefik:latest \
      --providers.docker=true \
      --entrypoints.web.address=:80 \
      --entrypoints.websecure.address=:443
    ExecStop=/usr/bin/docker stop traefik

    [Install]
    WantedBy=multi-user.target
```

### PostgreSQL Database

```yaml
- name: postgres.service
  enabled: true
  contents: |
    [Unit]
    Description=PostgreSQL Container
    After=docker.service
    Requires=docker.service

    [Service]
    TimeoutStartSec=0
    Restart=always
    ExecStartPre=-/usr/bin/docker stop postgres
    ExecStartPre=-/usr/bin/docker rm postgres
    ExecStartPre=/usr/bin/docker pull postgres:16-alpine
    ExecStart=/usr/bin/docker run --name postgres \
      --rm \
      -p 5432:5432 \
      -e POSTGRES_PASSWORD=changeme \
      -v /var/lib/postgresql/data:/var/lib/postgresql/data \
      postgres:16-alpine
    ExecStop=/usr/bin/docker stop postgres

    [Install]
    WantedBy=multi-user.target
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

For custom ports:
```hcl
firewall_allowed_ports = [80, 443, 8080, 3000]
```

## Managing the Container

```bash
# SSH to server
ssh core@<server-ip>

# Check container status
docker ps

# View logs
journalctl -u nginx-container.service -f

# Restart container
sudo systemctl restart nginx-container.service

# Stop container
sudo systemctl stop nginx-container.service
```

## Docker Compose (Optional)

For more complex setups, you can use Docker Compose:

```yaml
storage:
  files:
    - path: /opt/docker-compose.yml
      mode: 0644
      contents:
        inline: |
          version: '3'
          services:
            web:
              image: nginx:alpine
              ports:
                - "80:80"
                - "443:443"

            app:
              image: my-app:latest
              environment:
                - DATABASE_URL=postgres://postgres:5432/mydb

systemd:
  units:
    - name: docker-compose.service
      enabled: true
      contents: |
        [Unit]
        Description=Docker Compose Application
        After=docker.service
        Requires=docker.service

        [Service]
        Type=oneshot
        RemainAfterExit=yes
        WorkingDirectory=/opt
        ExecStartPre=/usr/bin/docker-compose -f /opt/docker-compose.yml pull
        ExecStart=/usr/bin/docker-compose -f /opt/docker-compose.yml up -d
        ExecStop=/usr/bin/docker-compose -f /opt/docker-compose.yml down

        [Install]
        WantedBy=multi-user.target
```

## Cleanup

```bash
terraform destroy
```
