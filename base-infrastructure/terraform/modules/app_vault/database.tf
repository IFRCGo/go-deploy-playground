resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = "${var.app_name}db"
  server_id = var.database_server_id
  collation = "en_US.utf8"
  charset   = "utf8"

  lifecycle {
    prevent_destroy = false
  }
}