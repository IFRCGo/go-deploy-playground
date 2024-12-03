# Create Azure AD Application
resource "azuread_application" "github_actions" {
  display_name = "${var.app_name}-github-actions-app"

  owners = [
    data.azuread_client_config.current.object_id
  ]
}

# Create Service Principal
resource "azuread_service_principal" "github_actions" {
  #application_id = azuread_application.github_actions.application_id
  client_id                    = azuread_application.github_actions.client_id
  app_role_assignment_required = false

  owners = [
    data.azuread_client_config.current.object_id
  ]
}

# Create Federated Identity Credential for GitHub OIDC
#resource "azuread_application_federated_identity_credential" "github_actions" {
#  application_object_id = azuread_application.github_actions.object_id
#  display_name         = "github-actions-federated"
#  description          = "GitHub Actions federated credential"
#  audiences           = ["api://AzureADTokenExchange"]
#  issuer              = "https://token.actions.githubusercontent.com"
#  subject             = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
#}

resource "azuread_application_federated_identity_credential" "github_actions_deploy_credential" {
  application_id = azuread_application.github_actions.id
  display_name   = "${var.app_name}-${var.environment}-repo-deploy"
  description    = "Deployments for ${var.app_name}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${var.github_org}/${var.github_repo}:environment:${var.environment}"
}

# Assign Contributor role to Service Principal at Resource Group level
#resource "azurerm_role_assignment" "contributor" {
#  #scope                = azurerm_resource_group.static_site.id
#  scope                = var.resource_group_id
#  role_definition_name = "Contributor"
#  principal_id         = azuread_service_principal.github_actions.object_id
#}

# Assign Storage Blob Data Contributor role
resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = azurerm_storage_account.static_site.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# Assign CDN Endpoint Contributor role
resource "azurerm_role_assignment" "cdn_endpoint_contributor" {
  scope                = azurerm_cdn_profile.static_site.id
  role_definition_name = "CDN Endpoint Contributor"
  principal_id         = azuread_service_principal.github_actions.object_id
}