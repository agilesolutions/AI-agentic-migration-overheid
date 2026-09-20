# Terraform + STACKIT SKE + FluxCD GitOps Platform

This document describes a Terraform-driven platform architecture for a Kubernetes cluster running on **STACKIT SKE**, with:

* Terraform-managed infrastructure
* STACKIT SKE Kubernetes
* STACKIT Observability
* KEDA autoscaling
* FluxCD GitOps
* GitHub as the GitOps repository
* Helm and Kubernetes provider integration
* Kustomize overlays for environment-specific configuration

The guiding architectural principle is:

> **Terraform establishes the platform and GitOps control plane. FluxCD owns the Kubernetes platform and workloads after bootstrap.**

---

## Architecture Overview
1. Terraform does not manage all Flux Kubernetes resources after bootstrap.
2. Giving clean ownership to FluxCD avoids Terraform and FluxCD fighting over the same resources.
3. Terraform provisions the SKE cluster, Observability, GitHub access, and bootstraps FluxCD.
4. FluxCD manages the platform components and workloads, including KEDA, Traefik, cert-manager, External Secrets, Observability agents, Keycloak, and applications.

```text
┌───────────────────────────────────────────────────────────┐
│                         Terraform                          │
│                                                           │
│  STACKIT SKE Cluster                                     │
│  STACKIT Observability                                   │
│  GitHub Repository Access                                │
│  FluxCD Bootstrap                                        │
└─────────────────────────────┬─────────────────────────────┘
                              │
                              ▼
                       ┌───────────────┐
                       │    FluxCD     │
                       │  flux-system  │
                       └───────┬───────┘
                               │
                               │ watches
                               ▼
                       ┌───────────────┐
                       │    GitHub     │
                       │  GitOps Repo  │
                       └───────┬───────┘
                               │
                               ▼
                       ┌─────────────────────────┐
                       │       STACKIT SKE       │
                       │                         │
                       │  Traefik                │
                       │  KEDA                   │
                       │  cert-manager           │
                       │  External Secrets       │
                       │  Applications           │
                       └─────────────────────────┘
```

---

# 1. Terraform Module Structure

A recommended Terraform structure is:

```text
terraform/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── providers.tf
│   │   └── variables.tf
│   │
│   └── prod/
│       ├── main.tf
│       ├── providers.tf
│       └── variables.tf
│
└── modules/
    ├── ske-cluster/
    ├── flux/
    ├── keda/
    ├── traefik/
    ├── cert-manager/
    ├── external-secrets/
    └── observability/
```

The recommended ownership model is:

```text
Terraform
├── SKE cluster
├── STACKIT Observability
├── GitHub access
└── Flux bootstrap

FluxCD
├── KEDA
├── Traefik
├── cert-manager
├── External Secrets
├── Observability agents
├── Keycloak
└── Applications
```

---

# 2. Terraform KEDA Module

Terraform should install the KEDA operator, while FluxCD should manage application-specific `ScaledObject` resources.

## Module structure

```text
modules/
└── keda/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

## `modules/keda/main.tf`

```hcl
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

resource "helm_release" "keda" {
  name             = var.name
  namespace        = var.namespace
  create_namespace = var.create_namespace

  repository = var.repository
  chart      = var.chart
  version    = var.chart_version

  atomic          = var.atomic
  cleanup_on_fail = var.cleanup_on_fail
  wait            = var.wait
  timeout         = var.timeout

  values = var.values

  dynamic "set" {
    for_each = var.set_values

    content {
      name  = set.key
      value = set.value
    }
  }
}
```

## `variables.tf`

```hcl
variable "name" {
  description = "Helm release name."
  type        = string
  default     = "keda"
}

variable "namespace" {
  description = "Kubernetes namespace where KEDA is installed."
  type        = string
  default     = "keda"
}

variable "create_namespace" {
  description = "Create the namespace if it does not exist."
  type        = bool
  default     = true
}

