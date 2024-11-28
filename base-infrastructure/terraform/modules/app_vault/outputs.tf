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

output "storage_container_name" {
  value = var.storage_config.enabled ? azurerm_storage_container.app_container[0].name : null
}