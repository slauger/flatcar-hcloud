# K3s Cluster Module

Terraform module for deploying HA K3s clusters on Hetzner Cloud with integrated load balancer.

## Features

- High availability K3s cluster (3+ servers)
- Integrated Hetzner Load Balancer
- Automatic firewall configuration
- Cloudflare DNS integration
- Automatic K3s token generation
- Daily K3s updates via systemd timer
- HTTP/HTTPS/K3s API load balancing

## Usage

### Basic HA Cluster

```hcl
module "k3s" {
  source = "./modules/k3s-cluster"

  name         = "k3s-server"
  dns_domain   = "example.com"
  cluster_name = "production"

  server_count = 3
  server_type  = "cx32"
  location     = "nbg1"

  ssh_keys        = ["your-ssh-key-name"]
  ssh_public_keys = ["ssh-rsa AAAAB3..."]

  # Load Balancer
  load_balancer_enabled  = true
  load_balancer_services = ["http", "https"]

  # Firewall
  firewall_enabled       = true
  firewall_allowed_ports = [80, 443]
}
```

### With Cloudflare DNS

```hcl
module "k3s" {
  source = "./modules/k3s-cluster"

  name         = "k3s-server"
  dns_domain   = "example.com"
  cluster_name = "production"

  # ... other config ...

  # Load Balancer DNS
  load_balancer_dns_name = "k3s.example.com"
  cloudflare_enabled     = true
  cloudflare_domain      = "example.com"
}
```

### Expose K3s API via Load Balancer

```hcl
module "k3s" {
  source = "./modules/k3s-cluster"

  # ... other config ...

  load_balancer_enabled         = true
  load_balancer_services        = ["http", "https"]
  load_balancer_expose_k3s_api  = true  # Expose port 6443
}
```

### Custom K3s Configuration

```hcl
module "k3s" {
  source = "./modules/k3s-cluster"

  # ... other config ...

  k3s_config = <<-EOT
    disable:
      - traefik
      - servicelb
    cluster-cidr: 10.42.0.0/16
    service-cidr: 10.43.0.0/16
  EOT
}
```

### Private Network Only

```hcl
resource "hcloud_network" "k3s" {
  name     = "k3s-network"
  ip_range = "10.0.0.0/16"
}

module "k3s" {
  source = "./modules/k3s-cluster"

  # ... other config ...

  network_id = hcloud_network.k3s.id
  public_net = false  # Private only
}
```

## Getting kubeconfig

After deployment, retrieve the kubeconfig:

