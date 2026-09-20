# Kubernetes High Availability: `topologySpreadConstraints` and `PodDisruptionBudget`

> **Applies to:** Kubernetes, STACKIT SKE, AKS, EKS, GKE, OpenShift

---

# Overview

Modern Kubernetes deployments should not rely solely on replica counts for high availability. Two complementary mechanisms help ensure resilient workloads:

* **`topologySpreadConstraints`** – controls **where** Pods are scheduled.
* **`PodDisruptionBudget` (PDB)** – controls **when** Pods may be voluntarily evicted.

Together they provide resilient scheduling during:

* Kubernetes upgrades
* Node maintenance
* Cluster autoscaling
* Node replacements
* Rolling application deployments

---

# topologySpreadConstraints

## Purpose

`topologySpreadConstraints` instructs the Kubernetes scheduler to distribute Pods evenly across topology domains such as:

* Nodes
* Availability Zones
* Regions
* Custom topology labels

This reduces the impact of infrastructure failures.

---

## Without topology spreading

```text
Node A
 ├── app-1
 ├── app-2
 ├── app-3
 └── app-4

Node B
(empty)
```

If Node A fails:

```text
Application unavailable
```

---

## With topology spreading

```text
Node A                 Node B
 ├── app-1             ├── app-2
 └── app-3             └── app-4
```

If one node fails:

```text
50% of capacity remains available
```

---

# Basic Example

```yaml
spec:
  replicas: 4

  template:
    metadata:
      labels:
        app: webshop

    spec:
      topologySpreadConstraints:
        - maxSkew: 1
          topologyKey: kubernetes.io/hostname
          whenUnsatisfiable: DoNotSchedule
          labelSelector:
            matchLabels:
              app: webshop
```

---

## Configuration Explained

### topologyKey

Defines the failure domain.

Common values:

```yaml
kubernetes.io/hostname
```

Spread across nodes.

```yaml
topology.kubernetes.io/zone
```

Spread across availability zones.

---

### maxSkew

Maximum difference in Pod count between topology domains.

Example:

```
Node A = 3 Pods
Node B = 2 Pods

Skew = 1
```

Allowed.

```
Node A = 4 Pods
Node B = 1 Pod

Skew = 3
```

Rejected when `maxSkew=1`.

---

### whenUnsatisfiable

#### DoNotSchedule

Strict enforcement.

Scheduler refuses to place additional Pods if the spread would be violated.

Best for production.

---

#### ScheduleAnyway

Soft preference.

Scheduler attempts an even spread but allows scheduling if necessary.

Useful for:

* Development
* Smaller clusters
* Temporary resource shortages

---

# Multi-Zone Example

```yaml
topologySpreadConstraints:

- topologyKey: topology.kubernetes.io/zone
  maxSkew: 1
  whenUnsatisfiable: DoNotSchedule
  labelSelector:
    matchLabels:
      app: webshop
```

Example:

```
Zone A
  Node1
    app-1
    app-2

Zone B
  Node5
    app-3
    app-4
```

An entire zone may fail while the application continues running.

---

# Combining Multiple Constraints

```yaml
topologySpreadConstraints:

- topologyKey: topology.kubernetes.io/zone
  maxSkew: 1
  whenUnsatisfiable: DoNotSchedule
  labelSelector:
    matchLabels:
      app: webshop

- topologyKey: kubernetes.io/hostname
  maxSkew: 1
  whenUnsatisfiable: ScheduleAnyway
  labelSelector:
    matchLabels:
      app: webshop
```

Scheduling priority:

1. Spread across zones.
2. Spread across nodes within each zone.

---

# Compared to Pod Anti-Affinity

Traditional anti-affinity:

```yaml
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
```

Can become too restrictive.

Example:

Three replicas.

Only two nodes.

```
Node1
app-1

Node2
app-2

app-3 Pending
```

Topology spread allows:

```
Node1
app-1
app-3

Node2
app-2
```

Better overall cluster utilization.

---

# PodDisruptionBudget (PDB)

## Purpose

A PodDisruptionBudget limits **voluntary disruptions**.

It protects application availability during:

* Kubernetes upgrades
* Node maintenance
* Cluster autoscaler scale-down
* `kubectl drain`
* Managed node replacement

A PDB **does not** protect against unexpected failures such as:

