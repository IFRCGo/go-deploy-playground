provider "azurerm" {
  features {}

  skip_provider_registration = true
}

data "azurerm_resource_group" "go_resource_group" {
  name = "ifrctgos002rg"
}

resource "azurerm_kubernetes_cluster" "go_kubernetes_cluster" {
  name                = "go-${var.environment}-aks"
  location            = data.azurerm_resource_group.go_resource_group.location
  resource_group_name = data.azurerm_resource_group.go_resource_group.name
  dns_prefix          = "go-${var.environment}-aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_A2_v2"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 1
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "IFRCGo"
  }
}

