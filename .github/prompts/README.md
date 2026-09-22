# Java Migration Use-Case Prompts — Azure/AKS

Prompt set based on the migration use cases from the Java developer assignment/vacancy discussed in this conversation.

## Included use cases

1. Java 8 → current LTS
2. Spring Boot modernization
3. RHEL → container
4. RHEL → Azure AKS
5. Jenkins → Azure Pipelines
6. Unit/integration test modernization
7. Framework selection
8. Azure/AKS readiness assessment
9. End-to-end migration
10. Generic migration assessment template

## Target architecture

Java 21/25
→ modern Spring Boot
→ container/Jib
→ Azure Container Registry
→ Azure Kubernetes Service
→ Azure DevOps / Azure Pipelines

Supporting Azure services may include Azure Key Vault, workload identity, Azure networking and Azure monitoring.

**OpenShift is deliberately excluded.**

## Recommended execution pattern

Assess → Baseline → Plan → Execute → Test → Deploy → Validate → Report

The prompts deliberately separate assessment from mutation so that Copilot can inspect an existing system before changing it.
