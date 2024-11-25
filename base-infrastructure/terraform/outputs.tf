output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "risk_module_key_vault_name" {
  value = module.secrets.key_vault_name
}

output "risk_module_client_id" {
  value = module.secrets.workload_client_id
}

output "alert_hub_key_vault_name" {
  value = module.alert_hub_vault.key_vault_name
}

output "alert_hub_client_id" {
  value = module.alert_hub_vault.workload_client_id
}