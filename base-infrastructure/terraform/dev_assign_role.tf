resource "azurerm_role_assignment" "dev_key_vault_admin" {
  scope                = module.secrets.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = "32053268-3970-48f3-9b09-c4280cd0b67d"
}