variable "repository" {
  description = "KEDA Helm repository."
  type        = string
  default     = "https://kedacore.github.io/charts"
}

variable "chart" {
  description = "KEDA Helm chart name."
  type        = string
  default     = "keda"
}

variable "chart_version" {
  description = "KEDA Helm chart version."
  type        = string
}

variable "atomic" {
  description = "Rollback the release if installation fails."
  type        = bool
  default     = true
}

variable "cleanup_on_fail" {
  description = "Clean up failed resources."
  type        = bool
  default     = true
}

variable "wait" {
  description = "Wait until resources are ready."
  type        = bool
  default     = true
}

variable "timeout" {
  description = "Timeout in seconds for Helm operations."
  type        = number
  default     = 600
}

variable "values" {
  description = "Additional Helm values."
  type        = list(string)
  default     = []
}

variable "set_values" {
  description = "Additional Helm values."
  type        = map(string)
  default     = {}
}
```

## Example usage

```hcl
module "keda" {
  source = "../../modules/keda"

  chart_version = var.keda_chart_version

  namespace = "keda"
}
```

Terraform installs the operator:

```text
Terraform
    │
    ▼
KEDA Helm Chart
    │
    ▼
KEDA Operator
```

FluxCD then manages:

```text
ScaledObject
ScaledJob
TriggerAuthentication
```

---

# 3. KEDA Scaling a Backend Through REST API Traffic

For demonstration purposes, the backend can scale based on HTTP request traffic generated by the frontend.

The architecture is:

```text
Frontend
    │
    │ REST API
    ▼
Traefik Ingress
    │
    ▼
Spring Boot Backend
    │
    │ Micrometer metrics
    ▼
Prometheus
    │
    │ PromQL
    ▼
KEDA
    │
    ▼
HPA
    │
    ▼
Backend replicas
```

A Spring Boot application exposes metrics such as:

```text
http_server_requests_seconds_count
```

Example PromQL:

```promql
sum(
  rate(
    http_server_requests_seconds_count{
      application="backend-service",
      uri="/api/orders"
    }[1m]
  )
)
```

A result of:

```text
0.5
```

means approximately 0.5 requests per second.

A result of:

```text
8
```

means approximately 8 requests per second.

---

# 4. KEDA `ScaledObject`

The following manifest is managed by FluxCD.

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: backend-service
  namespace: applications
  labels:
    app.kubernetes.io/name: backend-service
    app.kubernetes.io/part-of: stackit-reference-platform
    app.kubernetes.io/managed-by: fluxcd

spec:
  scaleTargetRef:
    name: backend-service

  minReplicaCount: 1
  maxReplicaCount: 10

  pollingInterval: 15
  cooldownPeriod: 60

  advanced:
    horizontalPodAutoscalerConfig:
      behavior:
        scaleUp:
          stabilizationWindowSeconds: 0
          policies:
            - type: Pods
              value: 2
              periodSeconds: 30

        scaleDown:
          stabilizationWindowSeconds: 60
          policies:
            - type: Percent
              value: 50
              periodSeconds: 60

  triggers:
    - type: prometheus
      metadata:
        serverAddress: https://<PROMETHEUS-QUERY-ENDPOINT>

        query: |
          sum(
            rate(
              http_server_requests_seconds_count{
                application="backend-service",
                uri="/api/orders"
              }[1m]
            )
          )

        threshold: "5"
        activationThreshold: "1"
```

This means:

> Scale the backend when the `/api/orders` endpoint receives approximately more than 5 requests per second.

KEDA does not directly modify the Deployment replicas.

Instead:

```text
KEDA
  │
  ▼
HorizontalPodAutoscaler
  │
  ▼
Deployment replicas
```

---

# 5. Kustomize Application Layout

A good GitOps structure is:

```text
apps/
└── backend-service/
    ├── base/
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   ├── service-monitor.yaml
    │   └── kustomization.yaml
    │
    └── overlays/
        ├── dev/
        │   ├── kustomization.yaml
        │   └── scaledobject.yaml
        │
        └── prod/
            ├── kustomization.yaml
            └── scaledobject.yaml
```

