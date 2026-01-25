terraform {
  required_version = ">= 1.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
    ct = {
      source  = "poseidon/ct"
      version = "~> 0.13"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  # Cloudflare provider is optional
  # Only configure if cloudflare_enabled = true
  provider_meta "cloudflare" {
    skip_credentials_validation = true
  }
}
