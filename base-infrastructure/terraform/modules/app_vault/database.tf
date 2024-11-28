locals {
  app_database_name = "${var.app_name}${var.environment}db"
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = local.app_database_name
  server_id = var.database_server_id
  collation = "en_US.utf8"
  charset   = "utf8"

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_key_vault_secret" "db_name" {
  name         = "DATABASE-NAME"
  value        = local.app_database_name
  key_vault_id = azurerm_key_vault.app_kv.id

  # Ensure secret is deleted before creating identity loses permission to do so
  depends_on = [
    azurerm_role_assignment.key_vault_admin,
  ]

  lifecycle {
    ignore_changes = all
  }
}