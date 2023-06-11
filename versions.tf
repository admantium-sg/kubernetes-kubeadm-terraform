terraform {
  required_version = ">= 1.4.6"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~>1.39.0"

    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0.4"
    }
  }
}