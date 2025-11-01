# Storage Module - Outputs

output "storage_account_id" {
  value       = azurerm_storage_account.main.id
  description = "Storage account ID"
}

output "storage_account_name" {
  value       = azurerm_storage_account.main.name
  description = "Storage account name"
}

output "primary_blob_endpoint" {
  value       = azurerm_storage_account.main.primary_blob_endpoint
  description = "Primary blob endpoint URL"
}

output "primary_connection_string" {
  value       = azurerm_storage_account.main.primary_connection_string
  description = "Primary connection string"
  sensitive   = true
}

output "container_names" {
  value       = keys(azurerm_storage_container.containers)
  description = "List of container names"
}

output "container_ids" {
  value       = { for name, container in azurerm_storage_container.containers : name => container.id }
  description = "Map of container names to IDs"
}
