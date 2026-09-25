terraform {

  required_version = ">= 1.9"

  required_providers {

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

    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.8"
    }

  }
}

# Authenticate to the local cluster using your windows kubeconfig
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop" # Change this if using minikube or kind
}

provider "kubectl" {
  config_path = "~/.kube/config"
  config_context = "docker-desktop"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "docker-desktop"
  }
}
