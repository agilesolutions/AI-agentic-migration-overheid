# FluxCD Kustomization vs Kubernetes Kustomize

Understanding the relationship between **FluxCD Kustomizations** and **Kubernetes Kustomize** is one of the most important concepts when building a GitOps platform.

Although they both use the name **Kustomization**, they have very different responsibilities.

---

# Two Different Kustomizations

| Feature | Kubernetes Kustomize | FluxCD Kustomization |
|----------|----------------------|----------------------|
| API Version | `kustomize.config.k8s.io/v1beta1` | `kustomize.toolkit.fluxcd.io/v1` |
| Kind | `Kustomization` | `Kustomization` |
| Purpose | Build Kubernetes manifests | Reconcile and deploy manifests |
| Executed by | `kustomize build` | Flux Kustomize Controller |
| Stored in Kubernetes | No | Yes (Custom Resource) |
| Primary Responsibility | Manifest generation | GitOps orchestration |

---

# Kubernetes Kustomization

A Kubernetes Kustomization is simply a build configuration.

Example:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml

namespace: demo

patches:
  - path: patch.yaml

images:
  - name: backend
    newTag: 1.2.0
```

It tells Kustomize:

- which manifests belong together
- which patches to apply
- namespace transformations
- image substitutions
- generators
- overlays
- replacements
- components

It is consumed by:

```bash
kustomize build .
```

or

```bash
kubectl apply -k .
```

It is **never installed into Kubernetes**.

---

# FluxCD Kustomization

A Flux Kustomization is a Kubernetes Custom Resource.

Example:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization

metadata:
  name: infrastructure
  namespace: flux-system

spec:
  interval: 10m

  sourceRef:
    kind: GitRepository
    name: platform

  path: ./infrastructure

  prune: true

  wait: true
```

A Flux Kustomization tells the Flux Kustomize Controller:

- where the Git repository is
- which directory to reconcile
- how often to reconcile
- whether to prune deleted resources
- health checks
- dependencies
- decryption
- retries
- drift correction

---

# Understanding `spec.path`

One of the most frequently misunderstood properties is:

```yaml
spec:
  path: ./fluxcd
```

This does **not** point to another Flux Kustomization.

Instead it means:

> Clone the Git repository, change into the `./fluxcd` directory, run `kustomize build`, and apply the resulting manifests.

---

## Example Repository

```
repository-root/

├── fluxcd/
│   ├── kustomization.yaml
│   ├── infrastructure.yaml
│   ├── applications.yaml
│   ├── namespace.yaml
│   └── cluster-config.yaml
│
├── infrastructure/
│   ├── kustomization.yaml
│   └── ...
│
└── applications/
    ├── kustomization.yaml
    └── ...
```

Flux performs:

```
Clone Git Repository
        │
        ▼
cd ./fluxcd
        │
        ▼
Run kustomize build
        │
        ▼
Apply resulting manifests
```

---

# What Can `spec.path` Contain?

A Flux `spec.path` directory may contain **all kinds of Kubernetes manifests**, including Flux resources themselves.

For example:

```
fluxcd/

├── kustomization.yaml
├── infrastructure.yaml
├── applications.yaml
├── namespace.yaml
└── cluster-config.yaml
```

---

## Native Kubernetes Kustomization

```
fluxcd/kustomization.yaml
```

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - infrastructure.yaml
  - applications.yaml
  - namespace.yaml
  - cluster-config.yaml
```

Notice this is the Kubernetes Kustomization.

---

## Flux Kustomization Resources

```
fluxcd/infrastructure.yaml
```

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization

metadata:
  name: infrastructure
  namespace: flux-system

spec:
  interval: 10m

  sourceRef:
    kind: GitRepository
    name: flux-system

  path: ./infrastructure

  prune: true
```

This manifest is simply another Kubernetes object.

When Flux applies it, Kubernetes stores it as a Custom Resource.

The Flux Kustomize Controller then notices the new object and starts reconciling the `./infrastructure` directory.

---

## Ordinary Kubernetes Resources

