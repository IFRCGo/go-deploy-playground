resource "azurerm_role_assignment" "key_vault_devs" {
  count                = length(var.vault_admin_ids)
  scope                = azurerm_key_vault.app_kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.vault_admin_ids[count.index]
}
