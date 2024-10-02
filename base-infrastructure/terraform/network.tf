resource "azurerm_virtual_network" "playground" {
  name                = "go-${var.environment}-aks-vnet"
  address_space       = ["10.0.0.0/8"]
  location            = data.azurerm_resource_group.go_resource_group.location
  resource_group_name = data.azurerm_resource_group.go_resource_group.name
}

resource "azurerm_subnet" "playground" {
  name                 = "go-${var.environment}-aks-subnet"
  virtual_network_name = azurerm_virtual_network.playground.name
  address_prefixes     = ["10.1.0.0/16"]
  resource_group_name  = data.azurerm_resource_group.go_resource_group.name
  service_endpoints    = ["Microsoft.KeyVault"]
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