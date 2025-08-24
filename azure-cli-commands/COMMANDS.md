
## Reference guide to provisioning resources through Azure CLI.


### Create a resource group for our container resources
```bash
az group create --name rg-containers-learn --location eastus
```

### Create an Azure Container Registry
```bash
az acr create --resource-group rg-containers-learn --name acrlearning2024 --sku Basic
```

###  Build and push an image to the registry (this builds from local Dockerfile)
```bash
az acr build --registry acrlearning2024 --image sample-app:v1 .
```

### Create a container instance from our registry
```bash
az container create \
--resource-group rg-containers-learn \
--name sample-container \
--image acrlearning2024.azurecr.io/sample-app:v1 \
--cpu 1 --memory 1 \
--registry-login-server acrlearning2024.azurecr.io \
--registry-username acrlearning2024 \
--registry-password $(az acr credential show --name acrlearning2024 --query "passwords[0].value" -o tsv)
```
### Create a Container Apps environment
```bash
az containerapp env create \
--name containerapp-env \
--resource-group rg-containers-learn \
--location eastus
```

### Deploy an application to Container Apps
```bash
az containerapp create \
--name my-container-app \
--resource-group rg-containers-learn \
--environment containerapp-env \
--image acrlearning2024.azurecr.io/sample-app:v1 \
--target-port 80 \
--ingress external
```


### Valuable commands for debugging Network and connectivity: 
- `curl -v $ip` Will test HTTP request 
- Container logs: ` az container logs --resource-group tiny-flask-resource-group --name tinyflaskcontainerinstance`