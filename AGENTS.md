# Agent instructions

## Azure resource tags

Terraform root: `base-infrastructure/terraform`.

- Base tags are defined once in `base-infrastructure/terraform/tags.tf` as `local.base_tags` (`DeployedBy`, `Owner`, `Contact`, `Service`, `Ticket`, and `Environment` from `var.environment`). Change tag values only in `tags.tf`.
- Each new Azure resource in the root that supports `tags` must set `tags = local.base_tags`, or `merge(local.base_tags, {...})` for extra keys. The root has no `var.tags`. azurerm has no provider-level default tags, so a resource without a `tags` argument is untagged.
- The AKS cluster and its default node pool use `local.aks_tags` (`local.base_tags` plus `ManagedBy`), defined in `main.tf`.
- Each module in `base-infrastructure/terraform/modules/` (`app_vault`, `registry`, `static_website`) has a required `tags` input and sets `tags = var.tags` on each taggable resource (not on Key Vault secrets). Each module call in the root passes `tags = local.base_tags`. A new module takes the same required `tags` variable.
- Resources Kubernetes creates in the AKS node resource group (PVC disks and others) get their tags from Azure Policy assignments in `base-infrastructure/terraform/aks-tag-policy.tf`: one "Add a tag to resources" assignment per tag in `local.aks_tags`.
- Resources this Terraform does not manage are tagged by hand with `az tag update --operation Merge`: the resource group `ifrctgos002rg` (a data source here), the Terraform state storage account `gosandbox1`, and `azurerm_public_ip.traefik` (`ignore_changes = all`).
