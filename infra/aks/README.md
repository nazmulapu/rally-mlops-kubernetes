# AKS Infrastructure

Terraform configuration for Azure Kubernetes Service deployment.

## Prerequisites

- Azure CLI (`az` command)
- Terraform >= 1.0
- Valid Azure subscription

## Configuration

1. Set Azure subscription:
   ```bash
   az login
   az account set --subscription <SUBSCRIPTION_ID>
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review and apply:
   ```bash
   terraform plan
   terraform apply
   ```

## Resources Created

- AKS cluster with system and spot node pools
- Azure Container Registry
- Blob Storage containers (raw/, labels/, features/)
- Key Vault for secrets
- Virtual Network and subnets
- Managed identities for workload authentication

## Cleanup

```bash
terraform destroy
```

## Notes

- Spot instances reduce costs by ~70% for worker pools
- System node pool runs control plane components
- Key Vault integrates with Kubernetes via Secret Store CSI driver
