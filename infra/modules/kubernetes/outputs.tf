# Kubernetes Module - Outputs

output "cluster_id" {
  value       = azurerm_kubernetes_cluster.main.id
  description = "AKS cluster ID"
}

output "cluster_name" {
  value       = azurerm_kubernetes_cluster.main.name
  description = "AKS cluster name"
}

output "cluster_fqdn" {
  value       = azurerm_kubernetes_cluster.main.fqdn
  description = "AKS cluster FQDN"
}

output "kube_config_raw" {
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  description = "Raw kubeconfig for cluster access"
  sensitive   = true
}

output "kubelet_identity" {
  value       = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  description = "Kubelet managed identity object ID"
}

output "node_resource_group" {
  value       = azurerm_kubernetes_cluster.main.node_resource_group
  description = "Auto-generated resource group for cluster nodes"
}
