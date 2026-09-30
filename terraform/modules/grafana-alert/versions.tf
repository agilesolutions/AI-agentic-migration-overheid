terraform {

  required_version = ">= 1.9"

  required_providers {

    grafana = {
      source  = "grafana/grafana"
      version = ">= 3.0.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 3.2"
    }

    helm = {
      source = "hashicorp/helm"
      version = "~> 2.14"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }

  }
}

provider "grafana" {
  url  = var.grafana_url
  auth = var.grafana_token
}