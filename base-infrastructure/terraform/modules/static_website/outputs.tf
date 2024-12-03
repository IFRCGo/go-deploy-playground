# Outputs for GitHub Actions secrets
output "azure_client_id" {
  value     = azuread_application.github_actions.application_id
  sensitive = true
}

output "azure_tenant_id" {
  value     = data.azurerm_client_config.current.tenant_id
  sensitive = true
}

output "azure_subscription_id" {
  value     = data.azurerm_client_config.current.subscription_id
  sensitive = true
}