#module "alert_hub_frontend" {
#  source = "./modules/static_website"
#
#  app_name            = "alert-hub-web-app"
#  environment         = var.environment
#  github_repo         = "alert-hub-web-app"
#  location            = data.azurerm_resource_group.go_resource_group.location
#  resource_group_name = data.azurerm_resource_group.go_resource_group.name
#}

# TODO(susilnem): Enable go frontend
# module "go_frontend" {
#   source = "./modules/static_website"

#   app_name            = "go-web-app"
#   environment         = var.environment
#   github_repo         = "go-web-app"
#   location            = data.azurerm_resource_group.go_resource_group.location
#   resource_group_name = data.azurerm_resource_group.go_resource_group.name
# }