The same directory may also contain ordinary Kubernetes manifests.

Example:

```yaml
apiVersion: v1
kind: Namespace

metadata:
  name: demo
```

Flux simply applies it like any other Kubernetes resource.

---

# Can One Flux Kustomization Point to Another?

No.

This is **not supported**:

```yaml
spec:
  sourceRef:
    kind: Kustomization
```

Nor can `path` refer to another Flux Kustomization.

A Flux Kustomization always points to:

- GitRepository
- OCIRepository
- Bucket

and a directory inside that source.

---

# How Flux Kustomizations Work Together

Flux Kustomizations are connected through dependencies.

Example:

```yaml
dependsOn:
  - name: infrastructure
```

This produces a reconciliation order like:

```
Infrastructure
      │
      ▼
Platform
      │
      ▼
Applications
```

Each Flux Kustomization independently:

- clones the Git repository
- builds its own Kustomize overlay
- applies manifests
- performs health checks
- reconciles continuously

---

# Bootstrapping Flux

A common pattern is a "root" Flux Kustomization.

```
Flux Kustomization
(name: flux-system)
        │
        │ path: ./fluxcd
        ▼
Kustomize Build
        │
        ├── infrastructure.yaml
        ├── platform.yaml
        ├── observability.yaml
        └── applications.yaml
```

The root Kustomization installs several child Flux Kustomizations.

Each child then manages its own directory.

---

# Typical Production Repository

```
clusters/
└── production/
    ├── flux-system/
    │   └── gotk-sync.yaml
    │
    └── flux/
        ├── kustomization.yaml
        ├── infrastructure.yaml
        ├── platform.yaml
        ├── security.yaml
        ├── observability.yaml
        └── applications.yaml

infrastructure/
├── cert-manager/
├── traefik/
└── external-secrets/

platform/
├── keycloak/
├── postgres/
└── operators/

observability/
├── lgtm/
└── opentelemetry/

applications/
└── spring-services/
```

Root Flux Kustomization:

```yaml
spec:
  path: ./clusters/production/flux
```

---

# Recommended Deployment Hierarchy

```
GitRepository
      │
      ▼
Root Flux Kustomization
      │
      ├── Infrastructure
      ├── Platform
      ├── Security
      ├── Observability
      └── Applications
```

Dependencies:

```
Infrastructure
      │
      ▼
Platform
      │
      ▼
Security
      │
      ▼
Observability
      │
      ▼
Applications
```

Each layer is an independent Flux Kustomization with its own reconciliation lifecycle.

---

# Responsibilities Summary

## Kubernetes Kustomization

Responsible for **building manifests**.

```
deployment.yaml
service.yaml
configmap.yaml

        │
        ▼

kustomization.yaml

        │
        ▼

Generated Kubernetes YAML
```

---

## Flux Kustomization

Responsible for **GitOps orchestration**.

```
Git Repository

      │
      ▼

Clone Repository

      │
      ▼

Run Kustomize Build

      │
      ▼

Apply Resources

      │
      ▼

Health Checks

      │
      ▼

Prune Deleted Resources

      │
      ▼

Drift Detection

      │
      ▼

Continuous Reconciliation
```

---

# Key Takeaways

- `kustomize.config.k8s.io/v1beta1` is a **manifest builder**.
- `kustomize.toolkit.fluxcd.io/v1` is a **GitOps controller resource**.
- `spec.path` always points to a **directory in a Git/OCI/Bucket source**, not to another Flux Kustomization.
- A `spec.path` directory can contain:
    - Native Kubernetes Kustomizations
    - Flux Kustomization resources
    - HelmRelease resources
    - Namespaces
    - ConfigMaps
    - CRDs
    - Any other Kubernetes manifests
- A root Flux Kustomization commonly installs multiple child Flux Kustomizations.
- Child Flux Kustomizations coordinate deployment order using `dependsOn`.
- This layered architecture is the recommended pattern for production GitOps platforms because it cleanly separates manifest generation (Kustomize) from deployment orchestration (FluxCD).