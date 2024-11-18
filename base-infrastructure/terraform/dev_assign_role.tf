resource "azurerm_role_assignment" "dev_key_vault_admin" {
  scope                = module.secrets.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = "32053268-3970-48f3-9b09-c4280cd0b67d"
}

resource "azurerm_role_assignment" "dev_key_vault_admin2" {
  scope                = module.secrets.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = "f585c1c3-801b-4641-8d7f-145aa50ffb04"
}