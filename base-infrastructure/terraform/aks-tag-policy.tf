# Resources Kubernetes creates at runtime in the AKS node resource group (PVC disks,
# NICs, load balancer IPs) carry no terraform tags. One policy assignment per tag
# adds it to any resource there that lacks it.
data "azurerm_policy_definition" "add_tag" {
  display_name = "Add a tag to resources"
}

resource "azurerm_resource_group_policy_assignment" "aks_node_tag" {
  for_each = local.aks_tags

  name                 = "aks-node-tag-${lower(each.key)}"
  resource_group_id    = azurerm_kubernetes_cluster.go_kubernetes_cluster.node_resource_group_id
  policy_definition_id = data.azurerm_policy_definition.add_tag.id
  location             = data.azurerm_resource_group.go_resource_group.location

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    tagName  = { value = each.key }
    tagValue = { value = each.value }
  })
}

# The Modify effect writes the tag as the assignment's identity.
resource "azurerm_role_assignment" "aks_node_tag" {
  for_each = azurerm_resource_group_policy_assignment.aks_node_tag

  scope                = azurerm_kubernetes_cluster.go_kubernetes_cluster.node_resource_group_id
  role_definition_name = "Tag Contributor"
  principal_id         = each.value.identity[0].principal_id

  # The identity is created in this same apply, and entra takes a moment to
  # replicate it. Without this the first apply intermittently fails PrincipalNotFound.
  skip_service_principal_aad_check = true
}

# The assignment only acts on new and updated resources. Remediation tags the ones
# that already exist.
resource "azurerm_resource_group_policy_remediation" "aks_node_tag" {
  for_each = azurerm_resource_group_policy_assignment.aks_node_tag

  name                    = "aks-node-tag-${lower(each.key)}"
  resource_group_id       = azurerm_kubernetes_cluster.go_kubernetes_cluster.node_resource_group_id
  policy_assignment_id    = each.value.id
  resource_discovery_mode = "ReEvaluateCompliance"

  depends_on = [azurerm_role_assignment.aks_node_tag]
}
