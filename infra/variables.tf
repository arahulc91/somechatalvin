variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-librechat"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "librechat"
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 3080
}

variable "cosmos_db_throughput" {
  description = "Cosmos DB throughput (RU/s)"
  type        = number
  default     = 400
}

variable "container_cpu" {
  description = "CPU cores for main container"
  type        = number
  default     = 1
}

variable "container_memory" {
  description = "Memory in GB for main container"
  type        = number
  default     = 2
}

variable "enable_https" {
  description = "Enable HTTPS for the application"
  type        = bool
  default     = true
}

variable "allowed_origins" {
  description = "Allowed CORS origins"
  type        = list(string)
  default     = ["*"]
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "LibreChat"
    ManagedBy = "Terraform"
  }
}
