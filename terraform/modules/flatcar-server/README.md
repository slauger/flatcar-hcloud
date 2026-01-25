# Flatcar Server Module

Terraform module for deploying Flatcar Container Linux servers on Hetzner Cloud.

## Features

- Automatic Flatcar image selection (amd64/arm64)
- Integrated firewall with configurable rules
- Optional Cloudflare DNS integration
- Optional volume attachment
- Private network support
- Multiple instance deployment

## Usage

### Basic Example

```hcl
module "webserver" {
  source = "./modules/flatcar-server"

  name            = "web"
  dns_domain      = "example.com"
  server_type     = "cx23"
  location        = "nbg1"

  ignition_config = data.ct_config.basic.rendered
  ssh_keys        = ["your-ssh-key-name"]

  # Firewall
  firewall_enabled       = true
  firewall_allowed_ports = [80, 443]
}
```

### With Cloudflare DNS

```hcl
module "webserver" {
  source = "./modules/flatcar-server"

  name       = "web"
  dns_domain = "example.com"

  # ... other config ...

  cloudflare_enabled = true
  cloudflare_domain  = "example.com"
}
```

### With Volume

```hcl
module "webserver" {
  source = "./modules/flatcar-server"

  name       = "web"
  dns_domain = "example.com"

  # ... other config ...

  volume        = true
  volume_size   = 50
  volume_format = "ext4"
}
```

### Multiple Instances

