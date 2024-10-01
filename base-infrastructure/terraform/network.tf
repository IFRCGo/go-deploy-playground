resource "azurerm_virtual_network" "playground" {
  name                = "go-playground-aks-vnet"
  address_space       = ["10.1.0.0/8"]
  location            = data.azurerm_resource_group.go_resource_group.location
  resource_group_name = data.azurerm_resource_group.go_resource_group.name
}

resource "azurerm_subnet" "playground" {
  name                 = "go-playground-aks-subnet"
  virtual_network_name = azurerm_virtual_network.playground.name
  address_prefixes     = ["10.1.0.0/16"]
  resource_group_name  = data.azurerm_resource_group.go_resource_group.name
  service_endpoints    = ["Microsoft.KeyVault"]
}