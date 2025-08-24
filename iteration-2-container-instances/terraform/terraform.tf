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


# Create ACI - Azure Container Instance from registry
resource "azurerm_container_group" "tiny-flask" {
  location            = azurerm_resource_group.tiny-flask.location
  resource_group_name = azurerm_resource_group.tiny-flask.name
  name                = "tinyflaskcontainerinstance"
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = "tinyflaskdns"


  # In order for ACI to  pull an image from the ACR, we need to provide credentials:
  image_registry_credential {
    password = azurerm_container_registry.tiny-flask.admin_password
    server   = azurerm_container_registry.tiny-flask.login_server
    username = azurerm_container_registry.tiny-flask.admin_username
  }

  container {
    cpu    = 1
    image  = "${azurerm_container_registry.tiny-flask.login_server}/tiny-flask-image:latest"
    memory = 2
    name   = "tinyflaskcontainer"

    ports {
      port     = 5000
      protocol = "TCP"
    }

    environment_variables = {
      AUTHOR = "Frank Herbert"
    }

    # Check if container should be restarted
    liveness_probe {
      http_get {
        path = "/health"
        port = 5000
      }
      initial_delay_seconds = 30
      period_seconds        = 30
      timeout_seconds       = 5
      failure_threshold     = 3
    }

    # Check if container is ready for traffic
    readiness_probe {
      http_get {
        path = "/health"
        port = 5000
      }
      initial_delay_seconds = 10
      period_seconds        = 10
      timeout_seconds       = 3
      failure_threshold     = 2
    }
  }
}

# Store outputs into variables for use in wrapping up.sh script
output "acr_login_server" {
  description = "Login server URL for the container registry"
  value       = azurerm_container_registry.tiny-flask.login_server
}

output "acr_name" {
  description = "Name of the container registry"
  value       = azurerm_container_registry.tiny-flask.name
}

output "container_group_ip_address" {
  description = "Public IP of the container group"
  value       = azurerm_container_group.tiny-flask.ip_address
}

output "container_group_fqdn" {
  description = "Fully qualified domain name of the container group"
  value       = azurerm_container_group.tiny-flask.fqdn
}
