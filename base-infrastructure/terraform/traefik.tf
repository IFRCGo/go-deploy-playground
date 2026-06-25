resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  version          = "40.2.0"
  namespace        = "traefik"
  create_namespace = true

  depends_on = [
    azurerm_public_ip.traefik,
    azurerm_kubernetes_cluster.go_kubernetes_cluster,
  ]

  values = [yamlencode({
    deployment = {
      replicas = 1
    }

    service = {
      annotations = {
        "service.beta.kubernetes.io/azure-load-balancer-resource-group"            = data.azurerm_resource_group.go_resource_group.name
        "service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path" = "/ping"
      }
      spec = {
        loadBalancerIP        = azurerm_public_ip.traefik.ip_address
        externalTrafficPolicy = "Local"
      }
    }

    ingressClass = {
      enabled = true
      # NOTE: Keep false until nginx is fully removed
      isDefaultClass = false
    }

    providers = {
      kubernetesIngress = {
        # TODO: remove after all ingress manifests are updated to ingressClassName: traefik and ClusterIssuer solver is switched
        ingressClass = "nginx"
      }
      kubernetesIngressNGINX = {
        enabled = true
      }
    }

    # Replaces nginx: use-forwarded-headers, real-ip-header, set-real-ip-from
    # Trust X-Forwarded-For only from the AKS subnet (10.1.0.0/16)
    ports = {
      web = {
        http = {
          redirections = {
            entryPoint = {
              to        = "websecure"
              scheme    = "https"
              permanent = true
            }
          }
        }
        forwardedHeaders = {
          trustedIPs = [local.aks_subnet_cidr]
        }
      }
      websecure = {
        forwardedHeaders = {
          trustedIPs = [local.aks_subnet_cidr]
        }
      }
    }

    logs = {
      access = {
        enabled = true
      }
    }

    # Not exposing dashboard on plain HTTP
    api = {
      insecure = false
    }

  })]
}
