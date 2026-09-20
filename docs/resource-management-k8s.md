# Kubernetes Resource Governance
## Understanding Resource Requests, Limits, LimitRange and ResourceQuota

A practical guide explaining how Kubernetes manages Pod resources, when `LimitRange` and `ResourceQuota` are evaluated, who enforces them, and how they should be configured for both production clusters and local Docker Desktop Kubernetes environments.

---

# Table of Contents

- Introduction
- Kubernetes Resource Governance
- Resource Requests and Limits
- ResourceQuota
- LimitRange
- Quality of Service (QoS)
- PriorityClass
- PodDisruptionBudget
- Horizontal Pod Autoscaler
- Vertical Pod Autoscaler
- Cluster Autoscaler
- Namespace Isolation
- NetworkPolicies
- Node Affinity & Taints
- Topology Spread Constraints
- RuntimeClass
- Storage Quotas
- Object Count Quotas
- Enterprise Resource Governance Stack
- Docker Desktop Resource Strategy
- Example ResourceQuota
- Example LimitRange
- Example Deployment Resources
- How LimitRange Works Internally
- How ResourceQuota Works Internally
- Complete Admission Flow
- Production Best Practices

---

# Introduction

Kubernetes does **not** simply schedule Pods onto Nodes.

Before a Pod is even stored inside the cluster, Kubernetes evaluates a series of policies that determine:

- Is the Pod allowed?
- Does it have resource requests?
- Does it exceed namespace quotas?
- Can it eventually be scheduled?

These responsibilities are shared between several Kubernetes components:

```
Developer
     │
kubectl apply
     │
     ▼
API Server
     │
Admission Controllers
     │
├── LimitRange
├── ResourceQuota
└── Other Admission Plugins
     │
     ▼
etcd
     │
Deployment Controller
     │
ReplicaSet
     │
Scheduler
     │
Node
     │
Kubelet
```

---

# Kubernetes Resource Governance

Resource governance is implemented through multiple independent mechanisms.

| Feature | Purpose |
|----------|---------|
| Requests | Minimum resources needed |
| Limits | Maximum resources allowed |
| LimitRange | Namespace defaults and validation |
| ResourceQuota | Namespace resource budget |
| QoS | Eviction priority |
| PriorityClass | Scheduling priority |
| HPA | Scale Pods |
| VPA | Optimize requests |
| Cluster Autoscaler | Scale Nodes |
| PDB | Protect availability |
| NetworkPolicies | Secure networking |
| RBAC | Secure API access |
| Topology Spread | High availability |

---

# Resource Requests and Limits

Every production workload should define CPU and memory requests and limits.

Example:

```yaml
resources:
  requests:
    cpu: 250m
    memory: 512Mi

  limits:
    cpu: 500m
    memory: 1Gi
```

## Requests

Requests represent the minimum resources required.

They are used by the Kubernetes Scheduler.

Benefits

- Scheduling
- Capacity planning
- Guaranteed minimum resources

---

## Limits

Limits represent the maximum resources a container may consume.

Behavior

CPU

- throttled

Memory

- OOMKilled

---

# ResourceQuota

ResourceQuota limits the **total** resources available inside a namespace.

Example

```yaml
apiVersion: v1
kind: ResourceQuota

metadata:
  name: services-quota
  namespace: services

spec:
  hard:

    requests.cpu: "2"
    limits.cpu: "4"

    requests.memory: 4Gi
    limits.memory: 8Gi

    pods: "20"
    services: "10"

    configmaps: "20"
    secrets: "20"

    persistentvolumeclaims: "5"
    requests.storage: "20Gi"
```

ResourceQuota prevents one team or one application from consuming the entire cluster.

---

# LimitRange

LimitRange defines defaults, minimums and maximums.

```yaml
apiVersion: v1
kind: LimitRange

metadata:
  name: services-defaults
  namespace: services

spec:
  limits:

  - type: Container

    defaultRequest:
      cpu: 150m
      memory: 256Mi

    default:
      cpu: 500m
      memory: 768Mi

    min:
      cpu: 50m
      memory: 128Mi

    max:
      cpu: "1"
      memory: 2Gi
```

Benefits

- Automatic defaults
- Validation
- Prevent oversized containers
- Predictable scheduling

---

# Quality of Service (QoS)

