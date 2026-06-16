# Sushil
resource "azurerm_role_assignment" "alert_hub_vault_admin" {
  scope                = module.alert_hub_vault.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = "fd7b3704-8168-4b27-901c-f984b6b82c9a"
}

# Navin
resource "azurerm_role_assignment" "alert_hub_vault_admin2" {
  scope                = module.alert_hub_vault.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = "c31baae7-afbf-4ad3-8e01-5abbd68adb16"
}
