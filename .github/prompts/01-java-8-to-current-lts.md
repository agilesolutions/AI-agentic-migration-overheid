# Use Case 1 — Java 8 → Current LTS

## Assessment

Analyseer deze Java 8 applicatie en bepaal wat nodig is om naar Java 21 of Java 25 te migreren.

Voer eerst alleen een assessment uit. Wijzig geen bestanden.

Onderzoek:
- huidige Java/toolchain
- Maven/Gradle
- dependencies
- plugins en annotation processors
- deprecated/removed APIs
- `javax`/`jakarta`
- reflection/proxy usage
- JAXB en andere Java EE-gerelateerde dependencies
- JVM startup options
- tests
- container/Jib configuration
- CI/CD

Lever op:
1. huidige baseline
2. aanbevolen target Java-versie met technische onderbouwing
3. compatibility issues
4. dependency changes
5. code changes
6. test impact
7. container/runtime impact
8. migration plan
9. risks and rollback considerations

Claim geen succesvolle migratie zonder build- en testresultaten.

## Execute

Voer vervolgens de Java LTS-migratie incrementeel uit.

Regels:
- behoud bestaand gedrag
- vermijd unrelated refactoring
- upgrade alleen noodzakelijke dependencies
- compileer na logische stappen
- voer unit/integration tests uit
- rapporteer iedere blocker

Eindig met een migration report.
