# Container Registry Module Variables (ACR/ECR agnostic)

variable "registry_name" {
  description = "Container registry name (must be globally unique, alphanumeric only)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.registry_name))
    error_message = "Registry name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "sku" {
  description = "SKU for container registry (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  description = "Enable admin user for registry (NOT recommended for production - use managed identity instead)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
