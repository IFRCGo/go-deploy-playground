provider "azurerm" {
  features {}

  resource_provider_registrations = "none"
}

resource "azurerm_dns_zone" "ifrc" {
  name                = "ifrc.org"
  resource_group_name = data.azurerm_resource_group.go_resource_group.name
}

resource "azurerm_kubernetes_cluster" "go_kubernetes_cluster" {
  name                 = "go-${var.environment}-cluster"
  location             = data.azurerm_resource_group.go_resource_group.location
  resource_group_name  = data.azurerm_resource_group.go_resource_group.name
  azure_policy_enabled = true
  dns_prefix           = "go-${var.environment}-cluster"

  default_node_pool {
    name                        = "default"
    auto_scaling_enabled        = true
    max_count                   = 5
    min_count                   = 1
    temporary_name_for_rotation = "tempdefault"

    upgrade_settings {
      max_surge = "10%"
    }

    vm_size        = "Standard_A4_v2"
    vnet_subnet_id = azurerm_subnet.app.id
  }

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "1m"
  }

  # Nodes take Azure's weekly OS image upgrades.
  node_os_upgrade_channel = "NodeImage"

  oidc_issuer_enabled               = true
  private_cluster_enabled           = false
  role_based_access_control_enabled = true

  tags = {
    Environment = var.environment
    ManagedBy   = "IFRCGo"
  }

  # Inert while `force_upgrade_enabled` is false, but the provider rejects removing the
  # block once the cluster carries it.
  upgrade_override {
    force_upgrade_enabled = false
  }

  workload_identity_enabled = true
}

resource "azurerm_role_assignment" "network" {
  scope                = data.azurerm_resource_group.go_resource_group.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.go_kubernetes_cluster.identity[0].principal_id
}
