## Business Context
**Scenario**: Your e-commerce application experiences variable traffic - quiet during nights, moderate during days, and massive spikes during sales events. You need zero-downtime deployments and the ability to test new features with a subset of users before full rollout.

**What This Solves**:
- Automatic scaling based on actual HTTP traffic (not just CPU/memory)
- Zero-downtime deployments through revision management
- A/B testing and canary deployments via traffic splitting
- Cost optimization through scale-to-zero capabilities
- Built-in HTTPS and custom domain support

## Technical Implementation
This iteration demonstrates:
- **Azure Container Apps Environment setup**
- **HTTP-based auto-scaling  configuration**
- **Multiple revision management**
- **Traffic splitting between versions**
- **Hybrid IaC + CLI operational model**

## Key Features Implemented
- Automatic scaling from 1-5 replicas based on concurrent requests
- Blue-green and canary deployment patterns
- Real-time traffic management without redeployment
- Instance-aware application for visualizing scaling
- Terraform lifecycle management for operational flexibility

## Architectural Decisions
- **Why Multiple Revisions**: Enables instant rollback and gradual rollouts
- **Why Hybrid Approach**: Infrastructure stability (Terraform) + operational agility (CLI)
- **Why HTTP Scaling**: More responsive to actual user experience than CPU metrics

## Key Learning Outcomes
- Implementing production-grade deployment strategies
- Understanding revision immutability and traffic management
- Balancing infrastructure-as-code with operational requirements
- Troubleshooting scaling and traffic routing issues


## How to test auto scaling:

1) Run the `up.sh` script, this will provision the "static" infrastructure.
2) Run the `concurrent_request.sh` to simulate concurrent requests. This is to test auto-scaling behaviour. 
3) While the script is running its requests, paste the container app URL into your browser. Hit the refresh button a couple of times. You should see the `HOSTNAME` variable change.
4) You can inspect the replica counts in the `Metrics` section within the `Container App`

## Note on  revisions
A revision in Azure Container Apps is an immutable snapshot of an application configuration. That is, the container image, environment variables, scaling rules and resource allocations. 
When updating the Container App, instead of replacing the running version, a new revision is created, and Azure lets you control how traffic flows between them. 

### Hybrid approach to Devops 
This approach separates infrastructure concerns (Terraform's strength) from operational concerns (where CLI/scripts excel). 
This is a pattern called "Infrastructure as Code + GitOps".

### Ignore dynamic changes to Terraform state

```terraform
lifecycle {
    ignore_changes = [
      ingress[0].traffic_weight
    ]
  }
```
The ignore_changes argument within the lifecycle block in Terraform allows you to specify certain attributes of a resource that Terraform should disregard when comparing the desired state (defined in your configuration) with the actual state of the infrastructure.
Purpose:
Preventing unwanted updates:
If an attribute of a resource is frequently modified outside of Terraform (e.g., manually in the cloud console, by an external automation tool, or by a cloud policy), ignore_changes prevents Terraform from trying to revert those changes on subsequent terraform apply operations.

## How to test revisions: 
1) In order to test revisions, add the necessary variables to the `create_revision.sh` script, and run it.
2) After the revision is finished, the traffic weight should be 80 - 20 between OLD and NEW revision. 
Run the `test_revision.sh` script to verify that traffic is routed accordingly between the revisions. 
You can also at any time re-adjust the weight with the following `AZ CLI command`:
```bash
az containerapp ingress traffic set \
    --name tiny-flask-container-app \
    --resource-group tiny-flask-resource-group \
    --revision-weight tiny-flask-container-app--v1=50 \
                      tiny-flask-container-app--v2=50   # 50-50 split between revisions
```