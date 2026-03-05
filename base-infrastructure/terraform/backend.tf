terraform {
  required_version = "~> 1.11.3"

  backend "azurerm" {
    resource_group_name  = "ifrctgos002rg"
    storage_account_name = "gosandbox1"
    container_name       = "terraform"
    key                  = "playground"
  }
}
