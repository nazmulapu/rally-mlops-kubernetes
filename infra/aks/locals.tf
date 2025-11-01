# AKS-specific locals and derived values

locals {
  common_tags = {
    environment = var.environment
    project     = "rally-mlops"
    managed_by  = "terraform"
  }

  # Registry name (remove hyphens for ACR requirement)
  registry_name = replace(var.cluster_name, "-", "")

  # Key Vault name (remove hyphens and truncate if needed)
  key_vault_name = substr(replace("${var.cluster_name}kv", "-", ""), 0, 24)

  # Environment-specific settings
  environment_config = {
    dev = {
      enable_spot_instances = true
      use_managed_identity  = false
      acr_admin_enabled     = true
      autoscaling_enabled   = false
      worker_node_count     = 2
      min_worker_nodes      = 1
      max_worker_nodes      = 3
      system_pool_nodes     = 1
    }
    staging = {
      enable_spot_instances = true
      use_managed_identity  = true
      acr_admin_enabled     = false
      autoscaling_enabled   = true
      worker_node_count     = 2
      min_worker_nodes      = 2
      max_worker_nodes      = 5
      system_pool_nodes     = 1
    }
    prod = {
      enable_spot_instances = false
      use_managed_identity  = true
      acr_admin_enabled     = false
      autoscaling_enabled   = true
      worker_node_count     = 3
      min_worker_nodes      = 3
      max_worker_nodes      = 10
      system_pool_nodes     = 2
    }
  }

  # Get config for current environment
  env_config = local.environment_config[var.environment]
}
