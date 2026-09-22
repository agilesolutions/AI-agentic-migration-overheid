# Use Case 9 — End-to-End Java Migration

Voer een volledige assessment uit voor de volgende migratie:

Java 8
→ Java 21/25
→ modern Spring Boot
→ containerization
→ Azure Container Registry
→ Azure Kubernetes Service
→ Jenkins → Azure Pipelines
→ JUnit 5/Testcontainers

Werk uitsluitend volgens deze fasering:

## Phase 1 — Discover
Analyseer de huidige applicatie en infrastructuur.

## Phase 2 — Baseline
Leg build, tests, runtime behavior en dependencies vast.

## Phase 3 — Plan
Maak een uitvoerbaar migration backlog met dependencies en risico's.

## Phase 4 — Java
Migreer Java.

## Phase 5 — Spring
Moderniseer Spring Boot.

## Phase 6 — Test
Moderniseer unit/integration testing.

## Phase 7 — Container
Maak een production-ready container.

## Phase 8 — Azure
Publiceer naar ACR en deploy naar AKS.

## Phase 9 — CI/CD
Migreer Jenkins naar Azure Pipelines.

## Phase 10 — Validate
Voer functionele, integration, security, performance en operational validation uit.

## Phase 11 — Cutover
Maak een gecontroleerd production rollout- en rollbackplan.

Belangrijk:
- verander niets zonder expliciete uitvoering
- preserve behavior
- geen OpenShift
- geen destructieve production changes
- claim niets zonder bewijs
- documenteer blockers en assumptions

Eindresultaat:
- architecture assessment
- migration backlog
- target architecture
- implementation changes
- test evidence
- deployment design
- operational runbook
- rollback strategy
- remaining risks
