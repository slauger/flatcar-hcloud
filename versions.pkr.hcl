packer {
  required_version = ">= 1.7.0"

  required_plugins {
    hcloud = {
      source = "github.com/hetznercloud/hcloud"
      # renovate: datasource=github-releases depName=hetznercloud/packer-plugin-hcloud
      version = "~> 1.6"
    }
  }
}
