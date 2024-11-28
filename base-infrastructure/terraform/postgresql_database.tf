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

resource "azurerm_postgresql_flexible_server_firewall_rule" "vnet_rule" {
  name             = "go-${var.environment}-psql-vnet-access-fw-rule"
  server_id        = azurerm_postgresql_flexible_server.ifrc.id
  start_ip_address = cidrhost(azurerm_virtual_network.app.address_space[0], 0)
  end_ip_address   = cidrhost(azurerm_virtual_network.app.address_space[0], -1)
}

# For a D2s_v3 (8GB RAM) instance
resource "azurerm_postgresql_flexible_server_configuration" "effective_cache_size" {
  name      = "effective_cache_size"
  server_id = azurerm_postgresql_flexible_server.ifrc.id
  value     = "6144000" # 6GB - About 75% of total RAM
}

resource "azurerm_postgresql_flexible_server_configuration" "shared_buffers" {
  name      = "shared_buffers"
  server_id = azurerm_postgresql_flexible_server.ifrc.id
  value     = "2097152" # 2GB - About 25% of total RAM
}

resource "azurerm_postgresql_flexible_server_configuration" "work_mem" {
  name      = "work_mem"
  server_id = azurerm_postgresql_flexible_server.ifrc.id
  value     = "32768" # 32MB - (8GB - 2GB shared_buffers) / (16 * 2 vCPUs)
}

resource "azurerm_postgresql_flexible_server_configuration" "maintenance_work_mem" {
  name      = "maintenance_work_mem"
  server_id = azurerm_postgresql_flexible_server.ifrc.id
  value     = "524288" # 512MB - About 6.4% of RAM
}

# Additional recommended settings for performance
resource "azurerm_postgresql_flexible_server_configuration" "random_page_cost" {
  name      = "random_page_cost"
  server_id = azurerm_postgresql_flexible_server.ifrc.id
  value     = "1.1" # Lower value for SSD storage
}

resource "azurerm_postgresql_flexible_server_configuration" "effective_io_concurrency" {
  name      = "effective_io_concurrency"
  server_id = azurerm_postgresql_flexible_server.ifrc.id
  value     = "200" # Higher value for SSD storage
}

resource "azurerm_postgresql_flexible_server_configuration" "max_parallel_workers" {
  name      = "max_parallel_workers"
  server_id = azurerm_postgresql_flexible_server.ifrc.id
  value     = "2" # Equal to number of vCPUs
}

resource "azurerm_postgresql_flexible_server_configuration" "max_parallel_workers_per_gather" {
  name      = "max_parallel_workers_per_gather"
  server_id = azurerm_postgresql_flexible_server.ifrc.id
  value     = "1" # Half of max_parallel_workers
}