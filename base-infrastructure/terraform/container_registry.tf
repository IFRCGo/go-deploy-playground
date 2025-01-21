module "go_container_registry" {
  source = "./modules/registry"

  app_name            = "ifrcgo"
  environment         = var.environment
  resource_group_name = data.azurerm_resource_group.go_resource_group.name
}