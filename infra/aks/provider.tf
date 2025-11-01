terraform {
  cloud {
    organization = "nazmulapu-labs"

    workspaces {
      name = "rally-mlops-kubernetes"
    }
  }

  # Working directory should be set in Terraform Cloud workspace settings
  # to point to infra/aks for proper module resolution

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = "~> 1.13"
}

provider "azurerm" {
  features {}
}
