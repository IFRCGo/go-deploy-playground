data "azurerm_resource_group" "go_resource_group" {
  name = "ifrctgos002rg"
}

data "azurerm_client_config" "current" {
}

# FIXME: Remove this is not required
# tflint-ignore: terraform_unused_declarations
data "azurerm_subscription" "current" {
}