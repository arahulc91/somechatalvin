output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "librechat_url" {
  description = "URL to access LibreChat"
  value       = "https://${azurerm_container_app.librechat.ingress[0].fqdn}"
}

output "cosmos_db_endpoint" {
  description = "Cosmos DB endpoint"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "cosmos_db_name" {
  description = "Cosmos DB account name"
  value       = azurerm_cosmosdb_account.main.name
}

output "cosmos_db_connection_string" {
  description = "Cosmos DB MongoDB connection string"
  value       = local.mongo_connection_string
  sensitive   = true
}

output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.main.name
}

output "storage_account_key" {
  description = "Storage account primary key"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "acr_name" {
  description = "Container registry name"
  value       = azurerm_container_registry.main.name
}

output "acr_login_server" {
  description = "Container registry login server"
  value       = azurerm_container_registry.main.login_server
}

output "container_registry_login_server" {
  description = "Container registry login server (deprecated, use acr_login_server)"
  value       = azurerm_container_registry.main.login_server
}

output "container_registry_admin_username" {
  description = "Container registry admin username"
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}

output "container_registry_admin_password" {
  description = "Container registry admin password"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}

output "meili_master_key" {
  description = "MeiliSearch master key"
  value       = random_password.meili_master_key.result
  sensitive   = true
}

output "jwt_secret" {
  description = "JWT secret"
  value       = random_password.jwt_secret.result
  sensitive   = true
}

output "jwt_refresh_secret" {
  description = "JWT refresh secret"
  value       = random_password.jwt_refresh_secret.result
  sensitive   = true
}

output "postgres_password" {
  description = "PostgreSQL password"
  value       = random_password.postgres_password.result
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.main.id
}

output "container_app_environment_id" {
  description = "Container App Environment ID"
  value       = azurerm_container_app_environment.main.id
}
