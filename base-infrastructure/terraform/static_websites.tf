module "alert_hub_frontend" {
  source = "./modules/static_website" 

  app_name = "alert-hub-frontend"
  environment = var.environment
  github_repo = "alert-hub-web-app"
  location = data.azurerm_resource_group.go_resource_group.location
  resource_group_name = data.azurerm_resource_group.go_resource_group.name
}