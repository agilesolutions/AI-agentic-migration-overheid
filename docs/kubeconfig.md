# Kubernetes Kubeconfig & GitOps Infrastructure Guide

A **kubeconfig** file is a configuration file that `kubectl` and other Kubernetes tools use to find cluster access information, API endpoints, and authentication credentials.

At its core, it acts as a **passport and roadmap database** for your Kubernetes environments, allowing you to securely switch between different clusters and user identities.

---

## The 3 Core Pillars of a Kubeconfig

Every kubeconfig file relies on three main arrays to build a connection. Think of it as a relational database where the pieces link together:

*   **`clusters` (Where to go)**: The physical location of the API server. This includes the full URL endpoint (e.g., `https://1.2.3.4:6443`) and the Certificate Authority (CA) certificate used to verify the server's identity.
*   **`users` (Who you are)**: Your authentication credentials. This can be client certificates, bearer tokens, username/password pairs, or execution instructions for cloud IAM plugins (like AWS IAM Authenticator or Google Cloud CLI).
*   **`contexts` (The relationship)**: A named shortcut that pairs a specific **cluster** with a specific **user**, and optionally a default **namespace**.

The file also specifies a **`current-context`**, which tells `kubectl` which context to use by default when you run commands.

---

## Anatomy of a Kubeconfig File

Here is what a standard, clean kubeconfig file looks like under the hood (written in YAML):

```yaml
apiVersion: v1
kind: Config
preferences: {}

# 1. THE TARGET DESTINATIONS
clusters:
- name: production-cluster
  cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0t...
    server: https://10.0.0.5:6443

# 2. THE IDENTITY CREDENTIALS
users:
- name: platform-admin
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0t...
    client-key-data: LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0t...

# 3. THE COMBINATIONS (LINKS)
contexts:
- name: prod-admin-context
  context:
    cluster: production-cluster
    user: platform-admin
    namespace: apps

# THE ACTIVE PROFILE
current-context: prod-admin-context
```

---

## Common Management Commands

You rarely edit this file by hand. Instead, you manage it using `kubectl config` commands:

*   **View your active configuration**:
    ```bash
    kubectl config view
    ```
*   **See all available environments (contexts)**:
    ```bash
    kubectl config get-contexts
    ```
*   **Switch to a different cluster/user profile**:
    ```bash
    kubectl config use-context <context-name>
    ```
*   **Change your default namespace for the current context**:
    ```bash
    kubectl config set-context --current --namespace=<namespace-name>
    ```

---

## Default Location & Merging

By default, Kubernetes tools look for this file at **`~/.kube/config`** on your machine.

However, if you manage dozens of clusters, a single file can become messy. You can combine multiple files dynamically using the `KUBECONFIG` environment variable:

```bash
export KUBECONFIG=~/.kube/config:~/projects/dev-cluster.yaml:~/projects/prod-cluster.yaml
```

When you run `kubectl`, it merges these files in memory, prioritizing conflicting settings from left to right.

---

## Terraform Integration via STACKIT (SKE)

When working with European cloud infrastructure like **STACKIT**, you can deploy a STACKIT Kubernetes Engine (SKE) cluster and dynamically feed its runtime kubeconfig directly into your Terraform configuration. This setup allows you to create the cluster and provision its applications within a single command workflow.

