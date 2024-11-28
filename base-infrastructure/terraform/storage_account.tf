# Create Storage Account
resource "azurerm_storage_account" "app_storage" {
  name                     = "go${var.environment}storage"
  resource_group_name      = data.azurerm_resource_group.go_resource_group.name
  location                 = data.azurerm_resource_group.go_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.environment
  }
}