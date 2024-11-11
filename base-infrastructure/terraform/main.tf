provider "azurerm" {
  features {}

  skip_provider_registration = true
}

resource "azurerm_dns_zone" "ifrc" {
  name                = "ifrc.org"
  resource_group_name = data.azurerm_resource_group.go_resource_group.name
}

resource "azurerm_kubernetes_cluster" "go_kubernetes_cluster" {
  name                = "go-${var.environment}-cluster"
  location            = data.azurerm_resource_group.go_resource_group.location
  resource_group_name = data.azurerm_resource_group.go_resource_group.name
  dns_prefix          = "go-${var.environment}-cluster"

  default_node_pool {
    name                = "default"
    enable_auto_scaling = true
    max_count           = 1
    min_count           = 1
    node_count          = 1

    upgrade_settings {
      max_surge = "10%"
    }

    vm_size        = "Standard_A2_v2"
    vnet_subnet_id = azurerm_subnet.app.id
  }

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "1m"
  }

  oidc_issuer_enabled               = true
  private_cluster_enabled           = false
  role_based_access_control_enabled = true

  tags = {
    Environment = var.environment
    ManagedBy   = "IFRCGo"
  }

  web_app_routing {
    dns_zone_id = azurerm_dns_zone.ifrc.id
  }

  workload_identity_enabled = true
}

locals {
  cluster_namespace    = "default"
  service_account_name = "service-token-reader"
}

resource "azurerm_federated_identity_credential" "cred" {
  name                = "go-${var.environment}-reader-identity"
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.go_kubernetes_cluster.oidc_issuer_url
  parent_id           = module.secrets.workload_id
  resource_group_name = data.azurerm_resource_group.go_resource_group.name
  subject             = "system:serviceaccount:${local.cluster_namespace}:${local.service_account_name}"
}

module "secrets" {
  source = "./modules/app_vault"

  app_name            = "risk-module"
  environment         = var.environment
  resource_group_name = data.azurerm_resource_group.go_resource_group.name

  secrets = {
    DATABASE_PASSWORD          = "tf-new-database-password"
    DJANGO_SECRET_KEY          = "tf-secret-key"
    METEOSWISS_S3_ACCESS_KEY   = "tf-access-adjusted-key"
    METEOSWISS_S3_BUCKET       = "tf-some-bucket"
    METEOSWISS_S3_ENDPOINT_URL = "tf-some-s3-endpoint-url"
    METEOSWISS_S3_SECRET_KEY   = "tf-secret-key"
    PDC_ACCESS_TOKEN           = "tf-pdc-access-token"
    PDC_PASSWORD               = "tf-pdc-password"
    PDC_USERNAME               = "tf-pdc-username"
  }
}
