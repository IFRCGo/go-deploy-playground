terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.9"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.81"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.2"
    }
  }
}
