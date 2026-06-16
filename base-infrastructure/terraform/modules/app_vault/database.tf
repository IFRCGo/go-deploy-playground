# TODO(susilnem): We might need to check and validate database name already exists or not.
# NOTE: Something like this?

# data "azurerm_postgresql_flexible_server_database" "existing" {
#   count     = var.database_server_id == null ? 0 : 1
#   name      = var.database_name != null ? var.database_name : local.app_database_name
#   server_id = var.database_server_id
# }

# resource "azurerm_postgresql_flexible_server_database" "app" {
#   count = var.database_server_id == null ? 0 : (
#     length(data.azurerm_postgresql_flexible_server_database.existing) > 0 ? 0 : 1
#   )

#   name      = var.database_name != null ? var.database_name : local.app_database_name
#   server_id = var.database_server_id
#   collation = "en_US.utf8"
#   charset   = "utf8"

#   lifecycle {
#     prevent_destroy = true
#     precondition {
#       condition = can(regex("^[a-z][a-z0-9_-]{0,62}$",
#         var.database_name != null ? var.database_name : local.app_database_name
#       ))
#       error_message = "Database name must start with a letter and can only contain lowercase letters, numbers, underscores, or hyphens, and be between 1 and 63 characters long."
#     }
#   }
# }

locals {
  app_database_name = "${var.app_name}${var.environment}db"
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  count = var.database_server_id == null ? 0 : 1

  name      = var.database_name != null ? var.database_name : local.app_database_name
  server_id = var.database_server_id
  collation = "en_US.utf8"
  charset   = "utf8"

  lifecycle {
    prevent_destroy = false
  }
}

#resource "azurerm_key_vault_secret" "db_name" {
#  name         = "DATABASE-NAME"
#  value        = local.app_database_name
#  key_vault_id = azurerm_key_vault.app_kv.id
#
#  # Ensure secret is deleted before creating identity loses permission to do so
#  depends_on = [
#    azurerm_role_assignment.key_vault_admin,
#  ]
#
#  lifecycle {
#    ignore_changes = all
#  }
#}
