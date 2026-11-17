# How to Start: Create a Simple App in the Sandbox

A walkthrough for adding a small app to the sandbox cluster, using `iamap` (a static
nginx site) as the worked example. Code lives in [apps/iamap](../apps/iamap),
deployment config in [iamap.yaml](../base-infrastructure/argocd/applications/iamap.yaml).

Nothing here needs `kubectl apply`-ing an `Application` by hand: ArgoCD is already
watching this repo (see [argocd-app-of-apps.yaml](../base-infrastructure/argocd-app-of-apps.yaml)),
so committing and pushing the files below is enough — ArgoCD creates/syncs the app
automatically.

## 1. Write the app

Put app code under `apps/<name>/`. For a static site, a `Dockerfile` that serves
pre-built files with nginx is enough:

```dockerfile
# apps/iamap/Dockerfile
FROM nginx:1.27-alpine

COPY site/ /usr/share/nginx/html/

EXPOSE 80
```

## 2. Build and push the image

The sandbox has an Azure Container Registry. Build straight from source — no local
Docker daemon, no separate push step:

```bash
az acr build --registry IfrcgoPlaygroundContainerRegistry --image iamap:latest apps/iamap/
```

This pushes to `ifrcgoplaygroundcontainerregistry.azurecr.io/iamap:latest`, which is
what the `Deployment` below references.

