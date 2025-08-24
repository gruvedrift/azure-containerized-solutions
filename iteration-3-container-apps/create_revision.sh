#!/bin/bash

set -e


# Configurations, SWÆÆP with your variables...
RESOURCE_GROUP="tiny-flask-resource-group"
CONTAINER_APP_NAME="tiny-flask-container-app"
ACR_NAME="tinyflaskcontainerregistry"
APP_NAME="tiny-flask-image"
FIRST_VERSION="v1"
NEW_VERSION="${1:-v2}" # Default to version v2

echo "=== Building and Pushing Version $NEW_VERSION ==="

# Get the login server
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --query loginServer -o tsv)

# Build and push a new image with v2 tag
echo "Building Docker image with tag $NEW_VERSION..."
docker build --platform linux/amd64 -t $ACR_LOGIN_SERVER/tiny-flask-image:$NEW_VERSION ./src

echo "Pushing docker  image..."
az acr login --name $ACR_NAME
docker push $ACR_LOGIN_SERVER/$APP_NAME:$NEW_VERSION


echo "=== Creating New Revision: $NEW_VERSION..."

# Create a new revision with Azure CLI
az containerapp update \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --image $ACR_LOGIN_SERVER/$APP_NAME:$NEW_VERSION \
  --revision-suffix $NEW_VERSION \
  --set-env-vars \
    APP_VERSION="2.0.0" \
    FEATURE_FLAG="New Experience" \
    AUTHOR="Duke Leto Atreides" \
    QUOTE="Without change, something sleeps inside us, and seldom awakens."

echo "=== Setting Up Traffic Split (80/20) ==="

az containerapp ingress traffic set \
  --name $CONTAINER_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --revision-weight $CONTAINER_APP_NAME--$FIRST_VERSION=80 $CONTAINER_APP_NAME--$NEW_VERSION=20