## Base

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml
  - service-monitor.yaml
```

## Development overlay

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: applications

resources:
  - ../../base
  - scaledobject.yaml
```

Example development scaling:

```text
1 → 5 replicas
scale at 5 requests/sec
```

## Production overlay

```text
2 → 20 replicas
scale at 20 requests/sec
```

The application base remains identical while the scaling policy changes by environment.

---

# 6. STACKIT Observability

STACKIT Observability exposes instance-specific endpoints.

The exact Prometheus-compatible endpoint is not a universal static URL. The endpoint must be retrieved from the individual Observability instance.

The Terraform resource exposes:

```hcl
stackit_observability_instance.<name>.metrics_url
```

Example:

```hcl
resource "stackit_observability_instance" "main" {
  project_id = var.project_id
  name       = "platform-observability"
  plan_name  = "Observability-Monitoring-Medium-EU01"
}
```

Output:

```hcl
output "prometheus_metrics_url" {
  description = "STACKIT Observability Prometheus metrics/query URL."
  value       = stackit_observability_instance.main.metrics_url
  sensitive   = true
}
```

The resource also exposes:

```hcl
metrics_push_url
```

The conceptual distinction is:

```text
metrics_push_url
        ▲
        │ remote_write
        │
   Prometheus
        │
        ▼
metrics_url
        ▲
        │ PromQL queries
        │
       KEDA
```

The STACKIT Observability management API endpoint is different from the Prometheus query endpoint.

---

# 7. Recommended Observability Architecture

The preferred architecture is:

```text
┌─────────────────────┐
│ Spring Boot Backend │
│                     │
│ /actuator/prometheus│
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Prometheus in SKE   │
│                     │
│ ServiceMonitor      │
└──────────┬──────────┘
           │
           │ remote_write
           ▼
┌─────────────────────┐
│ STACKIT Observability│
└─────────────────────┘
```

For KEDA scaling:

```text
Local Prometheus
      │
      ├── KEDA scaling queries
      │
      └── remote_write
              ▼
      STACKIT Observability
```

This avoids making KEDA dependent on a remote public endpoint for every scaling decision.

The preferred production pattern is:

> **Use a local Prometheus-compatible endpoint for KEDA scaling and STACKIT Observability for long-term metrics storage, querying, and visualization.**

For a demonstration, KEDA can query the STACKIT Observability endpoint directly.

---

# 8. Prometheus Credentials

The STACKIT Observability endpoint requires authentication.

The username and password should be treated as technical credentials.

They should not be hardcoded in:

```text
ScaledObject
Git repository
Kustomize manifest
Terraform output
```

Terraform outputs should be marked sensitive:

```hcl
output "observability_username" {
  value     = var.observability_username
  sensitive = true
}

output "observability_password" {
  value     = var.observability_password
  sensitive = true
}
```

The values are still stored in Terraform state, so the Terraform backend must be secured.

A Kubernetes Secret can be created:

```hcl
resource "kubernetes_secret_v1" "stackit_observability" {
  metadata {
    name      = "stackit-observability"
    namespace = "applications"
  }

  data = {
    username = var.observability_username
    password = var.observability_password
  }

  type = "Opaque"
}
```

KEDA can consume credentials through:

```yaml
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: stackit-observability
  namespace: applications

spec:
  secretTargetRef:
    - parameter: username
      name: stackit-observability
      key: username

    - parameter: password
      name: stackit-observability
      key: password
```

The `ScaledObject` references the authentication:

```yaml
triggers:
  - type: prometheus
    metadata:
      serverAddress: https://<PROMETHEUS-ENDPOINT>

      query: |
        sum(
          rate(
            http_server_requests_seconds_count{
              application="backend-service"
            }[1m]
          )
        )

      threshold: "5"

    authenticationRef:
      name: stackit-observability
```

---

# 9. Terraform-Only FluxCD Bootstrap

