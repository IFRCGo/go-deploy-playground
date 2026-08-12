# SSH bastion — cluster-wide access jump host.
# This is cluster access infrastructure (not tied to any single application), so it lives
# here in base-infrastructure rather than in an application Helm chart. The Kubernetes
# resources are defined by the local chart at base-infrastructure/charts/ssh-bastion and
# applied via this helm_release (matching how the other cluster components — traefik,
# argocd, cert-manager, etc. — are deployed).
#
# NOTE: after editing anything under charts/ssh-bastion, bump the chart `version` in
# Chart.yaml so the helm provider detects the change and redeploys.

resource "helm_release" "bastion" {
  name             = "ssh-bastion"
  namespace        = "bastion"
  create_namespace = true
  chart            = "${path.module}/../charts/ssh-bastion"

  depends_on = [
    azurerm_public_ip.bastion,
    azurerm_kubernetes_cluster.go_kubernetes_cluster,
  ]

  # Cluster/environment-specific values. The chart itself stays cloud-agnostic; anything
  # Azure/AKS-specific (storage class, LB annotations, reserved IP) is injected here.
  values = [yamlencode({
    environment = var.environment
    # Authorized SSH *public* keys. Concatenated into a single, declarative authorized_keys
    # file by the chart — removing an entry here revokes that key's access. This sandbox
    # cluster is limited to the three maintainers who work on it.

    keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN/f/A3qkaTHSdbKn8Hv75YiJvRMEXvWTDdIiR7tyAjJ navin@nav-machine",
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPGAnkQdf5CIpVoqNVJ17AAzUb02gpTltJI5q5SRKxl8 zol@hp",
    ]

    persistence = {
      # AKS built-in RWO managed-disk class.
      storageClass = "managed-csi"
    }
    # Defense-in-depth for the pivot surface: allow the pod to reach only cluster-internal
    # RFC1918 ranges (enough to port-forward to in-cluster services) — the public internet
    # and the cloud metadata endpoint (169.254.169.254) are denied. The chart default
    # egress CIDRs (10/8, 172.16/12, 192.168/16) cover the AKS pod/service ranges. This
    # cluster runs kubenet with no policy engine, so the NetworkPolicy is inert until one
    # is enabled; it is declared so the restriction applies as soon as that happens.
    networkPolicy = {
      enabled = true
    }
    service = {
      # Reserved static IP so the bastion endpoint is stable across recreations.
      loadBalancerIP = azurerm_public_ip.bastion.ip_address
      annotations = {
        "service.beta.kubernetes.io/azure-load-balancer-resource-group" = data.azurerm_resource_group.go_resource_group.name
      }
    }
  })]
}
