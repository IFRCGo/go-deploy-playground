module "go_container_registry" {
  source = "./modules/registry"

  app_name            = "ifrcgo"
  environment         = var.environment

  pull_principal_ids  = [
    #azurerm_kubernetes_cluster.go_kubernetes_cluster.identity[0].principal_id,
    azurerm_kubernetes_cluster.go_kubernetes_cluster.kubelet_identity[0].object_id
  ]

  resource_group_name = data.azurerm_resource_group.go_resource_group.name
}