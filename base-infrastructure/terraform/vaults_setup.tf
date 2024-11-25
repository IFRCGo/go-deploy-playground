#module "secrets" {
#  source = "./modules/app_vault"
#
#  app_name                = "risk-module"
#  cluster_namespace       = "ifrcgo-risk-module"
#  cluster_oidc_issuer_url = azurerm_kubernetes_cluster.go_kubernetes_cluster.oidc_issuer_url
#  environment             = var.environment
#  resource_group_name     = data.azurerm_resource_group.go_resource_group.name
#
#  secrets = {
#    DATABASE_PASSWORD          = ""
#    DJANGO_SECRET_KEY          = ""
#    METEOSWISS_S3_ACCESS_KEY   = ""
#    METEOSWISS_S3_BUCKET       = ""
#    METEOSWISS_S3_ENDPOINT_URL = ""
#    METEOSWISS_S3_SECRET_KEY   = ""
#    PDC_ACCESS_TOKEN           = ""
#    PDC_PASSWORD               = ""
#    PDC_USERNAME               = ""
#    SENTRY_DSN                 = ""
#  }
#
#  vault_subnet_ids = [azurerm_subnet.app.id]
#}
#
#module "alert_hub_vault" {
#  source = "./modules/app_vault"
#
#  app_name                = "alert-hub"
#  cluster_namespace       = "alert-hub"
#  cluster_oidc_issuer_url = azurerm_kubernetes_cluster.go_kubernetes_cluster.oidc_issuer_url
#  environment             = var.environment
#  resource_group_name     = data.azurerm_resource_group.go_resource_group.name
#  service_account_name    = "alert-hub-sa"
#  vault_subnet_ids = [azurerm_subnet.app.id]
#}