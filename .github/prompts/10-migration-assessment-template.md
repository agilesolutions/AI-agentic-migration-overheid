# Use Case 10 — Generic Migration Assessment Prompt

Gebruik deze prompt als eerste stap bij iedere nieuwe migratieopdracht.

Analyseer de bestaande Java applicatie en infrastructuur voordat je wijzigingen voorstelt.

Beantwoord:

1. Wat is de huidige architectuur?
2. Welke Java-versie wordt gebruikt?
3. Welke Spring Boot-versie?
4. Welke infrastructure dependencies?
5. Hoe draait de applicatie op RHEL?
6. Hoe wordt gebouwd?
7. Hoe wordt getest?
8. Hoe werkt Jenkins CI/CD?
9. Hoe wordt de applicatie geconfigureerd?
10. Waar staan secrets?
11. Welke databases/messaging systemen worden gebruikt?
12. Welke externe systemen zijn afhankelijk?
13. Welke filesystem assumptions bestaan?
14. Welke network assumptions bestaan?
15. Welke observability bestaat?
16. Welke onderdelen blokkeren containerization?
17. Welke onderdelen blokkeren AKS?
18. Welke onderdelen blokkeren Azure Pipelines?
19. Welke tests ontbreken?
20. Welke risico's zijn er?

Maak daarna:

### Current State
Feitelijke inventarisatie.

### Target State
Java + Spring + container + ACR + AKS + Azure Pipelines.

### Gap Analysis
Per gap:
- evidence
- impact
- proposed remediation
- dependencies
- validation

### Migration Backlog
Orden in logische milestones.

### First Milestone
Geef alleen de eerstvolgende veilige milestone die uitgevoerd kan worden.

Voer nog geen muterende wijzigingen uit.
