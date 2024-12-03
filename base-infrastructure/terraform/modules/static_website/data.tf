# Get current Azure configuration
data "azurerm_client_config" "current" {}

# Get current AzureAD configuration
data "azuread_client_config" "current" {}