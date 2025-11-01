# Container Registry Module - Main Resources

resource "azurerm_container_registry" "main" {
  name                = var.registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  # Managed identity for Azure services integration
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