```hcl
module "workers" {
  source = "./modules/flatcar-server"

  name           = "worker"
  dns_domain     = "example.com"
  instance_count = 3

  # ... other config ...
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_hcloud"></a> [hcloud](#requirement\_hcloud) | ~> 1.45 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | n/a |
| <a name="provider_hcloud"></a> [hcloud](#provider\_hcloud) | ~> 1.45 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudflare_dns_record.dns-a](https://registry.terraform.io/providers/hashicorp/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_dns_record.dns-aaaa](https://registry.terraform.io/providers/hashicorp/cloudflare/latest/docs/resources/dns_record) | resource |
| [hcloud_firewall.firewall](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall) | resource |
| [hcloud_firewall_attachment.firewall](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall_attachment) | resource |
| [hcloud_rdns.dns-ptr-ipv4](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/rdns) | resource |
| [hcloud_rdns.dns-ptr-ipv6](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/rdns) | resource |
| [hcloud_server.server](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/server) | resource |
| [hcloud_volume.volumes](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/volume) | resource |
| [cloudflare_zone.zone](https://registry.terraform.io/providers/hashicorp/cloudflare/latest/docs/data-sources/zone) | data source |
| [hcloud_image.flatcar](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/data-sources/image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_arch"></a> [arch](#input\_arch) | CPU architecture (amd64 or arm64) | `string` | `"amd64"` | no |
| <a name="input_backups"></a> [backups](#input\_backups) | Enable or disable backups | `bool` | `false` | no |
| <a name="input_cloudflare_domain"></a> [cloudflare\_domain](#input\_cloudflare\_domain) | Cloudflare domain for DNS records (only used if cloudflare\_enabled is true) | `string` | `""` | no |
| <a name="input_cloudflare_enabled"></a> [cloudflare\_enabled](#input\_cloudflare\_enabled) | Enable Cloudflare DNS integration | `bool` | `false` | no |
| <a name="input_dns_domain"></a> [dns\_domain](#input\_dns\_domain) | DNS domain to append to instance name | `string` | n/a | yes |
| <a name="input_dns_ttl"></a> [dns\_ttl](#input\_dns\_ttl) | TTL for DNS records | `number` | `1` | no |
| <a name="input_firewall_allow_ssh"></a> [firewall\_allow\_ssh](#input\_firewall\_allow\_ssh) | Allow SSH access through firewall | `bool` | `true` | no |
| <a name="input_firewall_allowed_ports"></a> [firewall\_allowed\_ports](#input\_firewall\_allowed\_ports) | List of TCP ports to allow through firewall (80, 443, 6443, etc.) | `list(number)` | <pre>[<br/>  80,<br/>  443<br/>]</pre> | no |
| <a name="input_firewall_allowed_udp_ports"></a> [firewall\_allowed\_udp\_ports](#input\_firewall\_allowed\_udp\_ports) | List of UDP ports to allow through firewall | `list(number)` | `[]` | no |
| <a name="input_firewall_enabled"></a> [firewall\_enabled](#input\_firewall\_enabled) | Enable firewall for the servers | `bool` | `true` | no |
| <a name="input_firewall_k3s_api_sources"></a> [firewall\_k3s\_api\_sources](#input\_firewall\_k3s\_api\_sources) | Source IP ranges allowed for K3s API (port 6443) | `list(string)` | <pre>[<br/>  "0.0.0.0/0",<br/>  "::/0"<br/>]</pre> | no |
| <a name="input_firewall_ssh_sources"></a> [firewall\_ssh\_sources](#input\_firewall\_ssh\_sources) | Source IP ranges allowed for SSH (only used if firewall\_allow\_ssh is true) | `list(string)` | <pre>[<br/>  "0.0.0.0/0",<br/>  "::/0"<br/>]</pre> | no |
| <a name="input_ignition_config"></a> [ignition\_config](#input\_ignition\_config) | Ignition config (JSON format) to use during server creation | `string` | n/a | yes |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of instances to deploy | `number` | `1` | no |
| <a name="input_keep_disk"></a> [keep\_disk](#input\_keep\_disk) | If true, do not upgrade the disk. This allows downgrading the server type later. | `bool` | `true` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Additional labels to apply to the server | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | The location name to create the server in (nbg1, fsn1, hel1, ash, hil) | `string` | `"nbg1"` | no |
| <a name="input_name"></a> [name](#input\_name) | Instance name (without domain) | `string` | n/a | yes |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | Network ID to attach server to (optional) | `number` | `null` | no |
| <a name="input_public_net"></a> [public\_net](#input\_public\_net) | Enable public network interface | `bool` | `true` | no |
| <a name="input_server_type"></a> [server\_type](#input\_server\_type) | Hetzner Cloud instance type | `string` | `"cx23"` | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | SSH key IDs or names which should be injected into the server at creation time | `list(string)` | `[]` | no |
| <a name="input_volume"></a> [volume](#input\_volume) | Enable or disable an additional volume | `bool` | `false` | no |
| <a name="input_volume_format"></a> [volume\_format](#input\_volume\_format) | Format of the volume (xfs or ext4) | `string` | `"ext4"` | no |
| <a name="input_volume_mount_path"></a> [volume\_mount\_path](#input\_volume\_mount\_path) | Mount path for the volume (configured via ignition) | `string` | `"/mnt/data"` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | Size of the additional data volume in GB | `number` | `20` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firewall_id"></a> [firewall\_id](#output\_firewall\_id) | ID of the firewall (if enabled) |
| <a name="output_image_id"></a> [image\_id](#output\_image\_id) | ID of the Flatcar image used |
| <a name="output_image_name"></a> [image\_name](#output\_image\_name) | Name of the Flatcar image used |
| <a name="output_ipv4_addresses"></a> [ipv4\_addresses](#output\_ipv4\_addresses) | List of IPv4 addresses |
| <a name="output_ipv6_addresses"></a> [ipv6\_addresses](#output\_ipv6\_addresses) | List of IPv6 addresses |
| <a name="output_ipv6_networks"></a> [ipv6\_networks](#output\_ipv6\_networks) | List of IPv6 network addresses |
| <a name="output_server_ids"></a> [server\_ids](#output\_server\_ids) | List of server IDs |
| <a name="output_server_names"></a> [server\_names](#output\_server\_names) | List of server FQDNs |
| <a name="output_volume_device_paths"></a> [volume\_device\_paths](#output\_volume\_device\_paths) | List of volume device paths (if volumes are enabled) |
| <a name="output_volume_ids"></a> [volume\_ids](#output\_volume\_ids) | List of volume IDs (if volumes are enabled) |
