locals {
  alert_hub_db_name = "alerthubplaygrounddb"
}

module "alert_hub_vault" {
  source = "./modules/app_vault"

  app_name                = "alert-hub"
  cluster_namespace       = "alert-hub"
  cluster_oidc_issuer_url = azurerm_kubernetes_cluster.go_kubernetes_cluster.oidc_issuer_url
  # NOTE: Use database_config pattern instead?
  database_server_id = azurerm_postgresql_flexible_server.ifrc.id
  database_name      = local.alert_hub_db_name

  environment         = var.environment
  resource_group_name = data.azurerm_resource_group.go_resource_group.name

  secrets = {
    DB_USER     = var.psql_administrator_login
    DB_PASSWORD = random_password.db_admin.result
    DB_HOST     = azurerm_postgresql_flexible_server.ifrc.fqdn
    DB_NAME     = local.alert_hub_db_name
  }

  storage_config = {
    container_refs = [
      {
        container_ref = "media"
        access_type   = "private"
      },
      {
        container_ref = "static"
        access_type   = "blob"
      }
    ]

    enabled              = true
    storage_account_id   = azurerm_storage_account.app_storage.id
    storage_account_name = azurerm_storage_account.app_storage.name
  }

  vault_subnet_ids = [azurerm_subnet.app.id]
}
