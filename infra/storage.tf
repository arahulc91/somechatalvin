resource "azurerm_storage_account" "main" {
  name                     = "${var.project_name}st${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "POST", "PUT"]
      allowed_origins    = var.allowed_origins
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }

  tags = local.common_tags
}

resource "azurerm_storage_container" "uploads" {
  name                  = "uploads"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "images" {
  name                  = "images"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "blob"
}

resource "azurerm_storage_share" "logs" {
  name               = "logs"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 10
}

resource "azurerm_storage_share" "meili_data" {
  name               = "meili-data"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 10
}

resource "azurerm_storage_share" "postgres_data" {
  name               = "postgres-data"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 10
}
