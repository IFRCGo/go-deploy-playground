# terraform {
#     backend local {
#       path = "terraform.tfstate"
#     }
# }

terraform {
  backend "azurerm" {
    resource_group_name  = "ifrctgos002rg"
    storage_account_name = "ifrcgoterraform"
    container_name       = "terraform"
    key                  = "playground"
  }
}