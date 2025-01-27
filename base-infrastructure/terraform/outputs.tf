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

output "alert_hub_storage_container" {
  value = module.alert_hub_vault.storage_container_names
}

output "sdt_resources" {
  value = {
    sdt_client_id = module.sdt_vault.workload_client_id
  } 
}

output "storage_account_names" {
  value = azurerm_storage_account.app_storage.name
  #value = data.azurerm_storage_account.gosanbox1.name
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.app_storage.primary_blob_endpoint
  #value = data.azurerm_storage_account.gosanbox1.primary_blob_endpoint
}

#output "site_storage_account" {
#  value = module.alert_hub_frontend.storage_account_name
#}