# Azure provider for configuring infrastructure in Microsoft Azure, using the Azure Resource Manager APIs.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the AzureRM provider
provider "azurerm" {
  # The features block allows for changing the behaviour of the AzureRM.
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "tiny-flask" {
  name     = "tiny-flask-resource-group"
  location = "West Europe"
}

# Create ACR - Azure Container Registry
resource "azurerm_container_registry" "tiny-flask" {
  name                = "tinyflaskcontainerregistry"
  resource_group_name = azurerm_resource_group.tiny-flask.name
  location            = azurerm_resource_group.tiny-flask.location
  sku                 = "Basic"
  admin_enabled       = "true" # Need this for authentication through Username / Password in the ACI step
}