# Containerized solutions:

This project was created as a **hands-on practice** resource for preparing for the AZ-204 exam.
It demonstrates how to build, package, and deploy containerized applications using various Azure Compute services while following real-world DevOps practices.
This project contains three iterations of containerized solutions with Azure Compute.
I have also added a `COMMANDS.md` file with relevant Azure CLI commands for Azure Containerized solutions.
For further learning, a selection of relevant questions and answers are provided.

#### Each iteration contains:
- A terraform configuration for provisioning resources on Azure.
- A small python application with necessary code / functionality for testing / verifying the provisioned resources.
- A `Dockerfile` for building and pushing an application image to cloud.
- A set of scripts for automatization.
- A `README.md` file with extra information.

## First iteration overview:
- How to set up the necessary resources and in which order to create and publish a container image to Azure Container Registry.

## Second iteration overview: 
- Everything from First iteration.
- Instantiate an Azure Container Group (Azure Container Instance) for running the containerized application uploaded to an ACR.
- Use of environment variables through Terraform -> Application.
- How to enable basic Health and Liveness probing with Azure and in-code endpoints.

## Third iteration overview:
- Everything from Second Iteration.
- How to provision and deploy an application to Azure Container Apps.
- How to configure external ingress for public access.
- How to implement HTTP-based auto-scaling rules. 
- How to test and verify scaling under simulated load.
- How to Create and manage Revisions.
- How to configure traffic splitting between revisions through the Azure CLI.


## Essential notes on Azure Containerized Solutions:

### Azure Container Registry SKUs

| Feature               | Basic | Standard | Premium |
|-----------------------|-------|----------|---------|
| Storage               | 10 GB | 100 GB   | 500 GB  |
| Webhooks              | ❌     | ✅        | ✅       |
| Geo-replication       | ❌     | ❌        | ✅       |
| Content trust         | ❌     | ❌        | ✅       |
| Private endpoints     | ❌     | ❌        | ✅       |
| Customer-managed keys | ❌     | ❌        | ✅       |

**Exam Tip**: Premium is the only SKU supporting geo-replication and content trust

### ACR Authentication Options

1. **Admin Account** (not recommended for production)
    - `az acr update --admin-enabled true`
    - Simple username/password

2. **Service Principal** (CI/CD scenarios)
    - `az ad sp create-for-rbac --name myapp --role acrpush`
    - Granular RBAC permissions

3. **Managed Identity** (recommended for Azure services)
    - System-assigned or user-assigned
    - No credential management needed

4. **Repository-scoped Tokens** (fine-grained access)
    - Scope to specific repositories
    - Time-limited access

**Exam Tip**: Know when to use each method

### Azure Container Apps
- The combination of CPU and memory are allways 1:2, so:
```bash
[cpu: 0.25, memory: 0.5Gi]
[cpu: 0.5, memory: 1.0Gi] 
[cpu: 0.75, memory: 1.5Gi]
# And so on ...
```

### Questions and Answers for relevant topics within Containerized Solutions scope:

