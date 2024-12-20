# Create random string for unique storage account name
resource "random_string" "random" {
  length  = 6
  special = false # Exclude special characters
  upper   = false # Exclude uppercase letters
  numeric = true  # Include numbers
  lower   = true  # Include lowercase letters
}

locals {
  storage_account_name = "${random_string.random.result}${lower(replace(var.app_name, "[^a-zA-Z0-9]", ""))}"
  storage_account_name_trimmed = trimspace(replace(
    length(local.storage_account_name) > 24 ? substr(local.storage_account_name, 0, 24) : local.storage_account_name,
    "/-+$/", ""
  ))
}

# Create Storage Account
resource "azurerm_storage_account" "static_site" {
  name = local.storage_account_name_trimmed

  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  static_website {
    index_document     = "index.html"
    error_404_document = "index.html"
  }

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }
}

# Create CDN Profile
resource "azurerm_cdn_profile" "static_site" {
  name                = "static-site-cdn-profile"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard_Microsoft"
}

# Create CDN Endpoint
resource "azurerm_cdn_endpoint" "static_site" {
  name                = "static-site-cdn-endpoint"
  profile_name        = azurerm_cdn_profile.static_site.name
  location            = var.location
  resource_group_name = var.resource_group_name

  origin {
    name      = "static-site-origin"
    host_name = replace(replace(azurerm_storage_account.static_site.primary_web_endpoint, "https://", ""), "/", "")
  }

  delivery_rule {
    name  = "EnforceHTTPS"
    order = 1

    request_scheme_condition {
      operator     = "Equal"
      match_values = ["HTTP"]
    }

    url_redirect_action {
      redirect_type = "Found"
      protocol      = "Https"
    }
  }
}