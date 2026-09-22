# Use Case 5 — Jenkins → Azure Pipelines

Analyseer de bestaande Jenkins pipeline.

Onderzoek:
- Jenkinsfile
- shared libraries
- agents
- credentials
- environment variables
- build
- unit tests
- integration tests
- artifacts
- Jib/Docker
- registry publication
- Helm/kubectl
- deployment
- approvals
- quality gates
- notifications

Maak eerst een mapping naar Azure DevOps.

Ontwerp daarna een `azure-pipelines.yml` met minimaal:

1. checkout
2. build
3. unit tests
4. integration tests
5. package
6. Jib/container build
7. quality/security checks
8. push naar ACR
9. deployment naar AKS
10. smoke/health validation

Gebruik geen hard-coded credentials.

Gebruik waar mogelijk service connections, workload identity/federated authentication en Azure Key Vault.

Maak ook een migration checklist voor Jenkins → Azure Pipelines.
