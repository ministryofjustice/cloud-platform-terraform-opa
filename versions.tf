terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.12.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.1"
    }
  }
  required_version = ">= 1.2.5"
}
