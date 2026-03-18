# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
  subscription_id = "****"
  tenant_id = "****"
}

resource "azurerm_resource_group" "rg" {
  name     = "myTFResourceGroup"
  location = var.location
}
