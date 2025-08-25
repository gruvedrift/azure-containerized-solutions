## Business Context
**Scenario**: You have a containerized application that needs to run continuously in the cloud with minimal management overhead. It's a simple service that doesn't need orchestration or scaling - like a data processing job or internal tool.

**What This Solves**:
- Quick deployment of containerized applications without managing VMs
- Ideal for dev/test environments or simple production workloads
- Pay-per-second billing for actual resource usage
- Built-in monitoring and health checks without additional setup

## Technical Implementation
This iteration demonstrates provisioning:
- **Azure Resource Group**
- **Azure Container Registry**
- **Azure Container Instance** (single container deployment)

## Key Features Implemented
- Admin credential authentication (demonstration only - not production-safe)
- Docker image build, tag, and push workflow to ACR
- Terraform output variables passed to deployment scripts
- Health and liveness probing for container reliability
- Environment variable injection from infrastructure to application