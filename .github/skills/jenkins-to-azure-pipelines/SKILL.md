# Jenkins to Azure Pipelines
Migrate Jenkins CI/CD to Azure DevOps Azure Pipelines while preserving build, test, container publication and AKS deployment behavior.
Inspect Jenkinsfile, shared libraries, agents, credentials, environment variables, build commands, tests, artifacts, Jib/Docker, registry authentication, deployment scripts, Helm/kubectl, approvals and gates.
Map Jenkinsfile to azure-pipelines.yml, agents to hosted/self-hosted agents, credentials to service connections/secure variables, artifacts to pipeline artifacts, registry to ACR and deployment steps to AKS tasks/CLI.
Target flow: checkout -> build -> unit tests -> integration tests -> package -> Jib/container build -> quality/security checks -> push ACR -> deploy AKS -> smoke/health validation.
Do not copy secrets into YAML. Prefer federated/service-connection mechanisms where supported.
Generate migration assessment, pipeline YAML, required connections/variables, AKS deployment strategy, validation and rollback considerations.
