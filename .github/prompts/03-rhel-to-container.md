# Use Case 3 — RHEL → Container

Een bestaande Java applicatie draait op RHEL.

Analyseer eerst hoe de applicatie momenteel wordt gestart en beheerd.

Onderzoek:
- systemd/service scripts
- startup arguments
- environment variables
- filesystem dependencies
- mounted directories
- certificates
- secrets
- configuration
- ports
- DNS/network dependencies
- database/messaging connections
- scheduled jobs
- logging
- monitoring
- OS package dependencies

Bepaal welke onderdelen niet direct naar een container kunnen worden overgezet.

Maak daarna een containerization plan met:
- base/runtime image
- Java runtime
- JVM options
- ports
- filesystem strategy
- configuration
- secret handling
- health checks
- graceful shutdown
- logging
- security/non-root execution

Gebruik Jib wanneer dit passend is.

Genereer pas containerconfiguratie nadat de assessment is afgerond.
