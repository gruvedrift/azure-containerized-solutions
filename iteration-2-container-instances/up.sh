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

echo "=== Stage 2: Building and Pushing Container Image ==="
# Obtain ACR details from Terraform output
ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server)
ACR_NAME=$(terraform output -raw acr_name)

echo "Logging into Azure Container Registry..."
az acr login --name $ACR_NAME

echo "Building Docker image..."
cd ../src
# Build specifically for AMD64/x86_64 architecture (used by Azure Container Instances)
docker build --platform linux/amd64 -t $ACR_LOGIN_SERVER/tiny-flask-image:latest .

echo "Pushing Docker image to registry..."
docker push $ACR_LOGIN_SERVER/tiny-flask-image:latest

echo "=== Stage 3: Deploying Container Instance ==="
cd ../terraform
terraform apply -target=azurerm_container_group.tiny-flask -auto-approve

echo "=== Deployment Complete ==="
echo "Your application is accessible at:"
echo "IP Address: http://$(terraform output -raw container_group_ip_address):5000"
echo "Friendly URL: http://$(terraform output -raw container_group_fqdn):5000"