Terraform can bootstrap FluxCD completely.

The architecture is:

```text
Terraform
   │
   ├── GitHub provider
   │     └── Deploy key
   │
   ├── TLS provider
   │     └── SSH key generation
   │
   └── Flux provider
         ├── Install Flux
         ├── Configure Git authentication
         └── Configure Git synchronization
```

The Flux provider resource:

```hcl
flux_bootstrap_git
```

performs the bootstrap process.

---

# 10. Flux Module

Recommended module structure:

```text
modules/
└── flux/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── versions.tf
```

## `versions.tf`

```hcl
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.9"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
```

## Variables

```hcl
variable "github_owner" {
  description = "GitHub organization or user."
  type        = string
}

variable "github_repository" {
  description = "GitHub GitOps repository."
  type        = string
}

variable "github_token" {
  description = "GitHub token."
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Kubernetes cluster name."
  type        = string
}

variable "git_branch" {
  description = "Git branch."
  type        = string
  default     = "main"
}

variable "flux_path" {
  description = "Flux cluster path."
  type        = string
}

variable "flux_namespace" {
  description = "Flux namespace."
  type        = string
  default     = "flux-system"
}

variable "flux_version" {
  description = "Flux version."
  type        = string
  default     = "v2.9.0"
}

variable "flux_interval" {
  description = "Flux reconciliation interval."
  type        = string
  default     = "1m0s"
}

variable "network_policy" {
  type    = bool
  default = true
}

variable "watch_all_namespaces" {
  type    = bool
  default = true
}

variable "create_repository" {
  type    = bool
  default = false
}

variable "repository_visibility" {
  type    = string
  default = "private"

  validation {
    condition = contains(
      ["private", "public", "internal"],
      var.repository_visibility
    )

    error_message = "Repository visibility must be private, public, or internal."
  }
}

variable "repository_description" {
  type    = string
  default = "GitOps repository managed by FluxCD."
}

variable "deploy_key_read_only" {
  type    = bool
  default = true
}

variable "flux_components_extra" {
  type    = set(string)
  default = []
}
```

---

# 11. Flux Module Resources

## Generate SSH key

```hcl
resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}
```

## Optional GitHub repository

```hcl
resource "github_repository" "this" {
  count = var.create_repository ? 1 : 0

  name        = var.github_repository
  description = var.repository_description

  visibility = var.repository_visibility

  has_issues   = false
  has_projects = false
  has_wiki     = false

  vulnerability_alerts = true

  lifecycle {
    prevent_destroy = true
  }
}
```

A GitOps repository should generally be protected from accidental Terraform destruction.

## GitHub deploy key

```hcl
resource "github_repository_deploy_key" "flux" {
  title      = "FluxCD - ${var.cluster_name}"
  repository = var.github_repository

  key       = tls_private_key.flux.public_key_openssh
  read_only = var.deploy_key_read_only

  depends_on = [
    github_repository.this
  ]
}
```

For a pure GitOps pull model:

```hcl
deploy_key_read_only = true
```

is preferable.

If Flux must write back to Git, for example for image automation:

```hcl
deploy_key_read_only = false
```

may be required.

---

# 12. Flux Bootstrap

```hcl
resource "flux_bootstrap_git" "this" {
  path = var.flux_path

  namespace = var.flux_namespace

  branch = var.git_branch

  version = var.flux_version

  interval = var.flux_interval

  network_policy = var.network_policy

  watch_all_namespaces = var.watch_all_namespaces

  components_extra = var.flux_components_extra

  depends_on = [
    github_repository_deploy_key.flux
  ]
}
```

The bootstrap creates:

```text
flux-system/
├── gotk-components.yaml
├── gotk-sync.yaml
└── kustomization.yaml
```

and configures the cluster to synchronize with GitHub.

---

# 13. Flux Outputs

