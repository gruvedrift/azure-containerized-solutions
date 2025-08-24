# Azure provider for configuring infrastructure in Microsoft Azure, using the Azure Resource Manager APIs.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.0.0"
    }
  }
}

# Configure the AzureRM provider
provider "azurerm" {
  # The features block allows for changing the behaviour of the AzureRM.
  features {}
  subscription_id = "8f9aed58-aa08-45bd-960a-2c15d4449132" # Needed after Terraform 4.0.0
}

# Create Resource Group
resource "azurerm_resource_group" "tiny-flask" {
  name     = "tiny-flask-resource-group"
  location = "West Europe"
}

# Create Azure Container Registry
resource "azurerm_container_registry" "tiny-flask" {
  name                = "tinyflaskcontainerregistry"
  location            = azurerm_resource_group.tiny-flask.location
  resource_group_name = azurerm_resource_group.tiny-flask.name
  sku                 = "Basic"
  admin_enabled       = "true"
}

# Create Log Analytics Workspace ( used for logging instances and follow traffic )
resource "azurerm_log_analytics_workspace" "tiny-flask" {
  name                = "tiny-flask-log-analytics-workspace"
  location            = azurerm_resource_group.tiny-flask.location
  resource_group_name = azurerm_resource_group.tiny-flask.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Create a Container Apps environment
resource "azurerm_container_app_environment" "tiny-flask" {
  name                       = "tiny-flask-app-environment"
  location                   = azurerm_resource_group.tiny-flask.location
  resource_group_name        = azurerm_resource_group.tiny-flask.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.tiny-flask.id
}

# Deploy an application to Container Apps
resource "azurerm_container_app" "tiny-flask" {
  name                         = "tiny-flask-container-app"
  container_app_environment_id = azurerm_container_app_environment.tiny-flask.id
  resource_group_name          = azurerm_resource_group.tiny-flask.name
  revision_mode                = "Multiple" # Enable multiple revisions

  ingress {
    external_enabled = "true" # Accessible from the internet
    target_port      = 5000   # Port Application is listening to

    traffic_weight {
      percentage      = 100
      latest_revision = true # Latest should receive 100% of traffic. Also, this is required on creation.
    }
  }

  # Store secret and give it a name reference
  secret {
    name  = "tinyflasksecret"
    value = azurerm_container_registry.tiny-flask.admin_password
  }

  # Authenticate with admin credentials
  registry {
    server               = azurerm_container_registry.tiny-flask.login_server
    username             = azurerm_container_registry.tiny-flask.admin_username
    password_secret_name = "tinyflasksecret"
  }

  template {
    # Define scaling behaviour
    min_replicas    = 1
    max_replicas    = 5
    revision_suffix = "v1"

    container {
      cpu    = 0.25
      image  = "${azurerm_container_registry.tiny-flask.login_server}/tiny-flask-image:v1"
      memory = "0.5Gi"
      name   = "tiny-flask-container-app"

      # Add environment variables
      env {
        name  = "APP_VERSION"
        value = "1.0.0"
      }
      env {
        name  = "AUTHOR"
        value = "Frank Herbert"
      }
      env {
        name  = "QUOTE"
        value = "The mystery of life isn't a problem to solve, but a reality to experience."
      }
    }

    # HTTP scaling rule for when to scale out
    http_scale_rule {
      name                = "tiny-flask-http-scaling"
      concurrent_requests = 10 # Scale out when any instance has more than 10 concurrent requests
    }
  }

  # Ignore changes made outside
  lifecycle {
    ignore_changes = [
      ingress[0].traffic_weight
    ]
  }
}