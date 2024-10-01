data "azurerm_resource_group" "go_resource_group" {
  name = "ifrctgos002rg"
}

data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "current" {
}