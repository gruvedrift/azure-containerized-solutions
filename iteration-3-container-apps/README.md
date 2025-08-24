## This iteration simulates scaling with Azure Container Apps

1) Run the `up.sh` script 
2) Run the `concurrent_request.sh`. The container app url is already provided :)
3) While the script is running its requests, paste the container app URL into your browser. Hit the refresh button a couple of times. You should see the `HOSTNAME` variable change.
4) You can inspect the replica counts in the `Metrics` section within the `Container App`



## Configure revisions
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

In order to test revisions, add the neccessary variables to  the `create_revision.sh` script, and run it. 

After the revision is finished, the traffic weight should be 80 - 20 between OLD and NEW revision. 
Run the `test_revision.sh` script to verify that traffic is routed accordingly between the revisions. 
You can also at any time re-adjust the weight with the following `AZ CLI command`
```bash
az containerapp ingress traffic set \
    --name tiny-flask-container-app \
    --resource-group tiny-flask-resource-group \
    --revision-weight tiny-flask-container-app--v1=50 \
                      tiny-flask-container-app--v2=50   # 50-50 split between revisions
```