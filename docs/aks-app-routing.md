# AKS App Routing Add-on

**Status:** removed on 2026-09-28. Traefik is now the only ingress controller.

## Intro

An ingress controller takes web traffic from the internet and sends it to the right app in the cluster.

We moved from nginx to traefik. After the move, we found a second nginx still running in the cluster. It was not ours. Azure had created it through the AKS "app routing" add-on.

This doc explains what that add-on was, how we checked that nobody used it, and how we removed it.

## What it was

An AKS add-on where Azure runs nginx for you. It came with:

- **nginx** in `app-routing-system`, with its own public IP (`98.64.179.202`)
- **external-dns**, which wrote records into a linked Azure DNS zone
- IngressClass `webapprouting.kubernetes.azure.com`

It was turned on in `main.tf`, with no helm chart:

```hcl
web_app_routing {
  dns_zone_id = azurerm_dns_zone.ifrc.id
}
```

## History

| Date | What happened |
|---|---|
| 2024-10-07 | Turned on (`38c0691`) |
| 2026-06-15 | Block removed from `main.tf` (`9a677c2`). Azure turned the add-on off, but left its objects in the cluster |
| 2026-09-28 | Leftovers found and deleted |

## Why it was safe to remove

Azure showed `webAppRouting.enabled: false`:

```bash
az aks show -g ifrctgos002rg -n go-playground-cluster --subscription "IFRC Non-Prod" --query "ingressProfile.webAppRouting" -o json
```

Leftovers still running in the cluster:

```bash
kubectl get pods -A | grep -iE 'nginx|traefik'
kubectl get deploy -n app-routing-system
kubectl get svc -n app-routing-system
kubectl get ingressclass
kubectl get nginxingresscontroller -A
```

No ingress used its class:

```bash
kubectl get ingress -A -o 'custom-columns=NS:.metadata.namespace,NAME:.metadata.name,CLASS:.spec.ingressClassName,HOSTS:.spec.rules[*].host,ADDR:.status.loadBalancer.ingress[0].ip'
```

No record in the Azure `ifrc.org` zone pointed at `98.64.179.202`:

```bash
az network dns record-set a list -g ifrctgos002rg -z ifrc.org --subscription "IFRC Non-Prod" --query "[?contains(to_string(ARecords), '98.64.179.202')].fqdn" -o tsv
```

The nginx logs showed only bots, all getting 400:

```bash
kubectl logs -n app-routing-system deploy/nginx --since=24h | tail -20
```

external-dns was crash-looping (`Identity not found`), so it could not touch DNS:

```bash
kubectl logs -n app-routing-system deploy/external-dns --tail=20
```

What the cleanup would delete (owner references and finalizers):

```bash
kubectl get deploy nginx -n app-routing-system -o jsonpath='{.metadata.labels}{"\n"}{.metadata.ownerReferences}{"\n"}'
kubectl get deploy external-dns -n app-routing-system -o jsonpath='{.metadata.ownerReferences}{"\n"}'
kubectl get nginxingresscontroller default -o jsonpath='{.metadata.finalizers}{"\n"}{.status}{"\n"}'
```

## Cleanup that was run

```bash
kubectl delete deploy external-dns -n app-routing-system
kubectl delete nginxingresscontroller default --dry-run=server
kubectl delete nginxingresscontroller default
kubectl get all -n app-routing-system
kubectl get ingressclass
kubectl delete ns app-routing-system
kubectl delete crd nginxingresscontrollers.approuting.kubernetes.azure.com
```

`az aks approuting disable` was not needed, because the add-on was already off. Terraform needs no change either.