* Hardware failure
* Node crash
* Power outage
* OOMKill
* Application crash
* Kernel panic

---

# Example

Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment

spec:
  replicas: 3
```

PDB:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget

metadata:
  name: payment-pdb

spec:
  minAvailable: 2

  selector:
    matchLabels:
      app: payment
```

Meaning:

> Never voluntarily evict Pods if fewer than two healthy replicas would remain.

---

# How It Works

Before maintenance:

```
payment-1
payment-2
payment-3
```

Node drain begins.

```
payment-1 evicted

payment-2
payment-3
```

Scheduler creates replacement.

```
payment-4 Ready

payment-2
payment-3
payment-4
```

Only then is another Pod allowed to be evicted.

---

# minAvailable

```yaml
minAvailable: 3
```

Always keep at least three Pods available.

| Replicas | Maximum Disruptions |
| -------- | ------------------- |
| 3        | 0                   |
| 4        | 1                   |
| 5        | 2                   |

---

# maxUnavailable

```yaml
maxUnavailable: 1
```

Allow at most one unavailable Pod.

Can also be percentage based.

```yaml
maxUnavailable: 25%
```

---

# Voluntary Disruptions

Protected by PDB:

* kubectl drain
* Cluster upgrades
* Autoscaler scale-down
* Managed Kubernetes maintenance
* Node replacement

---

# Involuntary Disruptions

Not protected:

* Node crash
* VM crash
* Hardware failure
* Kernel panic
* OOMKill
* Pod crash
* Container runtime failure

---

# Using Both Together

Cluster:

```
Node A
app-1
app-2

Node B
app-3
app-4
```

During maintenance:

```
Drain Node A

↓

app-1 evicted

↓

Scheduler creates app-5

↓

app-5 becomes Ready

↓

app-2 evicted
```

The scheduler redistributes Pods while the PDB guarantees that enough replicas remain available.

---

# Recommended Production Configuration

Deployment:

```yaml
replicas: 4
```

Topology spreading:

```yaml
topologySpreadConstraints:

- topologyKey: topology.kubernetes.io/zone
  maxSkew: 1
  whenUnsatisfiable: DoNotSchedule
  labelSelector:
    matchLabels:
      app: customer-api

- topologyKey: kubernetes.io/hostname
  maxSkew: 1
  whenUnsatisfiable: ScheduleAnyway
  labelSelector:
    matchLabels:
      app: customer-api
```

PodDisruptionBudget:

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget

metadata:
  name: customer-api

spec:
  maxUnavailable: 1

  selector:
    matchLabels:
      app: customer-api
```

---

# Best Practices

| Component         | Recommendation                                    |
| ----------------- | ------------------------------------------------- |
| Replicas          | Minimum 3 for production                          |
| Topology Spread   | Spread across nodes and zones                     |
| maxSkew           | `1`                                               |
| Node Constraint   | `kubernetes.io/hostname`                          |
| Zone Constraint   | `topology.kubernetes.io/zone`                     |
| PDB               | `maxUnavailable: 1` or `minAvailable: replicas-1` |
| Readiness Probe   | Required                                          |
| Liveness Probe    | Recommended                                       |
| Resource Requests | Required                                          |
| Resource Limits   | Recommended                                       |
| HPA               | Recommended for variable workloads                |

---

# Recommended Pattern for STACKIT SKE

For production workloads on **STACKIT SKE**, combine the following Kubernetes features:

* **Deployment**

    * 3–5 replicas

* **TopologySpreadConstraints**

    * Spread Pods across nodes
    * Spread across availability zones (if available)

* **PodDisruptionBudget**

    * `maxUnavailable: 1`

* **Readiness Probes**

    * Ensure only healthy Pods receive traffic

* **Liveness Probes**

    * Automatically recover unhealthy Pods

* **Resource Requests/Limits**

    * Enable efficient scheduling

* **Horizontal Pod Autoscaler (HPA)**

    * Scale based on CPU, memory, or custom metrics

* **Cluster Autoscaler**

    * Automatically add/remove worker nodes

This combination provides a resilient, cloud-native deployment strategy that is fully portable across upstream Kubernetes distributions, including **STACKIT SKE**, **Azure AKS**, **Amazon EKS**, **Google GKE**, and **Red Hat OpenShift**.
