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

  }
}

# Authenticate to the local cluster using your windows kubeconfig
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop" # Change this if using minikube or kind
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "docker-desktop"
  }
}