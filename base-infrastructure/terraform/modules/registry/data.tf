data "azurerm_resource_group" "app_rg" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {
}