# Azure subscription ID (required)
subscription_id = "YOUR_AZURE_SUBSCRIPTION_ID"

# Resource group name
resource_group_name = "rg-librechat"

# Azure region
location = "eastus"

# Environment (dev, staging, prod)
environment = "prod"

# Project name (used for resource naming)
project_name = "librechat"

# Application port
app_port = 3080

# Cosmos DB throughput (RU/s) - Note: Using serverless mode by default
# cosmos_db_throughput = 400

# Container resources
container_cpu    = 1.0
container_memory = 2

# Docker image tag (change after building new image)
image_tag = "latest"

# Tags for all resources
tags = {
  Project     = "LibreChat"
  ManagedBy   = "Terraform"
  Environment = "Production"
}
