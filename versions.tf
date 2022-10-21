terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~>1.35.2"

    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0.3"
    }
  }
}