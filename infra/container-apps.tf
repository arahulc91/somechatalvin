# Container Apps configuration for .env-based deployments
# Config comes from .env file baked into the image

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.project_name}-logs-${local.resource_suffix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}

resource "azurerm_container_app_environment" "main" {
  name                       = "${var.project_name}-env-${local.resource_suffix}"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  infrastructure_subnet_id   = azurerm_subnet.container_apps.id

  tags = local.common_tags
}

# PostgreSQL with pgvector for RAG
resource "azurerm_container_app" "vectordb" {
  name                         = "${var.project_name}-vectordb-${local.resource_suffix}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "vectordb"
      image  = "pgvector/pgvector:0.8.0-pg15-trixie"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "POSTGRES_DB"
        value = "mydatabase"
      }

      env {
        name  = "POSTGRES_USER"
        value = "myuser"
      }

      env {
        name        = "POSTGRES_PASSWORD"
        secret_name = "postgres-password"
      }
    }

    min_replicas = 1
    max_replicas = 1
  }

  secret {
    name  = "postgres-password"
    value = random_password.postgres_password.result
  }

  ingress {
    external_enabled = false
    target_port      = 5432
    transport        = "tcp"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = local.common_tags
}

# MeiliSearch
resource "azurerm_container_app" "meilisearch" {
  name                         = "${var.project_name}-meili-${local.resource_suffix}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "meilisearch"
      image  = "getmeili/meilisearch:v1.12.3"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "MEILI_HOST"
        value = "http://0.0.0.0:7700"
      }

      env {
        name  = "MEILI_NO_ANALYTICS"
        value = "true"
      }

      env {
        name        = "MEILI_MASTER_KEY"
        secret_name = "meili-master-key"
      }
    }

    min_replicas = 1
    max_replicas = 1
  }

  secret {
    name  = "meili-master-key"
    value = random_password.meili_master_key.result
  }

  ingress {
    external_enabled = false
    target_port      = 7700

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = local.common_tags
}

# RAG API
resource "azurerm_container_app" "rag_api" {
  name                         = "${var.project_name}-rag-${local.resource_suffix}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  template {
    container {
      name   = "rag-api"
      image  = "ghcr.io/danny-avila/librechat-rag-api-dev-lite:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "DB_HOST"
        value = azurerm_container_app.vectordb.ingress[0].fqdn
      }

      env {
        name  = "RAG_PORT"
        value = "8000"
      }

      env {
        name  = "POSTGRES_DB"
        value = "mydatabase"
      }

      env {
        name  = "POSTGRES_USER"
        value = "myuser"
      }

      env {
        name        = "POSTGRES_PASSWORD"
        secret_name = "postgres-password"
      }
    }

    min_replicas = 1
    max_replicas = 2
  }

  secret {
    name  = "postgres-password"
    value = random_password.postgres_password.result
  }

  ingress {
    external_enabled = false
    target_port      = 8000

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = local.common_tags
}

# Main LibreChat Application
resource "azurerm_container_app" "librechat" {
  name                         = "${var.project_name}-app-${local.resource_suffix}"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"

  # ACR authentication
  registry {
    server               = azurerm_container_registry.main.login_server
    username             = azurerm_container_registry.main.admin_username
    password_secret_name = "acr-password"
  }

  template {
    container {
      name   = "librechat"
      image  = "${azurerm_container_registry.main.login_server}/librechat:${var.image_tag}"
      cpu    = var.container_cpu
      memory = "${var.container_memory}Gi"

      # Only essential overrides - most config comes from .env in image
      env {
        name  = "MEILI_HOST"
        value = "http://${azurerm_container_app.meilisearch.ingress[0].fqdn}"
      }

      env {
        name  = "RAG_API_URL"
        value = "http://${azurerm_container_app.rag_api.ingress[0].fqdn}:8000"
      }
    }

    min_replicas = 1
    max_replicas = 3
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.main.admin_password
  }

  ingress {
    external_enabled = true
    target_port      = var.app_port

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = local.common_tags
}