### Architectural Best Practice: Avoiding Implicit File Dependencies
Instead of writing a kubeconfig to the local runner disk (which breaks CI/CD execution pipeline elasticity), use the [stackit_ske_kubeconfig](https://terraform.io) resource data attributes. This structure maps authentication values straight into the memory of downstream providers.

### Implementation Blueprint

```hcl
terraform {
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = "~> 0.102"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# 1. Authenticate with STACKIT
provider "stackit" {
  default_region = "eu01"
}

# 2. Reference your STACKIT Kubernetes Cluster (SKE)
data "stackit_ske_cluster" "ske" {
  project_id   = var.stackit_project_id
  cluster_name = var.stackit_cluster_name
}

# 3. Dynamic Short-Lived Kubeconfig generation
resource "stackit_ske_kubeconfig" "ske_auth" {
  project_id     = var.stackit_project_id
  cluster_name   = data.stackit_ske_cluster.ske.cluster_name
  refresh        = true
  expiration     = 3600 # 1 hour token viability
}

# 4. Bind the credentials to the Kubernetes module context
provider "kubernetes" {
  host                   = resource.stackit_ske_kubeconfig.ske_auth.host
  token                  = resource.stackit_ske_kubeconfig.ske_auth.token
  cluster_ca_certificate = base64decode(resource.stackit_ske_kubeconfig.ske_auth.cluster_ca_certificate)
}

# 5. Consume inside child modules using Implicit Inheritance
module "cluster_apps" {
  source    = "./modules/k8s-core-services"
  namespace = "ingress-system"
}
```

---

## Helm Deployments with Dynamic SKE Auth

To safely deploy Helm packages into your STACKIT infrastructure using the same ephemeral credentials, configure the HashiCorp `helm` provider using the exact sensitive outputs from your `stackit_ske_kubeconfig` resource. This approach guarantees that your pipeline never commits long-lived cluster certificates or admin keys to disk.

### Helm Provider Initialization

```hcl
provider "helm" {
  kubernetes {
    host                   = resource.stackit_ske_kubeconfig.ske_auth.host
    token                  = resource.stackit_ske_kubeconfig.ske_auth.token
    cluster_ca_certificate = base64decode(resource.stackit_ske_kubeconfig.ske_auth.cluster_ca_certificate)
  }
}

# Deploy a release (e.g., NGINX Ingress Controller)
resource "helm_release" "ingress_controller" {
  name       = "ingress-nginx"
  repository = "https://github.io"
  chart      = "ingress-nginx"
  version    = "4.10.0"
  namespace  = "ingress-system"

  create_namespace = true
}
```

---

## Advanced Architecture: HCP Terraform Stacks Management

When managing enterprise deployments with HCP Terraform Stacks, you shift away from old-style monolith workspaces. In a Stack layout, the STACKIT cluster infrastructure and the downstream application configurations exist as isolated **components** connected by unified inputs and outputs.

The orchestrator dynamically reads values from the provider block and manages dependencies at runtime without triggering ordering failures.

### Stack Orchestration Configuration Example (`tfstack.hcl`)

```hcl
// 1. Define required provider schemas for the Stack
required_providers {
  stackit = {
    source  = "stackitcloud/stackit"
    version = "~> 0.102"
  }
  kubernetes = {
    source  = "hashicorp/kubernetes"
    version = "~> 2.0"
  }
}

// 2. Define standard global variables
variable "project_id" {
  type = string
}

// 3. Cluster Infrastructure Component
component "ske_infrastructure" {
  source = "./modules/ske-cluster"
  
  inputs = {
    project_id   = var.project_id
    cluster_name = "prod-stack-cluster"
  }
}

// 4. Instantiate the Kubernetes provider inside the stack using output references
provider "kubernetes" "dynamic_ske" {
  config {
    host                   = component.ske_infrastructure.kubeconfig_host
    token                  = component.ske_infrastructure.kubeconfig_token
    cluster_ca_certificate = base64decode(component.ske_infrastructure.kubeconfig_ca)
  }
}

// 5. Workload Component (Implicitly consumes the dynamically generated provider above)
component "cluster_workloads" {
  source = "./modules/k8s-apps"
  
  inputs = {
    app_version = "v2.4.0"
  }

  providers = {
    kubernetes = provider.kubernetes.dynamic_ske
  }
}
```

---

## GitOps Trigger Pattern via FluxCD

Instead of continuously managing application layers via Terraform, the industry-standard pattern is to use Terraform exclusively to bootstrap the **FluxCD GitOps controller** onto your STACKIT cluster. Once bootstrapped, FluxCD takes over, syncing your cluster state directly with a designated Git repository.

This pattern enforces absolute separation of concerns: Terraform handles the cluster lifecycle, and FluxCD handles the application delivery lifecycle.

### FluxCD Provider Integration Blueprint

```hcl
terraform {
  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.3"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# 1. Bind Flux directly to your dynamically authorized SKE Cluster
provider "flux" {
  kubernetes = {
    host                   = resource.stackit_ske_kubeconfig.ske_auth.host
    token                  = resource.stackit_ske_kubeconfig.ske_auth.token
    cluster_ca_certificate = base64decode(resource.stackit_ske_kubeconfig.ske_auth.cluster_ca_certificate)
  }
}

# 2. Configure GitHub Provider for repository access management
provider "github" {
  token = var.github_token
  owner = var.github_org_or_user
}

# 3. Reference or create the repository where cluster states live
data "github_repository" "gitops_repo" {
  full_name = "${var.github_org_or_user}/${var.gitops_repo_name}"
}

# 4. Bootstrap FluxCD on the newly provisioned SKE Cluster
resource "flux_bootstrap_git" "this" {
  depends_on = [resource.stackit_ske_kubeconfig.ske_auth]

  embedded_manifests = true
