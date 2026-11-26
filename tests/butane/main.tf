# Offline render test for all Butane configs in this repository.
#
# Transpiles every Butane config with the ct provider in strict mode
# (warnings are errors). It needs no cloud credentials and creates no
# resources: run `terraform init && terraform plan` in this directory.

terraform {
  required_version = ">= 1.0"

  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "~> 0.14"
    }
  }
}

locals {
  ssh_public_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBr7e7yzLy8yOq0bcJkbL0F2Z2V2c8S5wG3dQ0Yb0m3o test@example.com"]

  volumes = [
    { name = "data", size = 10, mount_path = "/var/mnt/data" },
    { name = "logs", size = 10, mount_path = "/var/mnt/logs" },
  ]

  # Plain Butane configs (no template variables)
  static_configs = fileset("${path.module}/../../examples", "*.yaml")

  # Butane templates rendered by the Terraform examples and modules
  templates = {
    "flatcar-single"    = templatefile("${path.module}/../../terraform/examples/flatcar-single/config.yaml", { ssh_public_keys = local.ssh_public_keys, volumes = local.volumes })
    "flatcar-container" = templatefile("${path.module}/../../terraform/examples/flatcar-container/config.yaml", { ssh_public_keys = local.ssh_public_keys, volumes = local.volumes })
    "k3s-single"        = templatefile("${path.module}/../../terraform/examples/k3s-single/config.yaml", { ssh_public_keys = local.ssh_public_keys, volumes = local.volumes })
    "k3s-server-init" = templatefile("${path.module}/../../terraform/modules/k3s-cluster/templates/k3s-server.yaml", {
      ssh_public_keys = local.ssh_public_keys
      volumes         = local.volumes
      k3s_token       = "test-token"
      install_exec    = "--cluster-init"
      k3s_config      = ""
    })
    "k3s-server-join" = templatefile("${path.module}/../../terraform/modules/k3s-cluster/templates/k3s-server.yaml", {
      ssh_public_keys = local.ssh_public_keys
      volumes         = []
      k3s_token       = "test-token"
      install_exec    = "--server https://10.0.0.2:6443"
      k3s_config      = "write-kubeconfig-mode: \"0644\""
    })
  }
}

data "ct_config" "static" {
  for_each = local.static_configs
  content  = file("${path.module}/../../examples/${each.value}")
  strict   = true
}

data "ct_config" "template" {
  for_each = local.templates
  content  = each.value
  strict   = true
}

output "ignition_sha256" {
  description = "SHA-256 of every rendered Ignition config"
  value = merge(
    { for k, v in data.ct_config.static : "examples/${k}" => sha256(v.rendered) },
    { for k, v in data.ct_config.template : k => sha256(v.rendered) },
  )
}
