output "key_vault_name" {
  value = azurerm_key_vault.app_kv.name
}

output "workload_client_id" {
  value = azurerm_user_assigned_identity.workload.client_id
}

output "workload_id"{
  value = azurerm_user_assigned_identity.workload.id
}