```bash
# Get command from output
terraform output -raw kubeconfig_command

# Execute to get kubeconfig
ssh core@<server-ip> sudo cat /etc/rancher/k3s/k3s.yaml > kubeconfig.yaml

# Update server address to load balancer IP
LB_IP=$(terraform output -raw load_balancer_ipv4)
sed -i "s|https://.*:6443|https://${LB_IP}:6443|" kubeconfig.yaml

# Test
kubectl --kubeconfig=kubeconfig.yaml get nodes
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_ct"></a> [ct](#requirement\_ct) | ~> 0.13 |
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | ~> 1.45 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | n/a |
| <a name="provider_ct"></a> [ct](#provider\_ct) | ~> 0.13 |
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | ~> 1.45 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_k3s_servers"></a> [k3s\_servers](#module\_k3s\_servers) | ../flatcar-server | n/a |

## Resources

| Name | Type |
|------|------|
| [cloudflare_dns_record.lb_a](https://registry.terraform.io/providers/hashicorp/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_dns_record.lb_aaaa](https://registry.terraform.io/providers/hashicorp/cloudflare/latest/docs/resources/dns_record) | resource |
| [hcloud_load_balancer.k3s_lb](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer) | resource |
| [hcloud_load_balancer_service.http](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_service.https](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_service.k3s_api](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_service) | resource |
| [hcloud_load_balancer_target.k3s_servers](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/load_balancer_target) | resource |
| [random_password.k3s_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [cloudflare_zone.lb_zone](https://registry.terraform.io/providers/hashicorp/cloudflare/latest/docs/data-sources/zone) | data source |
| [ct_config.k3s_server](https://registry.terraform.io/providers/poseidon/ct/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_arch"></a> [arch](#input\_arch) | CPU architecture (amd64 or arm64) | `string` | `"amd64"` | no |
| <a name="input_backups"></a> [backups](#input\_backups) | Enable backups | `bool` | `false` | no |
| <a name="input_cloudflare_domain"></a> [cloudflare\_domain](#input\_cloudflare\_domain) | Cloudflare domain for DNS records | `string` | `""` | no |
| <a name="input_cloudflare_enabled"></a> [cloudflare\_enabled](#input\_cloudflare\_enabled) | Enable Cloudflare DNS integration | `bool` | `false` | no |
| <a name="input_cluster_init"></a> [cluster\_init](#input\_cluster\_init) | Initialize a new cluster (first server only) | `bool` | `true` | no |
| <a name="input_cluster_init_server"></a> [cluster\_init\_server](#input\_cluster\_init\_server) | Address of the first server to join (required if cluster\_init is false) | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the K3s cluster (used for labels) | `string` | `"main"` | no |
| <a name="input_ct_strict"></a> [ct\_strict](#input\_ct\_strict) | Strict mode for ct config transpiler | `bool` | `true` | no |
| <a name="input_dns_domain"></a> [dns\_domain](#input\_dns\_domain) | DNS domain to append to instance names | `string` | n/a | yes |
| <a name="input_firewall_allow_ssh"></a> [firewall\_allow\_ssh](#input\_firewall\_allow\_ssh) | Allow SSH access through firewall | `bool` | `true` | no |
| <a name="input_firewall_allowed_ports"></a> [firewall\_allowed\_ports](#input\_firewall\_allowed\_ports) | Additional TCP ports to allow through firewall | `list(number)` | <pre>[<br/>  80,<br/>  443<br/>]</pre> | no |
| <a name="input_firewall_enabled"></a> [firewall\_enabled](#input\_firewall\_enabled) | Enable firewall for the servers | `bool` | `true` | no |
| <a name="input_firewall_k3s_api_sources"></a> [firewall\_k3s\_api\_sources](#input\_firewall\_k3s\_api\_sources) | Source IP ranges allowed for K3s API (port 6443) | `list(string)` | <pre>[<br/>  "0.0.0.0/0",<br/>  "::/0"<br/>]</pre> | no |
| <a name="input_firewall_ssh_sources"></a> [firewall\_ssh\_sources](#input\_firewall\_ssh\_sources) | Source IP ranges allowed for SSH | `list(string)` | <pre>[<br/>  "0.0.0.0/0",<br/>  "::/0"<br/>]</pre> | no |
| <a name="input_k3s_config"></a> [k3s\_config](#input\_k3s\_config) | Additional K3s config.yaml content | `string` | `""` | no |
| <a name="input_keep_disk"></a> [keep\_disk](#input\_keep\_disk) | Don't upgrade disk (allows downgrading) | `bool` | `true` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Additional labels to apply | `map(string)` | `{}` | no |
| <a name="input_load_balancer_dns_name"></a> [load\_balancer\_dns\_name](#input\_load\_balancer\_dns\_name) | DNS name for load balancer (e.g., 'k3s-lb' or 'k3s-lb.example.com') | `string` | `""` | no |
| <a name="input_load_balancer_enabled"></a> [load\_balancer\_enabled](#input\_load\_balancer\_enabled) | Enable load balancer in front of K3s servers | `bool` | `true` | no |
| <a name="input_load_balancer_expose_k3s_api"></a> [load\_balancer\_expose\_k3s\_api](#input\_load\_balancer\_expose\_k3s\_api) | Expose K3s API (port 6443) through load balancer | `bool` | `true` | no |
| <a name="input_load_balancer_services"></a> [load\_balancer\_services](#input\_load\_balancer\_services) | Services to expose on load balancer (http, https) | `list(string)` | <pre>[<br/>  "http",<br/>  "https"<br/>]</pre> | no |
| <a name="input_load_balancer_type"></a> [load\_balancer\_type](#input\_load\_balancer\_type) | Hetzner Cloud load balancer type | `string` | `"lb11"` | no |
| <a name="input_location"></a> [location](#input\_location) | Hetzner Cloud location | `string` | `"nbg1"` | no |
| <a name="input_name"></a> [name](#input\_name) | Base name for K3s servers (without domain) | `string` | n/a | yes |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | Network ID to attach servers to (optional) | `number` | `null` | no |
| <a name="input_public_net"></a> [public\_net](#input\_public\_net) | Enable public network interface | `bool` | `true` | no |
| <a name="input_server_count"></a> [server\_count](#input\_server\_count) | Number of K3s server nodes | `number` | `3` | no |
| <a name="input_server_type"></a> [server\_type](#input\_server\_type) | Hetzner Cloud instance type for servers | `string` | `"cx32"` | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | SSH key IDs or names to inject | `list(string)` | `[]` | no |
| <a name="input_ssh_public_keys"></a> [ssh\_public\_keys](#input\_ssh\_public\_keys) | SSH public keys to add to Ignition config | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_id"></a> [firewall\_id](#output\_firewall\_id) | Firewall ID (if enabled) |
| <a name="output_k3s_token"></a> [k3s\_token](#output\_k3s\_token) | K3s cluster token (sensitive) |
| <a name="output_kubeconfig_command"></a> [kubeconfig\_command](#output\_kubeconfig\_command) | Command to retrieve kubeconfig from first server |
| <a name="output_load_balancer_dns_name"></a> [load\_balancer\_dns\_name](#output\_load\_balancer\_dns\_name) | Load balancer DNS name (if configured) |
| <a name="output_load_balancer_id"></a> [load\_balancer\_id](#output\_load\_balancer\_id) | Load balancer ID (if enabled) |
| <a name="output_load_balancer_ipv4"></a> [load\_balancer\_ipv4](#output\_load\_balancer\_ipv4) | Load balancer IPv4 address (if enabled) |
| <a name="output_load_balancer_ipv6"></a> [load\_balancer\_ipv6](#output\_load\_balancer\_ipv6) | Load balancer IPv6 address (if enabled) |
| <a name="output_server_ids"></a> [server\_ids](#output\_server\_ids) | List of K3s server IDs |
| <a name="output_server_ipv4_addresses"></a> [server\_ipv4\_addresses](#output\_server\_ipv4\_addresses) | List of K3s server IPv4 addresses |
| <a name="output_server_ipv6_addresses"></a> [server\_ipv6\_addresses](#output\_server\_ipv6\_addresses) | List of K3s server IPv6 addresses |
| <a name="output_server_names"></a> [server\_names](#output\_server\_names) | List of K3s server FQDNs |
