output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "test_key_vault_name" {
  value = module.secrets.key_vault_name
}

output "test_workload_id" {
  value = module.secrets.workload_id
}