>**Question 1:** Which Container Registry SKU supports content trust and private endpoints?  
**Answer 1:** Premium SKU. Basic and Standard SKUs do not support content trust (image signing) or private link connectivity.
---
>**Question 2:** What happens to Container Apps revisions when you deploy updates?  
**Answer 2:** Container Apps creates a new revision for each deployment while maintaining previous revisions. You can configure traffic splitting between revisions and keep multiple revisions active simultaneously for A/B testing or gradual rollouts.
---
>**Question 3:** Your Container Instance fails to start with an "ImagePullBackOff" error. What are the most likely causes?  
**Answer 3:** Authentication issues with the container registry (incorrect credentials), the specified image doesn't exist or has wrong tag, network connectivity issues preventing access to the registry, or insufficient permissions on the registry.
---
>**Question 4:** What is the maximum number of images you can store in a Basic SKU Container Registry?  
**Answer 4:** Basic SKU provides 10 GB of storage. There's no hard limit on the number of images, but you're limited by the total storage capacity.
---
>**Question 5:** You need to automatically build and push container images when code is committed to your Git repository. Which Azure service should you use?  
**Answer 5:** Azure Container Registry Tasks (ACR Tasks). Use `az acr task create` to set up automated builds triggered by Git commits.
---
>**Question 6:** What's the difference between Container Instances and Container Apps regarding scaling?  
**Answer 6:** Container Instances are single containers that don't auto-scale – you manually specify CPU and memory. Container Apps provide automatic scaling based on HTTP traffic, CPU usage, or custom metrics, and can scale to zero.
---
>**Question 7:** You're deploying a Container App that needs access to a virtual network. Which configuration is required?  
**Answer 7:** Create a Container Apps Environment with VNet integration enabled. Container Apps inherit the network configuration from their environment, and individual apps cannot override this setting.
---
>**Question 8:** How do you configure traffic splitting between revisions in Container Apps?  
**Answer 8:** Use the `--traffic-weights` parameter in `az containerapp update` or configure it in the portal. You can split traffic by percentage (e.g., 80% to revision-1, 20% to revision-2) for canary deployments.
---
>**Question 9:** Your Container Instance needs to access Azure Key Vault securely. How should you configure authentication?  
**Answer 9:** Enable system-assigned managed identity on the Container Instance and grant the identity appropriate permissions in Key Vault. Container Instances can use managed identity for authentication.
---
>**Question 10:** What's the purpose of webhooks in Container Registry?  
**Answer 10:** Webhooks trigger automated actions when events occur in your registry, such as when images are pushed or deleted. Common use cases include triggering CI/CD pipelines or updating deployed applications.
---
>**Question 11:** You need to replicate container images across multiple Azure regions. Which Container Registry feature should you use?  
**Answer 11:** Geo-replication (Premium SKU only). This automatically replicates images to multiple regions, reducing latency for global deployments and providing disaster recovery capabilities.
---
>**Question 12:** How do you run a Container Instance that executes once and terminates?  
**Answer 12:** Set the restart policy to "Never" using `--restart-policy Never`. This is ideal for batch jobs or one-time tasks that shouldn't restart automatically upon completion.
---
>**Question 13:** You're using Container Apps and want to ensure zero-downtime deployments. What strategy should you implement?  
**Answer 13:** Use revision management with traffic splitting. Deploy to a new revision, gradually shift traffic from the old revision to the new one, and keep the old revision available for instant rollback if needed.
---
>**Question 14:** What authentication method does Container Registry support for automated scenarios?  
**Answer 14:** Service principals, managed identities, and repository-scoped tokens. For CI/CD pipelines, prefer managed identities or repository-scoped tokens for enhanced security and limited scope.
---
>**Question 15:** Your Container Instance needs persistent storage that survives container restarts. What options are available?  
**Answer 15:** Mount Azure Files shares or Azure Disk volumes. Azure Files provides shared storage accessible from multiple containers, while Azure Disk provides dedicated storage for single container scenarios.
---
>**Question 16:** How do you configure a Container App to scale based on HTTP queue length?  
**Answer 16:** Use HTTP scaling rules in the Container App configuration. Set `--min-replicas` and `--max-replicas`, then configure `--scale-rule-http-concurrency` to define the concurrent requests per replica threshold.
---
>**Question 17:** You need to scan container images for vulnerabilities before deployment. Which Container Registry feature should you enable?  
**Answer 17:** Microsoft Defender for container registries (formerly Azure Security Center integration). This automatically scans images for vulnerabilities and provides detailed security reports.
---
>**Question 18:** What's the maximum execution time for Container Instances?  
**Answer 18:** Container Instances don't have a maximum execution time limit. They run until the process completes, fails, or you manually stop them. You're charged for the entire execution duration.
---
>**Question 19:** How do you configure custom domains for Container Apps?  
**Answer 19:** Enable custom domains in the Container Apps Environment, then configure DNS mapping and TLS certificates. The custom domain applies to all apps within that environment.
---
>**Question 20:** Your container needs different environment variables for development and production. How should you manage this with Container Registry and Container Instances?  
**Answer 20:** Store the same image in Container Registry but use different environment variables when creating Container Instances via `--environment-variables` parameter. Keep secrets in Key Vault and reference them through managed identity.
---