Pods receive one of three QoS classes.

## Guaranteed

```
Requests == Limits
```

Highest protection.

---

## Burstable

```
Requests < Limits
```

Recommended for almost every Spring Boot service.

---

## BestEffort

No requests.

No limits.

Lowest priority.

---

# PriorityClass

Example

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass

metadata:
  name: production

value: 100000
```

Typical priorities

```
100000  Traefik
90000   Keycloak
85000   Cert Manager
80000   PostgreSQL
70000   Kafka
50000   Business Services
10000   Batch Jobs
```

---

# PodDisruptionBudget

Example

```yaml
spec:
  minAvailable: 2
```

Protects applications during

- node maintenance
- upgrades
- rolling deployments

---

# Horizontal Pod Autoscaler

Example

```yaml
minReplicas: 2
maxReplicas: 10

targetCPUUtilizationPercentage: 70
```

Automatically increases Pod replicas.

---

# Vertical Pod Autoscaler

Adjusts

- CPU Requests
- Memory Requests

based on historical usage.

---

# Cluster Autoscaler

Adds worker nodes when Pods cannot be scheduled.

```
Pending Pods

↓

New Node

↓

Pods Scheduled
```

---

# Namespace Isolation

Typical namespaces

```
platform
monitoring
services
development
staging
```

Each namespace typically contains

- ResourceQuota
- LimitRange
- RBAC
- NetworkPolicies

---

# NetworkPolicies

Restrict Pod communication.

```
Frontend

↓

Backend

↓

Database
```

Everything else denied.

---

# Node Affinity

Reserve hardware.

Example

```
GPU Nodes

↓

ML Workloads Only
```

---

# Topology Spread Constraints

Distribute Pods across Nodes.

```
Node A

API-1

API-2

Node B

API-3

API-4

Node C

API-5

API-6
```

---

# RuntimeClass

Examples

- runc
- gVisor
- Kata Containers

---

# Storage Quotas

Example

```yaml
hard:

persistentvolumeclaims: "5"

requests.storage: 20Gi
```

---

# Object Count Quotas

```yaml
hard:

pods: 20

services: 10

configmaps: 20

secrets: 20
```

---

# Enterprise Resource Governance Stack

```
Namespace

│

├── ResourceQuota

├── LimitRange

├── NetworkPolicies

├── RBAC

│

└── Applications

      │

      ├── Requests

      ├── Limits

      ├── QoS

      ├── PriorityClass

      ├── HPA

      ├── PDB

      └── Topology Spread

               │

               ▼

      Cluster Autoscaler
```

---

# Docker Desktop Kubernetes

For Docker Desktop Kubernetes (typically 4–8 vCPUs and 8–16 GiB RAM), quotas should be much smaller than production.

## Recommended ResourceQuota

```yaml
apiVersion: v1
kind: ResourceQuota

metadata:
  name: services-quota
  namespace: services

spec:
  hard:

    requests.cpu: "2"
    limits.cpu: "4"

    requests.memory: 4Gi
    limits.memory: 8Gi

    pods: "20"

    services: "10"

    configmaps: "20"

    secrets: "20"

    persistentvolumeclaims: "5"

    requests.storage: "20Gi"
```

---

## Recommended LimitRange

```yaml
apiVersion: v1
kind: LimitRange

metadata:
  name: services-defaults
  namespace: services

spec:
  limits:

  - type: Container

    defaultRequest:
      cpu: 150m
      memory: 256Mi

    default:
      cpu: 500m
      memory: 768Mi

    min:
      cpu: 50m
      memory: 128Mi

    max:
      cpu: "1"
      memory: 2Gi
```

---

# Vergunning Service Example

Explicitly define resources instead of relying on defaults.

```yaml
resources:

  requests:
    cpu: 250m
    memory: 512Mi

  limits:
    cpu: 750m
    memory: 1024Mi
```

This results in the **Burstable** QoS class, which is the recommended profile for most Spring Boot services.

---

# How LimitRange Works

LimitRange is implemented by the **LimitRanger admission plugin** inside the Kubernetes API Server.

It performs two functions:

- Apply default resource requests and limits.
- Validate minimum and maximum values.

Developer submits:

```yaml
containers:

- name: vergunning-service
```

LimitRange mutates the Pod before it is stored:

```yaml
containers:

