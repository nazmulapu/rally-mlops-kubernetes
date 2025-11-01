# AKS Environment Outputs

output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Resource group name"
}

output "resource_group_id" {
  value       = azurerm_resource_group.main.id
  description = "Resource group ID"
}

# Kubernetes Outputs
output "aks_cluster_id" {
  value       = module.kubernetes.cluster_id
  description = "AKS cluster ID"
}

output "aks_cluster_name" {
  value       = module.kubernetes.cluster_name
  description = "AKS cluster name"
}

output "aks_cluster_fqdn" {
  value       = module.kubernetes.cluster_fqdn
  description = "AKS cluster FQDN"
}

output "kube_config_raw" {
  value       = module.kubernetes.kube_config_raw
  description = "Raw kubeconfig for cluster access"
  sensitive   = true
}

output "kubelet_identity_object_id" {
  value       = module.kubernetes.kubelet_identity
  description = "Kubelet managed identity object ID"
}

output "node_resource_group" {
  value       = module.kubernetes.node_resource_group
  description = "Auto-generated resource group for cluster nodes"
}

# Container Registry Outputs
output "acr_registry_id" {
  value       = module.container_registry.registry_id
  description = "Azure Container Registry ID"
}

output "acr_login_server" {
  value       = module.container_registry.login_server
  description = "ACR login server URL"
}

output "acr_admin_username" {
  value       = module.container_registry.admin_username
  description = "ACR admin username"
  sensitive   = true
}

output "acr_admin_password" {
  value       = module.container_registry.admin_password
  description = "ACR admin password"
  sensitive   = true
}

# Storage Outputs
output "storage_account_id" {
  value       = module.storage.storage_account_id
  description = "Storage account ID"
}

output "storage_account_name" {
  value       = module.storage.storage_account_name
  description = "Storage account name"
}

output "storage_primary_blob_endpoint" {
  value       = module.storage.primary_blob_endpoint
  description = "Primary blob endpoint URL"
}

output "storage_container_names" {
  value       = module.storage.container_names
  description = "List of storage container names"
}

output "storage_connection_string" {
  value       = module.storage.primary_connection_string
  description = "Storage account connection string"
  sensitive   = true
}

# Key Vault Outputs
output "key_vault_id" {
  value       = module.secrets.key_vault_id
  description = "Key Vault ID"
}

output "key_vault_name" {
  value       = module.secrets.key_vault_name
  description = "Key Vault name"
}

output "key_vault_uri" {
  value       = module.secrets.key_vault_uri
  description = "Key Vault URI"
}

# Summary Output
output "deployment_summary" {
  value = {
    cluster_name          = module.kubernetes.cluster_name
    resource_group        = azurerm_resource_group.main.name
    registry_login_server = module.container_registry.login_server
    storage_account       = module.storage.storage_account_name
    storage_containers    = module.storage.container_names
    key_vault_name        = module.secrets.key_vault_name
    environment           = var.environment
  }
  description = "Deployment summary"
}