```hcl
output "repository_name" {
  description = "GitOps repository."
  value       = var.github_repository
}

output "repository_url" {
  description = "GitOps repository URL."
  value       = "https://github.com/${var.github_owner}/${var.github_repository}"
}

output "flux_namespace" {
  value = flux_bootstrap_git.this.namespace
}

output "flux_path" {
  value = flux_bootstrap_git.this.path
}

output "flux_version" {
  value = flux_bootstrap_git.this.version
}

output "deploy_key_id" {
  value = github_repository_deploy_key.flux.id
}
```

The Flux private key should normally not be exposed as a Terraform output.

---

# 14. GitOps Repository Structure

After bootstrap:

```text
stackit-platform-gitops/
│
├── clusters/
│   └── stackit-dev/
│       ├── flux-system/
│       │   ├── gotk-components.yaml
│       │   ├── gotk-sync.yaml
│       │   └── kustomization.yaml
│       │
│       ├── infrastructure.yaml
│       └── apps.yaml
│
├── infrastructure/
│   ├── traefik/
│   ├── cert-manager/
│   ├── keda/
│   ├── external-secrets/
│   └── observability/
│
└── apps/
    ├── frontend/
    ├── backend/
    └── order-service/
```

The Flux synchronization flow is:

```text
GitHub
   │
   ▼
GitRepository
   │
   ▼
Kustomization
   │
   ▼
clusters/stackit-dev/
   │
   ├── infrastructure
   │
   └── applications
```

---

# 15. STACKIT SKE Authentication

There are two authentication models.

## Local interactive development

Authenticate the STACKIT CLI:

```bash
stackit auth login
```

Generate a kubeconfig:

```bash
stackit ske kubeconfig create \
  --project-id "$STACKIT_PROJECT_ID" \
  "$CLUSTER_NAME" \
  --login
```

This updates:

```text
~/.kube/config
```

The kubeconfig uses an `exec` authentication plugin that calls the STACKIT CLI to obtain short-lived credentials.

Then:

```bash
kubectl config use-context "$CLUSTER_NAME"

kubectl get nodes
```

---

# 16. Local Kubernetes and Helm Providers

For local development:

```hcl
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.cluster_name
}
```

For Helm:

```hcl
provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = var.cluster_name
  }
}
```

This is convenient for local Terraform execution.

---

# 17. Terraform-Native SKE Kubeconfig

For automation, avoid depending on:

```text
~/.kube/config
```

Instead, generate an SKE kubeconfig through Terraform.

Conceptually:

```hcl
resource "stackit_ske_kubeconfig" "this" {
  project_id   = var.project_id
  cluster_name = var.cluster_name

  refresh        = true
  expiration     = 7200
  refresh_before = 3600
}
```

The generated kubeconfig is:

```hcl
stackit_ske_kubeconfig.this.kube_config
```

This is sensitive.

A temporary kubeconfig file can be generated:

```hcl
resource "local_sensitive_file" "kubeconfig" {
  filename = "${path.root}/.terraform/${var.cluster_name}.kubeconfig"

  content = stackit_ske_kubeconfig.this.kube_config

  file_permission = "0600"
}
```

Then:

```hcl
provider "kubernetes" {
  config_path = local_sensitive_file.kubeconfig.filename
}

provider "helm" {
  kubernetes = {
    config_path = local_sensitive_file.kubeconfig.filename
  }
}
```

---

# 18. Provider Architecture

The overall provider model is:

```text
┌──────────────────────────┐
│      STACKIT Provider    │
│                          │
│  SKE Cluster             │
│  Observability           │
│  SKE Kubeconfig          │
└────────────┬─────────────┘
             │
             ▼
      Kubernetes Credentials
             │
      ┌──────┼────────┐
      ▼      ▼        ▼
 Kubernetes  Helm     Flux
 Provider    Provider Provider
```

The GitHub provider manages:

```text
GitHub
  │
  ├── Repository
  └── Deploy Key
```

The Flux provider manages:

```text
FluxCD
  │
  ├── Installation
  ├── Git authentication
  └── Git synchronization
```

---

# 19. Recommended Provider Configuration

