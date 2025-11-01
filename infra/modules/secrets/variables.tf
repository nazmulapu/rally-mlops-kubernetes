# Secrets Module Variables (Key Vault/Secrets Manager agnostic)

variable "key_vault_name" {
  description = "Key Vault name (must be globally unique, 3-24 chars, alphanumeric and hyphens)"
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "sku_name" {
  description = "Key Vault SKU"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU must be standard or premium."
  }
}

variable "tenant_id" {
  description = "Azure tenant ID"
  type        = string
}

variable "object_id" {
  description = "Object ID of the user/service principal with access"
  type        = string
}

variable "enabled_for_disk_encryption" {
  description = "Allow disk encryption"
  type        = bool
  default     = false
}

variable "enabled_for_deployment" {
  description = "Allow deployment from Key Vault"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Allow template deployment from Key Vault"
  type        = bool
  default     = true
}

variable "purge_protection_enabled" {
  description = "Enable purge protection (recommended: true)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
