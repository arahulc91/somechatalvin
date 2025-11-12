resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "random_password" "jwt_secret" {
  length  = 64
  special = true
}

resource "random_password" "jwt_refresh_secret" {
  length  = 64
  special = true
}

resource "random_password" "meili_master_key" {
  length  = 32
  special = false
}

resource "random_password" "postgres_password" {
  length  = 32
  special = true
}

locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )

  resource_suffix = "${var.environment}-${random_string.suffix.result}"

  mongo_connection_string = "mongodb://${azurerm_cosmosdb_account.main.name}:${azurerm_cosmosdb_account.main.primary_key}@${azurerm_cosmosdb_account.main.name}.mongo.cosmos.azure.com:10255/LibreChat?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000"
}
