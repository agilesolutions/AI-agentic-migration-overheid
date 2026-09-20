# OpenShift Projects — DUO Reference

## 1. Overview

An **OpenShift Project** is one of the most important concepts to understand when working with OpenShift.

At its core, an OpenShift Project provides a logical and administrative boundary around a collection of Kubernetes/OpenShift resources.

A useful mental model is:

```text
OpenShift Cluster
│
├── Project: duo-development
│   ├── Spring Boot applications
│   ├── Deployments
│   ├── Pods
│   ├── Services
│   ├── Routes
│   ├── ConfigMaps
│   └── Secrets
│
├── Project: duo-test
│   ├── Spring Boot applications
│   ├── Deployments
│   ├── Pods
│   ├── Services
│   ├── Routes
│   ├── ConfigMaps
│   └── Secrets
│
└── Project: duo-production
    ├── Spring Boot applications
    ├── Deployments
    ├── Pods
    ├── Services
    ├── Routes
    ├── ConfigMaps
    └── Secrets
```

The exact DUO project naming convention will depend on the OpenShift platform configuration.

---

# 2. Project vs Kubernetes Namespace

In Kubernetes, the basic concept is a **Namespace**:

```text
Cluster
  │
  └── Namespace
       ├── Pods
       ├── Services
       ├── Deployments
       └── ConfigMaps
```

OpenShift builds on this concept and provides the **Project** abstraction:

```text
Cluster
  │
  └── Project
       ├── Pods
       ├── Services
       ├── Deployments
       ├── Routes
       ├── ConfigMaps
       ├── Secrets
       └── ServiceAccounts
```

Technically, an OpenShift Project is based on a Kubernetes Namespace, while OpenShift adds project-oriented functionality around:

* users
* roles
* permissions
* resource quotas
* limits
* policies
* project administration

Therefore, when working with `oc`, a Project can be thought of as an **enhanced Kubernetes namespace and an operational boundary**.

---

# 3. Why Projects Matter at DUO

For a Java/Spring Boot lead developer, an OpenShift Project can be considered the operational boundary in which an application or development team operates.

A possible organization could look like:

```text
OpenShift Cluster
│
├── duo-team-a-dev
├── duo-team-a-test
├── duo-team-a-prod
│
├── duo-team-b-dev
├── duo-team-b-test
└── duo-team-b-prod
```

The actual DUO organization may use different project names and may structure projects around applications, teams, environments or organizational units.

Inside a project, a Spring Boot application might look like:

```text
duo-team-a-dev
│
├── notebook-service
│   ├── Deployment
│   ├── Pods
│   ├── Service
│   └── Route
│
├── ConfigMaps
├── Secrets
└── ServiceAccounts
```

---

# 4. A Project as a Security Boundary

One of the most important characteristics of a Project is **access control**.

Different users or teams can have different permissions in different projects.

For example:

```text
Developer A
    │
    ▼
duo-team-a-dev
    ├── ✓ get pods
    ├── ✓ get logs
    ├── ✓ deploy
    ├── ✓ restart applications
    └── ✗ access production
```

Another developer might have:

```text
Developer B
    │
    ▼
duo-team-b-dev
    ├── ✓ get pods
    ├── ✓ get logs
    └── ✗ access team A
```

Permissions can be checked with:

```bash
oc auth can-i get pods
```

For example:

```bash
oc auth can-i create deployments
```

or:

```bash
oc auth can-i get secrets
```

The Project therefore forms an important boundary for **RBAC — Role-Based Access Control**.

---

# 5. Projects and Resource Isolation

Projects can also have resource quotas.

For example:

```text
duo-team-a-dev

CPU:
  requests: 10 cores
  limits:   20 cores

Memory:
  requests: 20 Gi
  limits:   40 Gi
```

Inspect quotas:

```bash
oc get resourcequota
```

Detailed information:

```bash
oc describe resourcequota
```

OpenShift can also use **LimitRanges** to control default, minimum and maximum resource requests and limits.

```bash
oc get limitrange
```

This becomes particularly important when a Spring Boot deployment cannot create additional Pods.

For example:

```text
Deployment
    │
    ▼
ReplicaSet
    │
    ▼
New Pod
    │
    X
ResourceQuota exceeded
```

The application may appear to have a deployment problem when the actual cause is a project-level resource restriction.

---

# 6. Projects Provide Naming Isolation

Resources are generally identified within a namespace/project.

For example:

```text
duo-dev
  └── service/notebook-service

duo-test
  └── service/notebook-service

duo-prod
  └── service/notebook-service
```

It is perfectly valid for different Projects to contain resources with the same name.

This allows the same application architecture to be deployed independently into different environments.

For example:

```text
notebook-service
```

can exist simultaneously in:

```text
duo-dev
duo-test
duo-prod
```

The Project is part of the resource context.

---

# 7. Project Context in the `oc` CLI

One of the most important concepts when using `oc` is the **current Project**.

Check the current Project:

```bash
oc project
```

Example:

```text
Using project "duo-notebook-dev" on server ...
```

Switch Projects:

```bash
oc project duo-notebook-test
```

Now:

```bash
oc get pods
```

returns Pods from:

```text
duo-notebook-test
```

rather than:

```text
duo-notebook-dev
```

This is why accidentally working in the wrong Project can produce confusing results.

---

# 8. The Three Commands to Start With