- name: vergunning-service

  resources:

    requests:
      cpu: 150m
      memory: 256Mi

    limits:
      cpu: 500m
      memory: 768Mi
```

If a developer specifies values outside the allowed range, the API Server rejects the request immediately.

---

# How ResourceQuota Works

ResourceQuota is implemented by the **ResourceQuota admission plugin**.

It evaluates the total resource consumption of the namespace before accepting a new object.

Example:

Current CPU Requests

```
1.8 CPU
```

New Pod

```
250m
```

New total

```
2.05 CPU
```

Quota

```
2 CPU
```

Result

```
Admission Denied

Exceeded ResourceQuota
```

The Pod is never created.

---

# Admission Order

The order of execution is critical.

```
Developer

↓

kubectl apply

↓

API Server

↓

LimitRange
(Default resources)

↓

ResourceQuota
(Check namespace totals)

↓

Stored in etcd

↓

Deployment Controller

↓

ReplicaSet

↓

Scheduler

↓

Node

↓

Kubelet
```

LimitRange must execute before ResourceQuota so that quota calculations include any defaulted resource requests.

---

# Scheduler

Only after admission succeeds does the Scheduler attempt to place the Pod on a Node.

If no Node has sufficient available resources, the Pod remains in the `Pending` state.

Even while pending, the Pod's requested resources count against the namespace's ResourceQuota because the Pod object already exists.

---

# Pod Deletion

When a Pod is deleted, its resource usage is immediately removed from the namespace quota, allowing new Pods to be admitted.

---

# Deployment and ReplicaSet Behavior

Each Pod created by a Deployment is admitted independently.

For a Deployment requesting 10 replicas:

```
Replica 1

Accepted

Replica 2

Accepted

...

Replica 9

Accepted

Replica 10

Rejected

(ResourceQuota exceeded)
```

The Deployment reports:

```
Desired: 10

Running: 9
```

The Deployment controller continues trying to create the missing replica until resources become available or the quota is increased.

---

# Who Enforces What?

| Component | Responsibility |
|-----------|----------------|
| API Server | Executes admission plugins during object creation and updates |
| LimitRanger Admission Plugin | Applies default requests/limits and validates min/max values |
| ResourceQuota Admission Plugin | Calculates namespace usage and enforces quotas |
| Scheduler | Selects an appropriate Node based on resource requests |
| Kubelet | Enforces CPU and memory limits at runtime using Linux cgroups |

Neither `LimitRange` nor `ResourceQuota` is a controller. Both are synchronous admission-time policies executed by the Kubernetes API Server.

---

# Production Best Practices

- Always define CPU and memory requests and limits.
- Use a `LimitRange` in every namespace to provide defaults and enforce sensible minimum and maximum values.
- Apply a `ResourceQuota` to every namespace to prevent uncontrolled resource consumption.
- Assign `PriorityClass` values to critical platform components such as Traefik, Keycloak, PostgreSQL, DNS, monitoring, and cert-manager.
- Configure `PodDisruptionBudget` for highly available workloads.
- Combine the Horizontal Pod Autoscaler with the Cluster Autoscaler for dynamic scaling.
- Regularly review resource requests using Prometheus, Grafana, or Vertical Pod Autoscaler recommendations.
- Use Topology Spread Constraints and Pod Anti-Affinity to improve resilience.
- Secure workloads using RBAC, NetworkPolicies, namespace isolation, and least-privilege ServiceAccounts.
- Monitor CPU, memory, quota usage, scheduling failures, OOMKills, and Pod evictions.

---

# Summary

Kubernetes resource governance is implemented through multiple complementary mechanisms working together.

1. **LimitRange** defines sensible per-container defaults and validates resource values.
2. **ResourceQuota** enforces the total resource budget available to a namespace.
3. **Scheduler** places admitted Pods onto Nodes based on resource requests.
4. **Kubelet** enforces runtime CPU and memory limits.

This layered approach provides:

- Fair resource allocation
- Predictable scheduling
- Multi-tenancy
- Cost control
- High availability
- Operational resilience
- Secure and stable production clusters

Whether running on a small Docker Desktop cluster or a large enterprise platform managed with FluxCD, these mechanisms form the foundation of effective Kubernetes resource governance.