> ⚠️ **Pushing a new `:latest` image is not enough to deploy it.** The `Deployment`
> manifest still says `image: ...iamap:latest` — same string as before — so neither
> ArgoCD nor Kubernetes sees any change to apply, and existing pods keep running the
> old image. After every rebuild, force a rollout: see [step 8](#8-updating-the-app-after-a-codesite-change).



## 3. Create the ArgoCD Application manifest

Add `base-infrastructure/argocd/applications/<name>.yaml`. For a plain app with no
existing Helm chart, use the generic `raw` chart (same pattern as the cert-manager
`ClusterIssuer`) to define plain Kubernetes resources inline:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: iamap
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: ghcr.io/toggle-corp/helm-charts
    chart: raw
    targetRevision: v0.1.0
    helm:
      valuesObject:
        resources:
          - apiVersion: apps/v1
            kind: Deployment
            metadata:
              name: iamap
              namespace: iamap
            spec:
              replicas: 1
              selector:
                matchLabels:
                  app: iamap
              template:
                metadata:
                  labels:
                    app: iamap
                spec:
                  containers:
                    - name: nginx
                      image: ifrcgoplaygroundcontainerregistry.azurecr.io/iamap:latest
                      ports:
                        - containerPort: 80

          - apiVersion: v1
            kind: Service
            metadata:
              name: iamap
              namespace: iamap
            spec:
              selector:
                app: iamap
              ports:
                - port: 80
                  targetPort: 80

          - apiVersion: traefik.io/v1alpha1
            kind: IngressRoute
            metadata:
              name: iamap
              namespace: iamap
            spec:
              entryPoints:
                - websecure
              routes:
                - match: Host(`go-ia-map-sandbox.ifrc.org`)
                  kind: Rule
                  services:
                    - name: iamap
                      port: 80
  destination:
    server: https://kubernetes.default.svc
    namespace: iamap
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

A few things worth noting:

- `CreateNamespace=true` means you don't pre-create the `iamap` namespace yourself.
- `IngressRoute` (not plain `Ingress`) is Traefik's CRD, since Traefik is the
  cluster's only ingress controller.
- If the app already ships its own Helm chart (like `go-api` or `notebook-factory`),
  skip the `raw` chart and point `source.chart`/`repoURL` at that instead — see
  [go-api.yaml](../base-infrastructure/argocd/applications/go-api.yaml) for a full example with Helm values files.

## 4. Point DNS at Traefik

DNS records in the `ifrc.org` Azure zone are managed by hand (not by Terraform).
Point with the new hostname to `ifrcgo-aks-playground.ifrc.org` with a `CNAME` record. Then test it:
```bash
dig +short go-ia-map-sandbox.ifrc.org
ifrcgo-aks-playground.ifrc.org.
...IP...
```


## 5. Add TLS

Traefik needs a TLS secret to terminate HTTPS for the host. Two options:

**Quick/manual** — create the secret directly from a cert/key pair and reference it
in the `IngressRoute`:

```bash
S=iamap-helm-secret-cert; N=iamap
kubectl create secret tls "$S" --cert=crt --key=key -n "$N"
```

```yaml
              # In the IngressRoute spec, instead of tls: {}
              tls:
                secretName: iamap-helm-secret-cert
```

This needs to be redone by hand whenever the cert is renewed.

**Nicer/automatic** — let cert-manager issue and renew the cert for you. The
cluster already has a `letsencrypt-prod` `ClusterIssuer` (see
[cert-manager.yaml](../base-infrastructure/argocd/platform/cert-manager.yaml)) with an HTTP-01 solver on
the `traefik` ingress class. Add a `Certificate` resource alongside the other
`resources` in the `raw` chart:

```yaml
          - apiVersion: cert-manager.io/v1
            kind: Certificate
            metadata:
              name: iamap
              namespace: iamap
            spec:
              secretName: iamap-helm-secret-cert
              issuerRef:
                name: letsencrypt-prod
                kind: ClusterIssuer
              dnsNames:
                - go-ia-map-sandbox.ifrc.org
```

cert-manager then creates and keeps `iamap-helm-secret-cert` up to date — same
`secretName` reference in the `IngressRoute`, no manual `kubectl` step. This
requires the DNS record from step 4 to already resolve to the cluster and be
reachable on port 80, for the ACME challenge to succeed.

## 6. Let ArgoCD pick it up

Commit and push both files (app code + the `Application` manifest). The
`app-of-apps` Application recurses over `base-infrastructure/argocd` (excluding
`archived/**`), so a new file under `applications/` is picked up on its own —
no extra registration step.

## 7. Verify

```bash
kubectl get applications -n argocd iamap
kubectl get pods -n iamap
curl -I https://go-ia-map-sandbox.ifrc.org
```

## 8. Updating the app after a code/site change

This is the step that's easy to forget, and it's **inevitable** any time you change
the site/app content without changing the `Deployment` manifest itself (i.e. you
keep using the `:latest` tag, which is the common case for a simple app like this):

```bash
# 1. Rebuild and push the image (same tag: iamap:latest)
az acr build --registry IfrcgoPlaygroundContainerRegistry --image iamap:latest apps/iamap/

# 2. Force the Deployment to re-pull and restart its pods
kubectl rollout restart deployment/iamap -n iamap

# 3. Watch it come back up
kubectl rollout status deployment/iamap -n iamap
```

Why this is needed: the `Deployment`'s pod template still reads
`image: ...iamap:latest` — byte-for-byte the same string as before — so both
ArgoCD (diffing the manifest) and Kubernetes (diffing the pod template) see "no
change" and do nothing on their own. `kubectl rollout restart` recreates the pods
without touching the manifest, which is what actually triggers a fresh pull of the
`:latest` image.

If this gets tedious, the more "GitOps" fix is to stop using a mutable `:latest`
tag: build with a unique tag per commit (e.g. the git SHA) and bump the `image:`
line in `iamap.yaml` on each change — then the manifest itself changes, ArgoCD
picks it up, and no manual `rollout restart` is needed.

## 9. Retiring an app later

When an app is no longer needed, move its `Application` manifest from
`applications/` to `archived/` (see [alert-hub-frontend.yaml](../base-infrastructure/argocd/archived/alert-hub-frontend.yaml)
and [alert-hub-backend.yaml](../base-infrastructure/argocd/archived/alert-hub-backend.yaml) for examples) instead of deleting it outright. Since
`app-of-apps` recurses with `exclude: 'archived/**'` and `prune: true`, moving the
file there makes `app-of-apps` prune the `Application` it had created — which, via
the `resources-finalizer.argocd.argoproj.io` finalizer, cascades into deleting
everything that `Application` managed (Deployment, Service, IngressRoute, namespace).
The manifest itself keeps living under `archived/` and in git history, so it's easy
to bring back later by moving it back to `applications/`.
