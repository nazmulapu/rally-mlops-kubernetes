# Kubernetes Module (AKS/EKS agnostic)
# This module provisions a Kubernetes cluster with system and worker node pools

variable "cluster_name" {
  description = "Kubernetes cluster name"
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
  validation {
    condition     = var.system_pool_node_count >= 1 && var.system_pool_node_count <= 10
    error_message = "System pool node count must be between 1 and 10."
  }
}

variable "worker_pool_vm_size" {
  description = "VM size for worker node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "worker_pool_node_count" {
  description = "Initial number of worker nodes (fixed if autoscaling disabled)"
  type        = number
  default     = 2
  validation {
    condition     = var.worker_pool_node_count >= 1 && var.worker_pool_node_count <= 100
    error_message = "Worker pool node count must be between 1 and 100."
  }
}

variable "use_spot_instances" {
  description = "Use spot instances for worker pool (cost savings, not recommended for production)"
  type        = bool
  default     = false
}

variable "spot_max_price" {
  description = "Maximum price for spot instances in USD (null means pay-as-you-go)"
  type        = number
  default     = null
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for worker node pool"
  type        = bool
  default     = false
}

variable "min_worker_nodes" {
  description = "Minimum number of worker nodes (required if autoscaling enabled)"
  type        = number
  default     = 1
  validation {
    condition     = var.min_worker_nodes >= 1
    error_message = "Minimum worker nodes must be at least 1."
  }
}

variable "max_worker_nodes" {
  description = "Maximum number of worker nodes (required if autoscaling enabled)"
  type        = number
  default     = 5
  validation {
    condition     = var.max_worker_nodes >= 1
    error_message = "Maximum worker nodes must be at least 1."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
