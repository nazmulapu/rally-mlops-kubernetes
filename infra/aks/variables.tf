# AKS Environment Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rally-mlops-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "rally-mlops-aks"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "system_pool_vm_size" {
  description = "VM size for system node pool"
  type        = string
  default     = "Standard_B2s"
}

variable "system_pool_node_count" {
  description = "Number of nodes in system pool"
  type        = number
  default     = 1
}

variable "worker_pool_vm_size" {
  description = "VM size for worker (spot) node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "worker_pool_node_count" {
  description = "Number of nodes in worker pool"
  type        = number
  default     = 3
}

variable "storage_account_name" {
  description = "Blob storage account name (must be globally unique, lowercase alphanumeric)"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
