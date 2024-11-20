module "secrets" {
  source = "./modules/app_vault"

  app_name            = "risk-module"
  environment         = var.environment
  resource_group_name = data.azurerm_resource_group.go_resource_group.name

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
}

module "alert_hub_vault" {
  source = "./modules/app_vault"

  app_name            = "alert-hub"
  environment         = var.environment
  resource_group_name = data.azurerm_resource_group.go_resource_group.name

  secrets = {}
}