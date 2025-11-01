# AKS Main Configuration
# Calls modular resources with environment-specific settings

# Data source for current Azure client config
data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = local.common_tags
}

# Kubernetes Module - AKS Cluster
module "kubernetes" {
  source = "../modules/kubernetes"

  cluster_name           = var.cluster_name
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  kubernetes_version     = var.kubernetes_version
  system_pool_vm_size    = var.system_pool_vm_size
  system_pool_node_count = local.env_config.system_pool_nodes
  worker_pool_vm_size    = var.worker_pool_vm_size
  worker_pool_node_count = local.env_config.worker_node_count
  use_spot_instances     = local.env_config.enable_spot_instances
  spot_max_price         = local.env_config.enable_spot_instances ? 0.096 : null
  enable_autoscaling     = local.env_config.autoscaling_enabled
  min_worker_nodes       = local.env_config.min_worker_nodes
  max_worker_nodes       = local.env_config.max_worker_nodes
  tags                   = local.common_tags

  depends_on = [azurerm_resource_group.main]
}

# Container Registry Module - ACR
module "container_registry" {
  source = "../modules/container_registry"

  registry_name       = local.registry_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  admin_enabled       = local.env_config.acr_admin_enabled
  tags                = local.common_tags

  depends_on = [azurerm_resource_group.main]
}

# Storage Module - Blob Storage
module "storage" {
  source = "../modules/storage"

  storage_account_name     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  containers = {
    raw      = "private"
    labels   = "private"
    features = "private"
  }
  tags = local.common_tags

  depends_on = [azurerm_resource_group.main]
}

# Secrets Module - Key Vault
module "secrets" {
  source = "../modules/secrets"

  key_vault_name      = local.key_vault_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  tags                = local.common_tags

  depends_on = [azurerm_resource_group.main]
}

# Grant AKS cluster access to ACR (using managed identity)
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                            = module.container_registry.registry_id
  role_definition_name             = "AcrPull"
  principal_id                     = module.kubernetes.kubelet_identity
  skip_service_principal_aad_check = true

  depends_on = [module.kubernetes, module.container_registry]
}

# Grant AKS cluster access to Storage
resource "azurerm_role_assignment" "aks_storage_blob" {
  scope                            = module.storage.storage_account_id
  role_definition_name             = "Storage Blob Data Contributor"
  principal_id                     = module.kubernetes.kubelet_identity
  skip_service_principal_aad_check = true

  depends_on = [module.kubernetes, module.storage]
}
