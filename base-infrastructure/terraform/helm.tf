provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.go_kubernetes_cluster.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.go_kubernetes_cluster.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.go_kubernetes_cluster.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.go_kubernetes_cluster.kube_config.0.cluster_ca_certificate)
  }
}

resource "helm_release" "argo-cd" {
  name             = "argo-cd"
  chart            = "argo-cd"
  create_namespace = true

  depends_on = [
    azurerm_kubernetes_cluster.go_kubernetes_cluster
  ]

  repository = "https://argoproj.github.io/argo-helm"
  namespace  = "argocd"
  version    = "7.6.7"

  values = [
    yamlencode({
      configs = {
        cm = {
          "timeout.reconciliation": "60s"  
        }
      }
    })
  ]
}

#resource "helm_release" "argo_cd_image_updater" {
#  depends_on = [helm_release.argo_cd]
#  name       = "argocd-image-updater"
#  chart      = "argocd-image-updater"
#  repository = "https://argoproj.github.io/argo-helm"
#  version    = "0.9.1"
#  namespace  = "argocd"
#
#  values = [
#    "${file("${path.module}/${local.image_updater_values_file}")}"
#  ]
#}

#resource "helm_release" "go-ingress-nginx" {
#  name             = "ingress-nginx"
#  repository       = "https://kubernetes.github.io/ingress-nginx"
#  chart            = "ingress-nginx"
#  version          = "4.8.3"
#  namespace        = "ingress-nginx"
#  create_namespace = true
#  depends_on       = [azurerm_kubernetes_cluster.go_kubernetes_cluster]
#}

#resource "helm_release" "go-cert-manager" {
#  name             = "cert-manager"
#  repository       = "https://charts.jetstack.io"
#  chart            = "cert-manager"
#  version          = "v1.13.2"
#  namespace        = "cert-manager"
#  create_namespace = true
#
#  set {
#    name  = "installCRDs"
#    value = true
#  }
#
#  depends_on = [azurerm_kubernetes_cluster.go_kubernetes_cluster]
#}