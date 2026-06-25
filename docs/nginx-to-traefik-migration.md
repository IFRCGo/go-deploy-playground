# Nginx -> Traefik Migration (Zero Downtime)

## What was set up so far

We deployed **alert-hub** (frontend + backend) on Azure Kubernetes to test the ingress switch.

Here is what was done, in order:

1. **Created two static IPs** — one for nginx, one for traefik. Both are reserved in Azure.
2. **Deployed nginx** as the main ingress, linked to its static IP.
3. **Deployed traefik** next to nginx, on its own IP. It runs but gets no traffic yet.
4. **Deployed alert-hub** using nginx as the ingress. DNS for `alerthub-sandbox.ifrc.org` points to the nginx IP.
5. **Added RabbitMQ operator** and **Azure Blob storage** needed by alert-hub.

Right now: alert-hub works through nginx. Traefik runs but is idle. DNS has pointed to nginx since yesterday.

## Why we are switching

Traefik is the long-term plan. We used nginx first to get alert-hub live fast. Now we move to traefik.

## How we switch (no downtime)

We make traefik ready before we change DNS. That way, the DNS change is the only moment that matters — and traefik is already set up and ready by then.

The key step: tell traefik to also watch `nginx`-class ingresses. Then traefik can serve traffic on its own IP before anyone switches to it.

---

## Phase 1 — Tell Traefik to Watch Nginx Ingresses

> No impact on users. Traefik starts handling ingresses on its own IP.

**1. Add `kubernetesIngress.ingressClass` to `traefik.tf`:**

```tf
providers = {
  kubernetesIngress = {
    ingressClass = "nginx"
  }
  kubernetesIngressNGINX = {
    enabled = true
  }
}
```

**2. Apply terraform:**

```bash
terraform apply
```

**3. Check that traefik serves alert-hub (skip DNS, hit traefik IP directly):**

```bash
TRAEFIK_IP=$(kubectl get svc -n traefik traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Should return 200 or a redirect — not 404
curl -sk -o /dev/null -w "%{http_code}" \
  -H "Host: alerthub-sandbox.ifrc.org" \
  "https://$TRAEFIK_IP"

# Check traefik logs to confirm it is handling requests
kubectl logs -n traefik -l app.kubernetes.io/name=traefik --tail=20
```

---

## Phase 2 — Lower DNS TTL (Day Before the Switch)

> TTL tells DNS clients how long to cache the old IP. Lower it so the switch spreads fast.

**4. Check the current TTL:**

```bash
dig alerthub-sandbox-api.ifrc.org +noall +answer
# Note the TTL number shown
```

**5. Lower TTL to 60 seconds in Azure DNS:**

Go to Azure Portal → DNS Zone `ifrc.org` → A record `alerthub-sandbox` → set TTL to 60.

Do the same for `alerthub-sandbox-api.ifrc.org`.

Then wait for the old TTL to pass before moving on (so old cached values expire).

---

## Phase 3 — Switch DNS (The Actual Cutover)

> Near-zero downtime. Traefik is already warm from Phase 1.

**6. Get both IPs:**

```bash
NGINX_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
TRAEFIK_IP=$(kubectl get svc -n traefik traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "nginx: $NGINX_IP  traefik: $TRAEFIK_IP"
```

**7. Update Azure DNS A records:**

| Record | Old value | New value |
|---|---|---|
| `alerthub-sandbox.ifrc.org` | nginx IP | traefik IP |
| `alerthub-sandbox-api.ifrc.org` | nginx IP | traefik IP |

**8. Watch traefik logs to confirm it gets real traffic:**

```bash
kubectl logs -n traefik -l app.kubernetes.io/name=traefik -f
```

**9. Check HTTPS works via the real domain:**

```bash
curl -sk -o /dev/null -w "%{http_code}" https://alerthub-sandbox.ifrc.org
curl -sk -o /dev/null -w "%{http_code}" https://alerthub-sandbox-api.ifrc.org
```

Expected: `200` or `301/302` (not `000` or `5xx`).

---

## Phase 4 — Clean Up Config

> Update config files to match the new state. No impact on users.

**10. Update the SSL cert issuer to use traefik:**

```bash
kubectl edit clusterissuer letsencrypt-prod
```

Change:
```yaml
solvers:
  - http01:
      ingress:
        ingressClassName: nginx   # change to traefik
```

**11. Update alert-hub ingress files to use traefik:**

Files to update:
- `base-infrastructure/argocd/applications/alert-hub-frontend.yaml`
- `base-infrastructure/argocd/applications/alert-hub-backend.yaml`

Change `ingressClassName: nginx` to `ingressClassName: traefik` in the helm parameters.

ArgoCD will pick up the change and sync on its own.

**12. Make traefik the default ingress in `traefik.tf`:**

```hcl
ingressClass = {
  enabled        = true
  isDefaultClass = true   # change to true
}
```

**13. Remove the `ingressClass = "nginx"` line from traefik providers in `traefik.tf`:**

```hcl
providers = {
  kubernetesIngressNGINX = {
    enabled = true
  }
}
```
---

## Phase 5 — Remove Nginx

> Only do this after traefik has been stable for 24–48 hours.

**16. Check nginx is getting no traffic:**

```bash
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller --tail=50
# Should show no requests
```

**17. Remove nginx:**

Delete the nginx resources from terraform:

- Remove `helm_release.ingress_nginx` from `helm-ingress-nginx.tf` (or delete the whole file)
- Remove `azurerm_public_ip.nginx` from `ip.tf`

---

## If Something Goes Wrong

Point DNS back to the nginx IP. Nginx is still running with all routes set up — the rollback is instant.

Do not delete nginx until you are sure traefik is working well.

---

## Checklist

**Phase 1 — Tell Traefik to Watch Nginx Ingresses**
- [x] `providers.kubernetesIngress.ingressClass = "nginx"` added to `traefik.tf`
- [ ] Traefik serves alert-hub at traefik IP (checked via curl)

**Phase 3 — Switch DNS**
- [ ] DNS A records changed to traefik IP
- [ ] HTTPS checked end-to-end via real domain

**Phase 4 — Clean Up Config**
- [ ] ClusterIssuer updated to `ingressClassName: traefik`
- [ ] Alert-hub ingress files updated to `ingressClassName: traefik`
- [ ] Traefik set as default ingress
- [ ] `ingressClass: nginx` removed from traefik providers config

**Phase 5 — Remove Nginx**
- [ ] Nginx logs show zero traffic
- [ ] Nginx removed via terraform
