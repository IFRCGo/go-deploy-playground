locals {
  vault_name = "${var.app_name}-${var.environment}-key-vault"
}
# Create an Azure Key Vault
resource "azurerm_key_vault" "app_kv" {
  # Ensure vault name is not longer that 24 characters and doesn't end with a hyphen
  #regexreplace(var.input_string, "-+$", "")
  name                       = length(local.vault_name) > 24 ? substr(local.vault_name, 0, 24) : regexreplace(local.vault_name, "-+$", "")
  enable_rbac_authorization  = true
  location                   = data.azurerm_resource_group.app_rg.location
  resource_group_name        = data.azurerm_resource_group.app_rg.name
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled   = false

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = var.vault_subnet_ids
  }
}