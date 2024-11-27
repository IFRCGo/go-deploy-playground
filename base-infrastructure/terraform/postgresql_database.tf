resource "random_password" "db_admin" {
  length  = 16
  special = true

  lifecycle {
    create_before_destroy = true
  }
}

# PostgreSQL Server Configuration
resource "azurerm_postgresql_flexible_server" "ifrc" {
  name                   = "ifrc-${var.environment}-psql-flexible-server"
  resource_group_name    = data.azurerm_resource_group.go_resource_group.name
  location               = data.azurerm_resource_group.go_resource_group.location
  version                = "13"
  administrator_login    = var.psql_administrator_login
  administrator_password = random_password.db_admin.result
  backup_retention_days  = 35
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  delegated_subnet_id    = azurerm_subnet.database.id
  private_dns_zone_id    = azurerm_private_dns_zone.postgres.id
  zone                   = 1

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.postgres
  ]
}