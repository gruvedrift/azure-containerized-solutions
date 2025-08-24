#!/bin/bash

# Exit on error
set -e

echo "=== Stage 1: Provisioning Core Infrastructure ==="
cd ./terraform
terraform init
terraform fmt
terraform validate

# Apply Azure Resource Group and Azure Container Registry
echo "Creating resource group and ACR... "
terraform apply -target=azurerm_resource_group.tiny-flask -target=azurerm_container_registry.tiny-flask -auto-approve