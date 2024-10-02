provider "azurerm" {
  features {}

  skip_provider_registration = true
}

resource "azurerm_kubernetes_cluster" "go_kubernetes_cluster" {
  name                = "go-${var.environment}-aks"
  location            = data.azurerm_resource_group.go_resource_group.location
  resource_group_name = data.azurerm_resource_group.go_resource_group.name
  dns_prefix          = "go-${var.environment}-aks"

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_A2_v2"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 1

    upgrade_settings {
      max_surge = "10%"
    }
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

  workload_identity_enabled = true
}
#
#resource "azurerm_kubernetes_cluster_node_pool" "new_default" {
#  name                  = "newdefault"
#  kubernetes_cluster_id = azurerm_kubernetes_cluster.go_kubernetes_cluster.id
#  vm_size               = "Standard_A2_v2"
#  node_count            = 1
#  vnet_subnet_id        = azurerm_subnet.playground.id
#
#  tags = {
#    Environment = var.environment
#  }
#}

#resource "azurerm_federated_identity_credential" "cred" {
#  name                = "go-${var.environment}-reader-identity"
#  audience            = ["api://AzureADTokenExchange"]
#  issuer              = azurerm_kubernetes_cluster.go_kubernetes_cluster.oidc_issuer_url
#  parent_id           = module.secrets.workload_id
#  resource_group_name = data.azurerm_resource_group.go_resource_group.name
#  subject             = "system:serviceaccount:default:service-token-reader"
#}

module "secrets" {
  source = "./modules/app_vault"

  app_name            = "risk-module"
  environment         = var.environment
  resource_group_name = data.azurerm_resource_group.go_resource_group.name

  secrets = {
    DATABASE_PASSWORD        = "tf-database-password"
    DJANGO_SECRET_KEY        = "tf-secret-key"
    METEOSWISS_S3_ACCESS_KEY = "tf-access-key"
    METEOSWISS_S3_BUCKET     = "tf-some-bucket"
    METEOSWISS_S3_SECRET_KEY = "tf-secret-key"
    PDC_ACCESS_TOKEN         = "tf-pdc-access-token"
    PDC_PASSWORD             = "tf-pdc-password"
  }
}