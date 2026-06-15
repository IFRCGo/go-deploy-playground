output "key_vault_id" {
  value = azurerm_key_vault.app_kv.id
}

output "key_vault_name" {
  value = azurerm_key_vault.app_kv.name
}

output "workload_client_id" {
  value = azurerm_user_assigned_identity.workload.client_id
}

output "workload_id" {
  value = azurerm_user_assigned_identity.workload.id
}

output "storage_container_names" {
  value = var.storage_config.enabled ? azurerm_storage_container.app_container[*].name : null
}

output "database_name" {
  value       = var.database_server_id != null ? local.app_database_name : null
  description = "The PostgreSQL database name created for this app. Null if no database_server_id was provided."
}
