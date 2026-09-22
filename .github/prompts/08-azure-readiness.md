# Use Case 8 — Azure/AKS Readiness Assessment

Voer een volledige cloud-readiness assessment uit voor een Java applicatie die van RHEL naar Azure AKS moet.

Controleer:

## Application
- Java version
- Spring Boot
- configuration
- secrets
- filesystem
- startup/shutdown
- health checks

## Container
- image
- Jib
- JVM sizing
- non-root
- ports
- health endpoints
- logging

## Azure
- ACR
- AKS
- Key Vault
- workload identity
- networking
- DNS
- certificates
- monitoring

## Kubernetes
- Deployment
- Service
- Ingress/Gateway
- ConfigMap
- Secrets
- probes
- resource limits
- autoscaling
- availability
- security

## CI/CD
- Azure Pipelines
- image build
- ACR publication
- AKS deployment
- approvals
- rollback

Produce a readiness scorecard, but do not assign an overall quality score. Use statuses:
- Ready
- Needs Work
- Blocked
- Unknown

For every non-ready item provide evidence and remediation.
