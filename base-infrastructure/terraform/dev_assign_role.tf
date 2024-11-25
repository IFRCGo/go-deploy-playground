#resource "azurerm_role_assignment" "dev_key_vault_admin" {
#  scope                = module.secrets.key_vault_id
#  role_definition_name = "Key Vault Administrator"
#  principal_id         = "32053268-3970-48f3-9b09-c4280cd0b67d"
#}
#
#resource "azurerm_role_assignment" "dev_key_vault_admin2" {
#  scope                = module.secrets.key_vault_id
#  role_definition_name = "Key Vault Administrator"
#  principal_id         = "c31baae7-afbf-4ad3-8e01-5abbd68adb16"
#}
#
#resource "azurerm_role_assignment" "alert_key_vault_admin" {
#  scope                = module.alert_hub_vault.key_vault_id
#  role_definition_name = "Key Vault Administrator"
#  principal_id         = "32053268-3970-48f3-9b09-c4280cd0b67d"
#}
#
#resource "azurerm_role_assignment" "alert_key_vault_admin2" {
#  scope                = module.alert_hub_vault.key_vault_id
#  role_definition_name = "Key Vault Administrator"
#  principal_id         = "c31baae7-afbf-4ad3-8e01-5abbd68adb16"
#}