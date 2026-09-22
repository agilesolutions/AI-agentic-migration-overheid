# Use Case 4 — RHEL → Azure AKS

Migreer deze bestaande RHEL-hosted Java applicatie naar Azure Kubernetes Service.

Doelarchitectuur:

Java application
→ Jib/container image
→ Azure Container Registry
→ Azure Kubernetes Service

Onderzoek eerst:
- applicatie dependencies
- network requirements
- DNS
- certificates
- secrets
- database/messaging
- filesystem
- external integrations
- logging/monitoring
- resource requirements

Ontwerp vervolgens:
- AKS namespace
- Deployment
- Service
- Ingress/Gateway
- ConfigMap
- Secret references
- ServiceAccount
- readiness probe
- liveness probe
- startup probe
- resource requests/limits
- HPA waar relevant
- NetworkPolicy waar relevant
- PodDisruptionBudget waar relevant

Gebruik Azure Key Vault en AKS workload identity voor secrets wanneer dit past binnen de omgeving.

Container images worden gepubliceerd naar ACR.

Maak een rollout- en rollbackstrategie.

OpenShift is geen target en mag niet worden gebruikt in de oplossing.
