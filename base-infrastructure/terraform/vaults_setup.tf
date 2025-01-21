module "secrets" {
  source = "./modules/app_vault"

  app_name                = "risk-module"
  cluster_namespace       = "ifrcgo-risk-module"
  cluster_oidc_issuer_url = azurerm_kubernetes_cluster.go_kubernetes_cluster.oidc_issuer_url
  database_server_id      = azurerm_postgresql_flexible_server.ifrc.id
  environment             = var.environment
  resource_group_name     = data.azurerm_resource_group.go_resource_group.name

  secrets = {
    DATABASE_PASSWORD          = ""
    DJANGO_SECRET_KEY          = ""
    METEOSWISS_S3_ACCESS_KEY   = ""
    METEOSWISS_S3_BUCKET       = ""
    METEOSWISS_S3_ENDPOINT_URL = ""
    METEOSWISS_S3_SECRET_KEY   = ""
    PDC_ACCESS_TOKEN           = ""
    PDC_PASSWORD               = ""
    PDC_USERNAME               = ""
    SENTRY_DSN                 = ""
  }

  vault_subnet_ids = [azurerm_subnet.app.id]
}

module "alert_hub_vault" {
  source = "./modules/app_vault"

  app_name                = "alert-hub"
  cluster_namespace       = "alert-hub"
  cluster_oidc_issuer_url = azurerm_kubernetes_cluster.go_kubernetes_cluster.oidc_issuer_url
  database_server_id      = azurerm_postgresql_flexible_server.ifrc.id
  environment             = var.environment
  resource_group_name     = data.azurerm_resource_group.go_resource_group.name
  service_account_name    = "alert-hub-sa"

  secrets = {
    DB_USER     = var.psql_administrator_login
    DB_PASSWORD = random_password.db_admin.result
    DB_HOST     = azurerm_postgresql_flexible_server.ifrc.fqdn
  }

  storage_config = {
    container_refs = [
      "media",
      "static"
    ]

    enabled              = true
    storage_account_id   = azurerm_storage_account.app_storage.id
    storage_account_name = azurerm_storage_account.app_storage.name
  }

  vault_subnet_ids = [azurerm_subnet.app.id]
}

module "sdt_vault" {
  source = "./modules/app_vault"

  app_name                = "sdt"
  cluster_namespace       = "sdt"
  cluster_oidc_issuer_url = azurerm_kubernetes_cluster.go_kubernetes_cluster.oidc_issuer_url
  environment             = var.environment
  resource_group_name     = data.azurerm_resource_group.go_resource_group.name
  service_account_name    = "sdt-sa"

  secrets = {
    CONTAINER_REGISTRY_USER     = module.go_container_registry.acr_token_username
    CONTAINER_REGISTRY_PASSWORD = module.go_container_registry.acr_token_password
  }

  vault_subnet_ids = [azurerm_subnet.app.id]
}