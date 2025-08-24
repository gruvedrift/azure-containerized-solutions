#!/bin/bash

# Exit on error
set -e

echo "=== Stage 1: Provisioning Core Infrastructure ==="
cd ./terraform
terraform init
terraform fmt
terraform validate

# Apply Azure Resource Group, Log Analytics Workspace and Container App Environment
echo "Creating resource group..."
terraform apply -target=azurerm_resource_group.tiny-flask \
                -target=azurerm_container_registry.tiny-flask \
                -target=azurerm_log_analytics_workspace.tiny-flask \
                -target=azurerm_container_app_environment.tiny-flask \
                -auto-approve

echo "=== Stage 2: Building and Pushing Container Image ==="

# Obtain ACR details from Terraform output
ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server)
ACR_NAME=$(terraform output -raw acr_name)

echo "Logging into Azure Container Registry..."
az acr login --name $ACR_NAME

echo "Building Docker image..."
cd ../src

# Build specifically for AMD64/x86_64 architecture (used by Azure Container Instances)
docker build --platform linux/amd64 -t $ACR_LOGIN_SERVER/tiny-flask-image:v1 .

echo "Pushing Docker image to registry..."
docker push $ACR_LOGIN_SERVER/tiny-flask-image:v1

echo "=== Stage 3: Deploy App to Azure Container Apps ==="
cd ../terraform
terraform apply -target=azurerm_container_app.tiny-flask -auto-approve

