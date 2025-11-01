# Kubernetes Module - Main Resources

resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name

  kubernetes_version = var.kubernetes_version

  # System node pool
  default_node_pool {
    name                = "system"
    node_count          = var.system_pool_node_count
    vm_size             = var.system_pool_vm_size
    os_disk_size_gb     = 128
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = false # System pool doesn't scale
  }

  # Identity
  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  tags = var.tags
}

# Worker node pool with autoscaling and spot instance support
resource "azurerm_kubernetes_cluster_node_pool" "workers" {
  name                  = "workers"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.worker_pool_vm_size
  node_count            = !var.enable_autoscaling ? var.worker_pool_node_count : null
  os_disk_size_gb       = 128
  os_type               = "Linux"

  # Autoscaling configuration
  enable_auto_scaling = var.enable_autoscaling
  min_count           = var.enable_autoscaling ? var.min_worker_nodes : null
  max_count           = var.enable_autoscaling ? var.max_worker_nodes : null

  # Spot instance configuration
  priority        = var.use_spot_instances ? "Spot" : "Regular"
  eviction_policy = var.use_spot_instances ? "Delete" : null
  spot_max_price  = var.use_spot_instances && var.spot_max_price != null ? var.spot_max_price : null

  tags = var.tags

  depends_on = [azurerm_kubernetes_cluster.main]
}
