# RHEL to Azure AKS Migration
Migrate a RHEL-hosted Java application to Azure Container Registry and Azure Kubernetes Service.

Target architecture:
RHEL Java application -> container/Jib -> Azure Container Registry -> Azure Kubernetes Service.

Assess Java runtime, filesystem, certificates, secrets, configuration, network/DNS/firewall requirements, databases, messaging, scheduled jobs, logging, monitoring and external integrations.

Container requirements:
- immutable image
- non-root runtime where feasible
- explicit ports
- JVM/resource sizing
- health endpoints
- graceful shutdown
- stdout/stderr logging

ACR:
- versioned/immutable image tags
- appropriate authentication
- vulnerability scanning and retention according to environment
- prefer workload identity/managed identity over long-lived credentials where supported

AKS:
- Deployment
- Service
- Ingress/Gateway
- ConfigMap
- Secret references
- ServiceAccount
- startup/readiness/liveness probes
- resource requests/limits
- HPA where justified
- NetworkPolicy where justified
- PodDisruptionBudget where justified
- environment separation

Prefer Azure Key Vault plus AKS workload identity for secrets where organizational standards permit.
Prepare structured logs, metrics, traces and Azure-compatible monitoring.

Migration sequence: assess -> containerize -> non-production AKS -> connectivity/behavior validation -> performance/operational validation -> controlled production cutover.
Never delete or disable source production workloads automatically.
