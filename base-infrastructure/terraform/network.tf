resource "azurerm_virtual_network" "app" {
  name                = "go-${var.environment}-cluster-network"
  address_space       = ["10.0.0.0/8"]
  location            = data.azurerm_resource_group.go_resource_group.location
  resource_group_name = data.azurerm_resource_group.go_resource_group.name
}

resource "azurerm_subnet" "app" {
  name                 = "go-${var.environment}-cluster-subnet"
  address_prefixes     = ["10.1.0.0/16"]
  resource_group_name  = data.azurerm_resource_group.go_resource_group.name
  service_endpoints    = ["Microsoft.KeyVault"]
  virtual_network_name = azurerm_virtual_network.app.name
}

resource "azurerm_subnet" "database" {
  name                 = "go-${var.environment}-postgres-subnet"
  resource_group_name  = data.azurerm_resource_group.go_resource_group.name
  virtual_network_name = azurerm_virtual_network.app.name
  address_prefixes     = ["10.2.0.0/16"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# Create private dns zone for postgresql
resource "azurerm_private_dns_zone" "postgres" {
  name                = "${var.environment}.postgres.database.azure.com"
  resource_group_name = data.azurerm_resource_group.go_resource_group.name
}

# Create vitual network link
resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "go-${var.environment}-postgres-vnet-zone"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.app.id
  resource_group_name   = data.azurerm_resource_group.go_resource_group.name

  depends_on = [
    azurerm_subnet.database
  ]
}

## Route Table
#resource "azurerm_route_table" "aks_route_table" {
#  name                = "go-${var.environment}-aks-route-table"
#  location            = data.azurerm_resource_group.go_resource_group.location
#  resource_group_name = data.azurerm_resource_group.go_resource_group.name
#
#  route {
#    name           = "internet"
#    address_prefix = "0.0.0.0/0"
#    next_hop_type  = "Internet"
#  }
#}
#
## Associate Route Table with Subnet
#resource "azurerm_subnet_route_table_association" "aks_subnet_route_table_association" {
#  subnet_id      = azurerm_subnet.playground.id
#  route_table_id = azurerm_route_table.aks_route_table.id
#}
#
## Network Security Group
#resource "azurerm_network_security_group" "aks_nsg" {
#  name                = "aks-nsg"
#  location            = data.azurerm_resource_group.go_resource_group.location
#  resource_group_name = data.azurerm_resource_group.go_resource_group.name
#
#  security_rule {
#    name                       = "allow_all_inbound"
#    priority                   = 100
#    direction                  = "Inbound"
#    access                     = "Allow"
#    protocol                   = "*"
#    source_port_range          = "*"
#    destination_port_range     = "*"
#    source_address_prefix      = "*"
#    destination_address_prefix = "*"
#  }
#
#  security_rule {
#    name                       = "allow_all_outbound"
#    priority                   = 100
#    direction                  = "Outbound"
#    access                     = "Allow"
#    protocol                   = "*"
#    source_port_range          = "*"
#    destination_port_range     = "*"
#    source_address_prefix      = "*"
#    destination_address_prefix = "*"
#  }
#}
#
## Associate NSG with Subnet
#resource "azurerm_subnet_network_security_group_association" "aks_subnet_nsg_association" {
#  subnet_id                 = azurerm_subnet.playground.id
#  network_security_group_id = azurerm_network_security_group.aks_nsg.id
#}
