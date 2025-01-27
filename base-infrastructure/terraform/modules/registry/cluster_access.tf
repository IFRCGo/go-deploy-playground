resource "azurerm_role_assignment" "acr_pull" {
  count                = length(var.pull_principal_ids)
  scope                = azurerm_container_registry.shared.id
  role_definition_name = "AcrPull" # Grants the "acr pull" permission
  principal_id         = var.pull_principal_ids[count.index]
}