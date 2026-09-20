# Common Operational FluxCD Commands

This document lists the FluxCD commands that are used most frequently during day-to-day platform operations. While Flux continuously reconciles your Git repository automatically, operators often need to inspect resources, trigger reconciliations, suspend deployments, or troubleshoot problems.

---

# Check Flux Installation

Show all Flux controllers.

```bash
flux check
```

Example output:

```
► checking prerequisites
✔ Kubernetes 1.32.2 >=1.31.0
✔ prerequisites checks passed

► checking controllers
✔ source-controller
✔ kustomize-controller
✔ helm-controller
✔ notification-controller
```

---

# List Git Sources

```bash
flux get sources git
```

Example:

```
NAME          REVISION          READY
platform      main@sha1:abc123  True
applications  main@sha1:def456  True
```

---

# List OCI Sources

```bash
flux get sources oci
```

---

# List Bucket Sources

```bash
flux get sources bucket
```

---

# List Kustomizations

```bash
flux get kustomizations
```

Example:

```
NAME             READY
infrastructure   True
platform         True
security         True
applications     True
```

---

# List Helm Releases

```bash
flux get helmreleases
```

---

# Get Detailed Information

Show a specific Kustomization.

```bash
flux get kustomization infrastructure
```

---

Show a HelmRelease.

```bash
flux get helmrelease keycloak
```

---

# View Status

```bash
flux tree kustomization infrastructure
```

Produces a dependency tree.

Example:

```
Kustomization/infrastructure

├── Namespace
├── HelmRepository
├── HelmRelease cert-manager
├── HelmRelease traefik
└── HelmRelease external-secrets
```

---

# Trigger Immediate Reconciliation

Normally Flux waits until the configured interval.

Force an immediate reconcile.

## Git Repository

```bash
flux reconcile source git platform
```

---

## OCI Repository

```bash
flux reconcile source oci platform
```

---

## Bucket

```bash
flux reconcile source bucket platform
```

---

## Kustomization

```bash
flux reconcile kustomization infrastructure
```

---

## HelmRelease

```bash
flux reconcile helmrelease keycloak
```

---

# Force Git Pull + Apply

Very common command.

```bash
flux reconcile source git platform
flux reconcile kustomization infrastructure
```

---

Or simply:

```bash
flux reconcile kustomization infrastructure --with-source
```

This is probably one of the most-used operational commands.

---

# Suspend Reconciliation

Temporarily stop automatic deployment.

```bash
flux suspend kustomization infrastructure
```

Resume later:

```bash
flux resume kustomization infrastructure
```

---

Suspend a HelmRelease.

```bash
flux suspend helmrelease keycloak
```

Resume:

```bash
flux resume helmrelease keycloak
```

---

# Suspend Git Polling

```bash
flux suspend source git platform
```

Resume:

```bash
flux resume source git platform
```

---

# Export Resource

```bash
flux export kustomization infrastructure
```

Useful for backup or debugging.

---

# Show Events

```bash
flux events
```

Filter:

```bash
flux events --for Kustomization/infrastructure
```

Very useful during troubleshooting.

---

# View Logs

All controllers.

```bash
flux logs
```

---

Only errors.

```bash
flux logs --level=error
```

---

Specific controller.

```bash
flux logs --kind=Kustomization
```

---

Follow logs.

```bash
flux logs --follow
```

---

# Trace Resources

Very useful for debugging ownership.

```bash
flux trace deployment backend
```

Shows:

- which HelmRelease created it
- which Kustomization owns it
- source repository

---

# Build Manifests Locally

Preview before applying.

```bash
flux build kustomization infrastructure
```

Excellent for CI debugging.

---

# Diff Against Cluster

```bash
flux diff kustomization infrastructure
```

Shows what would change.

---

# Delete Flux Resource

Delete a Kustomization.

```bash
flux delete kustomization infrastructure
```

Delete HelmRelease.

```bash
flux delete helmrelease keycloak
```

Delete Git source.

```bash
flux delete source git platform
```

---

# Bootstrap

Initial installation.

GitHub:

```bash
flux bootstrap github
```

GitLab:

```bash
flux bootstrap gitlab
```

Generic Git:

```bash
flux bootstrap git
```

Azure DevOps:

```bash
flux bootstrap git \
  --url=https://dev.azure.com/...
```

---

# Verify Cluster State

```bash
kubectl get gitrepositories -A

kubectl get kustomizations -A

kubectl get helmreleases -A

kubectl get helmrepositories -A
```

---

# Describe Resources

Often easier than using Flux.

```bash
kubectl describe kustomization infrastructure -n flux-system
```

---

# Inspect YAML

```bash
kubectl get kustomization infrastructure \
    -n flux-system \
    -o yaml
```

---

# Restart Controller

Sometimes needed after upgrades.

```bash
kubectl rollout restart deployment \
    kustomize-controller \
    -n flux-system
```

---

# Check Controller Pods

```bash
kubectl get pods -n flux-system
```

---

# Typical Operational Workflow

## Developer pushes code

```
Git Push
    │
    ▼
Flux polls Git
    │
    ▼
Reconciliation
```

Usually nothing needs to be done manually.

---

## Force deployment

```bash
flux reconcile kustomization applications --with-source
```

---

## Investigate failure

```bash
flux get kustomizations

flux events

flux logs --follow

kubectl describe kustomization applications
```

---

## Pause production rollout

```bash
flux suspend kustomization applications
```

---

## Resume

```bash
flux resume kustomization applications
```

---

## Verify deployment tree

```bash
flux tree kustomization applications
```

---

## Check drift

```bash
flux diff kustomization applications
```

---

# Most Frequently Used Commands

These are the commands you'll likely use daily:

| Command | Purpose |
|----------|---------|
| `flux check` | Verify Flux installation and controller health |
| `flux get sources git` | Check Git repository status |
| `flux get kustomizations` | List all Kustomizations and their readiness |
| `flux get helmreleases` | List deployed Helm releases |
| `flux reconcile kustomization <name> --with-source` | Force a Git pull and deployment |
| `flux reconcile helmrelease <name>` | Redeploy a Helm release |
| `flux suspend kustomization <name>` | Pause reconciliation |
| `flux resume kustomization <name>` | Resume reconciliation |
| `flux events --for Kustomization/<name>` | View reconciliation events |
| `flux logs --follow` | Stream controller logs |
| `flux tree kustomization <name>` | Display managed resource hierarchy |
| `flux trace <kind> <name>` | Identify which Flux resource owns a Kubernetes object |
| `kubectl describe kustomization <name> -n flux-system` | Inspect status, conditions, and errors |
| `kubectl get kustomizations -A` | List all Flux Kustomizations in the cluster |

---

# Recommended Commands to Memorize

If you're operating a production GitOps platform (for example, on STACKIT SKE, AKS, EKS, or GKE), these are the commands worth memorizing:

```bash
flux check

flux get kustomizations
flux get helmreleases

flux reconcile kustomization <name> --with-source

flux suspend kustomization <name>
flux resume kustomization <name>

flux tree kustomization <name>

flux events --for Kustomization/<name>

flux logs --follow

kubectl describe kustomization <name> -n flux-system

kubectl get kustomizations -A

flux reconcile kustomization flux-system --with-source

kubectl get crd imageautomations.image.toolkit.fluxcd.io -o jsonpath='{.spec.versions[*].name}'

```

These cover the vast majority of day-to-day operational tasks: health checks, manual reconciliations, troubleshooting, rollout control, and resource inspection.