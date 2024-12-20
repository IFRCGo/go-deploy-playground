# Create random string for unique storage account name
resource "random_string" "random" {
  length  = 6
  special = false # Exclude special characters
  upper   = false # Exclude uppercase letters
  numeric = true  # Include numbers
  lower   = true  # Include lowercase letters
}

locals {
  sanitized_app_name         = lower(replace(var.app_name, "/[^a-zA-Z0-9]/", ""))
  sanitized_app_name_trimmed = length(local.sanitized_app_name) > 18 ? substr(local.sanitized_app_name, 0, 18) : local.sanitized_app_name
  storage_account_name       = "${local.sanitized_app_name_trimmed}${random_string.random.result}"
}

# Create Storage Account
resource "azurerm_storage_account" "static_site" {
  name = local.storage_account_name

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