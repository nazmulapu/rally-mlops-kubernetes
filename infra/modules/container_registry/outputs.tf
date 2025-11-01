# Container Registry Module - Outputs

output "registry_id" {
  value       = azurerm_container_registry.main.id
  description = "Container registry ID"
}

output "registry_name" {
  value       = azurerm_container_registry.main.name
  description = "Container registry name"
}

output "login_server" {
  value       = azurerm_container_registry.main.login_server
  description = "Login server URL for the registry"
}

output "admin_username" {
  value       = azurerm_container_registry.main.admin_username
  description = "Admin username for registry access (if admin_enabled = true)"
  sensitive   = true
}

output "admin_password" {
  value       = azurerm_container_registry.main.admin_password
  description = "Admin password for registry access (if admin_enabled = true)"
  sensitive   = true
}

output "registry_identity_principal_id" {
  value       = azurerm_container_registry.main.identity[0].principal_id
  description = "Principal ID of the registry's managed identity (use for AcrPull role assignment)"
}

output "registry_identity_tenant_id" {
  value       = azurerm_container_registry.main.identity[0].tenant_id
  description = "Tenant ID of the registry's managed identity"
}