Before performing OpenShift troubleshooting or operational work, establish:

### Who am I?

```bash
oc whoami
```

### Where am I?

```bash
oc project
```

### What is running there?

```bash
oc get pods
```

Together:

```bash
oc whoami
oc project
oc get pods
```

These answer:

```text
Who am I?
    ↓
Which Project am I using?
    ↓
What is running in that Project?
```

This should become a natural habit when working with OpenShift.

---

# 9. Project Resources

A typical application Project can contain:

```text
Project
│
├── Deployments
│
├── ReplicaSets
│
├── Pods
│
├── Services
│
├── Routes
│
├── ConfigMaps
│
├── Secrets
│
├── ServiceAccounts
│
├── PersistentVolumeClaims
│
└── Jobs / CronJobs
```

For a Spring Boot application:

```text
Project
│
├── notebook-service Deployment
│       │
│       └── Spring Boot Pods
│
├── notebook-service Service
│
├── notebook-service Route
│
├── notebook-config ConfigMap
│
└── notebook-secret Secret
```

---

# 10. Projects and Networking

Projects also provide an important networking context.

A typical OpenShift request path is:

```text
External Client
      │
      ▼
    Route
      │
      ▼
   Service
      │
      ▼
     Pod
      │
      ▼
Spring Boot Container
```

For example:

```text
https://notebook-dev.<duo-domain>
              │
              ▼
       notebook-service
              │
              ▼
       Spring Boot Pods
```

Check Routes:

```bash
oc get routes
```

Inspect a Route:

```bash
oc describe route <route>
```

Check Services:

```bash
oc get svc
```

Inspect a Service:

```bash
oc describe svc <service>
```

---

# 11. Service DNS Across Projects

Within the same Project, an application can normally access a Service using its Service name:

```text
http://notebook-service:8080
```

Across Projects, the namespace/project becomes part of the DNS name:

```text
http://notebook-service.other-project:8080
```

or the fully qualified Kubernetes DNS form:

```text
http://notebook-service.other-project.svc.cluster.local:8080
```

However, **NetworkPolicies may restrict communication** between Projects.

Therefore:

> Being in the same OpenShift cluster does not automatically mean every application can communicate with every other application.

---

# 12. Projects and Configuration

Spring Boot applications commonly obtain configuration from:

* ConfigMaps
* Secrets
* environment variables
* mounted configuration files
* application configuration

A typical Project might contain:

```text
duo-notebook-dev
│
├── Deployment
│
├── ConfigMap
│     └── application configuration
│
├── Secret
│     └── credentials
│
├── Service
│
└── Route
```

A Deployment might reference these resources:

```yaml
envFrom:
  - configMapRef:
      name: notebook-config

  - secretRef:
      name: notebook-secret
```

Inspect ConfigMaps:

```bash
oc get configmaps
```

Inspect a ConfigMap:

```bash
oc describe configmap <configmap>
```

Inspect Secrets:

```bash
oc get secrets
```

> Avoid exposing Secret values in terminals, logs, tickets or chat.

---

# 13. Project Context and Spring Boot Troubleshooting

When troubleshooting a Spring Boot application, the Project should be the starting point.

A useful troubleshooting hierarchy is:

```text
OpenShift Project
        │
        ▼
Deployment
        │
        ▼
Pod
        │
        ▼
Container
        │
        ▼
Spring Boot
        │
        ▼
Configuration
        │
        ▼
Dependencies
```

For example:

```text
Project
  │
  ├── Deployment
  │      │
  │      └── Pod
  │           │
  │           └── Spring Boot
  │
  ├── ConfigMap
  │
  ├── Secret
  │
  ├── Service
  │
  └── Route
```

This gives a useful operational model for a Java/Spring Boot lead developer.

---

# 14. Projects and Application Environments

Projects are often used to separate environments.

Conceptually:

```text
                  OpenShift Cluster
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          ▼              ▼              ▼
        DEV             TEST           PROD
          │              │              │
          ▼              ▼              ▼
     Spring Boot     Spring Boot    Spring Boot
       Pods            Pods           Pods
```

This provides separation of:

* deployments
* configuration
* Secrets
* Services
* Routes
* permissions
* quotas
* policies

It also reduces the possibility of accidentally manipulating production resources while working on development resources.

---

# 15. Useful Project Commands

### List Projects

```bash
oc projects
```

### Current Project

```bash
oc project
```

### Switch Project

```bash
oc project <project-name>
```

### List resources

```bash
oc get all
```

### List Pods

```bash
oc get pods
```

### List Deployments

```bash
oc get deployments
```

### List Services

```bash
oc get svc
```

### List Routes

```bash
oc get routes
```

### List ConfigMaps

```bash
oc get configmaps
```

### List Secrets

```bash
oc get secrets
```

### List Project events

```bash
oc get events --sort-by='.lastTimestamp'
```

---

# 16. A Useful DUO Mental Model

For daily DUO work, think about OpenShift in these layers:

```text
                  OPENSHIFT CLUSTER
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          ▼              ▼              ▼
       PROJECT        PROJECT        PROJECT
         DEV            TEST           PROD
          │              │              │
          │              │              │
       Security       Security       Security
       Quotas         Quotas         Quotas
       Policies       Policies       Policies
          │              │              │
          ▼              ▼              ▼
     Deployments    Deployments
```
