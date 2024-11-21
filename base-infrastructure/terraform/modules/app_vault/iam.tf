# Grant the user applying the infra changes administrative rights on the vault
resource "azurerm_role_assignment" "key_vault_admin" {
  scope                = azurerm_key_vault.app_kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Create an identity that will be used by the application
resource "azurerm_user_assigned_identity" "workload" {
  name                = "${title(var.app_name)}${title(var.environment)}WorkloadIdentity"
  location            = data.azurerm_resource_group.app_rg.location
  resource_group_name = data.azurerm_resource_group.app_rg.name
}

# Grant application identity permission to access secrets
resource "azurerm_role_assignment" "key_vault_reader" {
  scope                = azurerm_key_vault.app_kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
}

resource "azurerm_federated_identity_credential" "cred" {
  name                = "${var.app_name}-${var.environment}-secret-reader-identity"
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.cluster_oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.workload.id
  resource_group_name = var.resource_group_name
  subject             = "system:serviceaccount:${var.cluster_namespace}:${var.service_account_name}"
}