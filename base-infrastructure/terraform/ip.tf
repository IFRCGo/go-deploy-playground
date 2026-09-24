# Traefik Public IP
resource "azurerm_public_ip" "traefik" {

  lifecycle {
    ignore_changes = all
  }

  name                = "go-${var.environment}-traefik-ip"
  resource_group_name = data.azurerm_resource_group.go_resource_group.name
  location            = data.azurerm_resource_group.go_resource_group.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
  }
}

# Cluster egress Public IP (see main.tf network_profile). Every node SNATs outbound traffic
# through it. Owned here instead of AKS's node resource group so it survives a cluster
# recreation and can be handed out for allowlisting.
resource "azurerm_public_ip" "egress" {
  name                = "go-${var.environment}-egress-ip"
  resource_group_name = data.azurerm_resource_group.go_resource_group.name
  location            = data.azurerm_resource_group.go_resource_group.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
  }
}

# SSH bastion Public IP (see bastion.tf) — reserved so the bastion endpoint stays stable
# across recreations of the Service.
resource "azurerm_public_ip" "bastion" {
  name                = "go-${var.environment}-bastion-ip"
  resource_group_name = data.azurerm_resource_group.go_resource_group.name
  location            = data.azurerm_resource_group.go_resource_group.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
  }
}
