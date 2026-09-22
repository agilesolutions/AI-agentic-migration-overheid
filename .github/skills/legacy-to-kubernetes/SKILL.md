# Legacy RHEL to Kubernetes
Analyze a Java application running on RHEL and migrate it toward containerized Kubernetes deployment with Azure Kubernetes Service as the target.
Discover systemd services, startup scripts, processes, filesystem mounts, certificates, secrets, configuration, ports, scheduled jobs, databases, messaging, logging and monitoring.
Prefer Jib for Java container builds where appropriate. Use immutable images, non-root execution, external configuration and health endpoints.
Assess Deployment, Service, ConfigMap, Secret references, ServiceAccount, probes, resource requests/limits, autoscaling, NetworkPolicy and PodDisruptionBudget where justified.
The Kubernetes target is AKS and images should be published to ACR.
Never delete source RHEL workloads automatically. Report dependencies, target design, migration sequence, validation and risks.