Terraform provider versions:

```hcl
terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.99"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }

    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.9"
    }
  }
}
```

STACKIT:

```hcl
provider "stackit" {
  default_region = var.stackit_region
}
```

GitHub:

```hcl
provider "github" {
  owner = var.github_owner
  token = var.github_token
}
```

Flux:

```hcl
provider "flux" {
  kubernetes = {
    config_path = local_sensitive_file.kubeconfig.filename
  }

  git = {
    url = "ssh://git@github.com/${var.github_owner}/${var.github_repository}.git"

    ssh = {
      username    = "git"
      private_key = module.flux.flux_private_key
    }
  }
}
```

---

# 20. Local Development Flow

```text
stackit auth login
        │
        ▼
stackit ske kubeconfig create --login
        │
        ▼
~/.kube/config
        │
        ├── kubectl
        ├── Terraform Kubernetes provider
        └── Terraform Helm provider
```

This is ideal for:

```text
Local development
Interactive troubleshooting
kubectl administration
```

---

# 21. CI/CD Flow

For CI/CD:

```text
CI Job
  │
  ├── STACKIT authentication
  │
  ▼
Terraform
  │
  ├── SKE infrastructure
  ├── Observability
  ├── GitHub deploy key
  │
  ▼
Flux bootstrap
  │
  ▼
GitHub
  │
  ▼
FluxCD
  │
  ▼
SKE cluster
```

CI should not rely on:

```text
~/.kube/config
```

Instead, Terraform should obtain or generate the SKE authentication context as part of the automated workflow.

---

# 22. Recommended Ownership Model

## Terraform owns

```text
STACKIT SKE cluster
STACKIT Observability
GitHub repository access
GitHub deploy key
FluxCD bootstrap
```

## FluxCD owns

```text
KEDA
Traefik
cert-manager
External Secrets
Observability agents
Keycloak
Applications
ScaledObjects
HelmReleases
Kustomizations
```

This avoids multiple systems managing the same Kubernetes resources.

---

# 23. Final Platform Flow

```text
┌──────────────────────┐
│      Terraform       │
│                      │
│  STACKIT SKE         │
│  Observability       │
│  GitHub Access       │
│  Flux Bootstrap      │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│       FluxCD         │
│                      │
│  GitRepository       │
│  Kustomizations      │
│  HelmReleases        │
└──────────┬───────────┘
           │
           ▼
┌────────────────────────────────────┐
│            STACKIT SKE              │
│                                    │
│  Traefik                           │
│      │                             │
│      ▼                             │
│  Spring Boot Frontend              │
│      │                             │
│      │ REST API                    │
│      ▼                             │
│  Spring Boot Backend               │
│      │                             │
│      │ Micrometer metrics          │
│      ▼                             │
│  Prometheus                        │
│      │                             │
│      ├── KEDA PromQL scaling       │
│      │        │                    │
│      │        ▼                    │
│      │       HPA                   │
│      │        │                    │
│      │        ▼                    │
│      │   Backend replicas          │
│      │                             │
│      └── remote_write              │
│               │                    │
│               ▼                    │
│       STACKIT Observability        │
└────────────────────────────────────┘
```

---

# Conclusion

The recommended architecture is:

> **Terraform provisions STACKIT infrastructure and bootstraps FluxCD. FluxCD becomes the Kubernetes control plane for platform components and workloads.**

The responsibilities are intentionally separated:

```text
Terraform
    │
    ├── Infrastructure
    ├── Cloud services
    ├── GitHub access
    └── GitOps bootstrap
            │
            ▼
          FluxCD
            │
            ├── Helm charts
            ├── Kubernetes manifests
            ├── Kustomize overlays
            ├── KEDA autoscaling
            └── Applications
```

For your STACKIT reference platform, this gives a strong and explainable architecture:

> **Terraform creates the platform. FluxCD operates the platform. Kubernetes runs the workloads. KEDA reacts to workload demand. STACKIT Observability provides centralized metrics and observability.**
