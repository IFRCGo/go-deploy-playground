locals {
  user_principal_ids = {
    tc_navin  = "c31baae7-afbf-4ad3-8e01-5abbd68adb16"
    tc_ranjan = "fc0ebb01-c8f1-456b-a7a5-0a2d6c79e6d9"
    tc_sushil = "fd7b3704-8168-4b27-901c-f984b6b82c9a"
  }

  alert_hub_db_name = "alerthubplaygrounddb"
  go_api_db_name    = "goapiplaygrounddb"
}

module "alert_hub_vault" {
  source = "./modules/app_vault"

  app_name                = "alert-hub"
  cluster_namespace       = "alert-hub"
  cluster_oidc_issuer_url = azurerm_kubernetes_cluster.go_kubernetes_cluster.oidc_issuer_url
  database_config = {
    enabled   = true
    server_id = azurerm_postgresql_flexible_server.ifrc.id
    name      = local.alert_hub_db_name
  }

  environment         = var.environment
  resource_group_name = data.azurerm_resource_group.go_resource_group.name

  secrets = {
    DB_USER     = var.psql_administrator_login
    DB_PASSWORD = random_password.db_admin.result
    DB_HOST     = azurerm_postgresql_flexible_server.ifrc.fqdn
    DB_NAME     = local.alert_hub_db_name
  }

  vault_admin_ids = [
    local.user_principal_ids.tc_navin,
    local.user_principal_ids.tc_sushil,
  ]

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

    enabled            = true
    storage_account_id = azurerm_storage_account.app_storage.id
  }

  vault_subnet_ids = [azurerm_subnet.app.id]
}

module "go_api_vault" {
  source = "./modules/app_vault"

  app_name                = "go-api"
  cluster_namespace       = "go-api"
  cluster_oidc_issuer_url = azurerm_kubernetes_cluster.go_kubernetes_cluster.oidc_issuer_url
  database_config = {
    enabled   = true
    server_id = azurerm_postgresql_flexible_server.ifrc.id
    name      = local.go_api_db_name
  }

  environment         = var.environment
  resource_group_name = data.azurerm_resource_group.go_resource_group.name

  # Should match secretsKeyMap entry from https://github.com/IFRCGo/go-api/blob/develop/deploy/helm/values/go-deploy/base.yaml
  # NOTE: base-infrastructure/terraform/modules/app_vault/secrets.tf replaces `_` -> `-`
  secrets = {
    DJANGO_DB_USER = var.psql_administrator_login
    DJANGO_DB_PASS = random_password.db_admin.result
    DJANGO_DB_HOST = azurerm_postgresql_flexible_server.ifrc.fqdn
    DJANGO_DB_NAME = local.go_api_db_name
    DJANGO_DB_PORT = "5432"
  }

  vault_admin_ids = [
    local.user_principal_ids.tc_navin,
    local.user_principal_ids.tc_sushil,
  ]

  storage_config = {
    # NOTE: Both are read anonymously: the application hands out plain blob URLs for media, and Django templates point at the static container directly.
    container_refs = [
      {
        container_ref = "media"
        access_type   = "blob"
      },
      {
        container_ref = "static"
        access_type   = "blob"
      }
    ]

    enabled            = true
    storage_account_id = azurerm_storage_account.app_storage.id
  }

  vault_subnet_ids = [azurerm_subnet.app.id]
}
