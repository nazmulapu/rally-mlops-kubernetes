# AKS Deployment Troubleshooting Guide

This document chronicles all issues encountered during the AKS cluster deployment and their solutions.

---

## Table of Contents

1. [Kubernetes Version Issues](#1-kubernetes-version-issues)
2. [VM Size Availability Problems](#2-vm-size-availability-problems)
3. [Regional vCPU Quota Exhaustion](#3-regional-vcpu-quota-exhaustion)
4. [Upgrade Settings Validation](#4-upgrade-settings-validation)
5. [Spot Instance Upgrade Restrictions](#5-spot-instance-upgrade-restrictions)
6. [Worker Pool Node Count Validation](#6-worker-pool-node-count-validation)
7. [Service Principal Permissions](#7-service-principal-permissions)

---

## 1. Kubernetes Version Issues

### Problem
```
Error: Kubernetes version 1.28 requires Premium tier LTS
```

**Root Cause:** Kubernetes version 1.28 entered Long-Term Support (LTS) status, which requires a Premium tier subscription.

### Solution
Updated to a newer non-LTS version:

**File:** `infra/aks/variables.tf`, `infra/aks/terraform.dev.tfvars`
```hcl
kubernetes_version = "1.31"  # Changed from "1.28"
```

**Lesson Learned:** Check Kubernetes version support status before selecting. Non-LTS versions (1.29, 1.30, 1.31) are available on standard tier.

---

## 2. VM Size Availability Problems

### Problem
```
Error: VMSizeNotSupported
Message: Virtual Machine size 'Standard_D2s_v6' is not supported for subscription in location 'westeurope'
```

**Root Cause:** VM SKU availability varies by:
- Subscription type
- Region
- Availability zones
- Current capacity

### Troubleshooting Steps

1. **Check available VM sizes in region:**
```bash
az vm list-skus --location westeurope --query "[?resourceType=='virtualMachines' && capabilities[?name=='vCPUs' && value=='2']][].name" -o table
```

2. **Filter by specific series:**
```bash
az vm list-skus --location westeurope --size Standard_D --query "[?contains(name, 'v5') && resourceType=='virtualMachines' && capabilities[?name=='vCPUs' && value=='2']].name" -o table
```

### Solution Attempted

**Attempt 1:** Standard_D2s_v6 → **Failed** (not available for subscription)
**Attempt 2:** Standard_D2s_v5 → **Success** (available in westeurope)
**Attempt 3:** Standard_D2s_v4 → **Failed** (capacity issues)
**Attempt 4:** Standard_D2ds_v5 → **Failed** (capacity issues)

**Final Configuration:**
```hcl
# System pool (Intel/AMD)
system_pool_vm_size = "Standard_D2s_v6"  # Available for system nodes

# Worker pool (AMD-based)
worker_pool_vm_size = "Standard_D2as_v6"  # AMD variant, better availability
```

**Files Changed:**
- `infra/aks/variables.tf`
- `infra/aks/terraform.dev.tfvars`
- `infra/modules/kubernetes/main.tf` (zones configuration)

### Best Practices

1. **Use multiple availability zones:**
```hcl
zones = ["1", "2", "3"]  # Increases chance of finding capacity
```

2. **Check Azure VM Selector:** https://aka.ms/aks/vm-size-selector

3. **Consider alternative SKU series:**
   - D-series (general purpose)
   - E-series (memory optimized)
   - F-series (compute optimized)

---

## 3. Regional vCPU Quota Exhaustion

### Problem
```
Error: ErrCode_InsufficientVCPUQuota
Message: Insufficient regional vcpu quota left for location westeurope. 
left regional vcpu quota 1, requested quota 4
```

**Root Cause:** Azure subscriptions have regional vCPU quotas. Our deployment needed:
- System pool: 1 node × 2 vCPUs = 2 vCPUs
- Worker pool: 2 nodes × 2 vCPUs = 4 vCPUs
- **Total:** 6 vCPUs (but only 1 vCPU available)

### Troubleshooting Steps

1. **Check current quota:**
```bash
az vm list-usage --location westeurope -o table
```

2. **Calculate requirements:**
```
System pool: 1 node × 2 vCPUs = 2 vCPUs
Worker pool: 2 nodes × 2 vCPUs = 4 vCPUs
Surge nodes (upgrade): 1 node × 2 vCPUs = 2 vCPUs (optional)
Total: 6-8 vCPUs
```

### Solution Options

**Option A: Reduce Node Count** ✅ (Implemented)
```hcl
# infra/aks/locals.tf
dev = {
  worker_node_count = 0  # Changed from 2 to 0
  system_pool_nodes = 1  # Keep system nodes
}
```

**Option B: Request Quota Increase** (Future)
```bash
# Via Azure Portal:
# Support → New request → Quota → Compute-VM (cores-vCPUs)
# Select region: westeurope
# Request increase for: Standard DSv2 Family vCPUs
```

**Option C: Use Different Region**
- Try northeurope or other EU regions
- Check capacity with `az vm list-skus`

### Conditional Worker Pool Creation

Added count parameter to only create worker pool when needed:

**File:** `infra/modules/kubernetes/main.tf`
```hcl
resource "azurerm_kubernetes_cluster_node_pool" "workers" {
  count = var.worker_pool_node_count > 0 || var.enable_autoscaling ? 1 : 0
  # ... rest of configuration
}
```

---

## 4. Upgrade Settings Validation

### Problem
```
Error: InvalidParameter
Message: The value of parameter agentPoolProfile.upgradeSettings.maxUnavailable is invalid. 
Error details: maxSurge and maxUnavailable cannot both be 0.
```

**Root Cause:** Initially set `max_surge = "0"` to avoid consuming extra vCPUs during upgrades, but Azure requires at least one to be non-zero.

### Solution

**File:** `infra/modules/kubernetes/main.tf`
```hcl
default_node_pool {
  # ... other settings
  
  upgrade_settings {
    # Azure requires maxSurge or maxUnavailable to be non-zero.
    # Setting max_surge to "1" avoids the API error while keeping surge small.
    max_surge = "1"  # Changed from "0"
  }
}
```

**Trade-off:** This allows one temporary surge node during upgrades (additional 2 vCPUs temporarily).

---

## 5. Spot Instance Upgrade Restrictions

### Problem
```
Error: InvalidParameter
Message: The value of parameter agentPoolProfile.upgradeSettings.maxSurge is invalid. 
Error details: Spot pools can't set max surge.
```

**Root Cause:** Worker pool configured with `priority = "Spot"`, but Spot node pools don't support `max_surge` in upgrade settings.

### Solution

Remove `upgrade_settings` from worker pool when using Spot instances:

**File:** `infra/modules/kubernetes/main.tf`
```hcl
resource "azurerm_kubernetes_cluster_node_pool" "workers" {
  # ... other settings
  
  priority        = var.use_spot_instances ? "Spot" : "Regular"
  eviction_policy = var.use_spot_instances ? "Delete" : null
  
  # Note: Spot pools cannot use upgrade_settings with max_surge
  # Upgrades will use default behavior for spot instances
  
  # REMOVED: upgrade_settings block
}
```

**Why:** Spot instances are ephemeral and designed to be interrupted, so Azure handles upgrades differently.

---

## 6. Worker Pool Node Count Validation

### Problem
```
Error: Invalid value for variable
Message: Worker pool node count must be between 1 and 100.
var.worker_pool_node_count is 0
```

**Root Cause:** Variable validation rule didn't allow `0` as a valid value.

### Solution

Updated validation to allow 0 (which disables worker pool via count parameter):

**File:** `infra/modules/kubernetes/variables.tf`
```hcl
variable "worker_pool_node_count" {
  description = "Initial number of worker nodes. Set to 0 to disable worker pool."
  type        = number
  default     = 2
  validation {
    condition     = var.worker_pool_node_count >= 0 && var.worker_pool_node_count <= 100
    error_message = "Worker pool node count must be between 0 and 100. Set to 0 to disable."
  }
}
```

---

## 7. Service Principal Permissions

### Problem
```
Error: authorization.RoleAssignmentsClient#Create: Failure responding to request: StatusCode=403
Message: The client does not have authorization to perform action 
'Microsoft.Authorization/roleAssignments/write'
```

**Root Cause:** Service Principal created with `az ad sp create-for-rbac` gets **Contributor** role by default, which can create resources but **cannot** manage role assignments (IAM).

### Why This Happens

The Terraform code needs to:
1. Create AKS cluster (needs Contributor role) ✅
2. Grant AKS managed identity permission to pull from ACR (needs authorization to assign roles) ❌
3. Grant AKS permission to access Storage (needs authorization to assign roles) ❌

### Solution

Grant **User Access Administrator** role to Service Principal:

```bash
az role assignment create \
  --assignee 14bc63e1-9633-4cee-984c-9d021d05db2b \
  --role "User Access Administrator" \
  --scope /subscriptions/fea043f7-8550-4f4b-9ed5-5cf07fe5065a
```

**Service Principal now has both:**
- ✅ Contributor (create/modify/delete resources)
- ✅ User Access Administrator (manage role assignments)

### Why Manual Step Required?

The `az ad sp create-for-rbac` command only allows **one** role:
```bash
# This gives Contributor only
az ad sp create-for-rbac --name terraform --role "Contributor"

# Can't do both in one command!
```

**Security Best Practice:** This forces explicit granting of permission management capabilities.

### Alternative Solutions

**Option A: Use Owner Role** (Not Recommended - Too Broad)
```bash
az ad sp create-for-rbac --name terraform --role "Owner"
```
⚠️ Gives full access including billing and subscription management.

**Option B: Grant Both Roles During Creation**
```bash
# Step 1: Create SP
SP_ID=$(az ad sp create-for-rbac --name terraform --query appId -o tsv)

# Step 2: Add User Access Administrator
az role assignment create --assignee $SP_ID --role "User Access Administrator"
```

**Option C: Manually Create Role Assignments** (Skip Terraform for IAM)
```bash
# Get AKS managed identity
AKS_PRINCIPAL_ID=$(az aks show --resource-group rally-mlops-rg-dev \
  --name rally-mlops-aks-dev \
  --query identityProfile.kubeletidentity.objectId -o tsv)

# Grant ACR Pull
az role assignment create \
  --assignee $AKS_PRINCIPAL_ID \
  --role "AcrPull" \
  --scope /subscriptions/.../Microsoft.ContainerRegistry/registries/rallymlopsaksdev

# Grant Storage access
az role assignment create \
  --assignee $AKS_PRINCIPAL_ID \
  --role "Storage Blob Data Contributor" \
  --scope /subscriptions/.../Microsoft.Storage/storageAccounts/rallystoragedev
```

Then comment out role assignments in `infra/aks/main.tf`.

---

## Summary: Key Lessons Learned

### 1. **VM Size Selection**
- Always check regional availability before choosing VM sizes
- Use multiple availability zones to improve capacity availability
- Have fallback SKU options (v5, v4, v3)
- AMD variants (D_as series) sometimes have better availability

### 2. **Quota Management**
- Check regional vCPU quotas early: `az vm list-usage --location <region>`
- Calculate total requirements including surge nodes
- Request quota increases proactively (can take 24-48 hours)
- Consider disabling non-critical node pools initially

### 3. **Upgrade Settings**
- Azure requires `max_surge` or `max_unavailable` to be non-zero
- Spot instances don't support `max_surge`
- Balance between upgrade speed and resource consumption

### 4. **Service Principal Permissions**
- Contributor role cannot manage IAM/role assignments
- User Access Administrator needed for Terraform to manage permissions
- Security principle: Grant minimum permissions, add as needed

### 5. **Terraform State Management**
- Use `terraform state rm` to clean up failed resources
- Use `-ignore-remote-version` carefully when state is out of sync
- Always run `terraform plan` before `apply` after fixes

---

## Quick Reference: Common Commands

### Check Available Resources
```bash
# VM sizes in region
az vm list-skus --location westeurope --output table

# Filter by vCPU count
az vm list-skus --location westeurope \
  --query "[?resourceType=='virtualMachines' && capabilities[?name=='vCPUs' && value=='2']][].name" \
  -o table

# Check quota usage
az vm list-usage --location westeurope -o table
```

### Terraform State Management
```bash
# Remove stuck resources
terraform state rm module.kubernetes.azurerm_kubernetes_cluster.main

# Import existing resource
terraform import module.kubernetes.azurerm_kubernetes_cluster.main /subscriptions/.../managedClusters/...

# Refresh state
terraform refresh
```

### AKS Cluster Verification
```bash
# Get credentials
az aks get-credentials --resource-group rally-mlops-rg-dev --name rally-mlops-aks-dev

# Check nodes
kubectl get nodes

# Check system pods
kubectl get pods -A

# Check cluster status
az aks show --resource-group rally-mlops-rg-dev --name rally-mlops-aks-dev --query provisioningState
```

### Service Principal Management
```bash
# List role assignments for SP
az role assignment list --assignee <SP_APP_ID> -o table

# Grant additional role
az role assignment create \
  --assignee <SP_APP_ID> \
  --role "User Access Administrator" \
  --scope /subscriptions/<SUBSCRIPTION_ID>
```

---

## Contact & Support

- **Azure VM Selector:** https://aka.ms/aks/vm-size-selector
- **Quota Increase:** Azure Portal → Support → New Request → Service and subscription limits (quotas)
- **AKS Documentation:** https://learn.microsoft.com/en-us/azure/aks/

---

**Last Updated:** November 3, 2025  
**Cluster:** rally-mlops-aks-dev (westeurope)  
**Status:** ✅ Successfully Deployed
