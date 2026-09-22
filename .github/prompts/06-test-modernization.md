# Use Case 6 — Unit & Integration Test Modernization

Analyseer de bestaande teststrategie van deze Java applicatie.

Zoek specifiek naar:
- nieuwe production classes zonder tests
- gewijzigde classes zonder passende tests
- ontbrekende branch/error-path tests
- oude JUnit-versies
- overmatig gebruik van mocks
- ontbrekende integration tests
- database integration gaps
- externe service integration gaps

Maak eerst een test-gap analysis.

Moderniseer daarna naar:
- JUnit 5
- Mockito waar passend
- Spring test slices waar passend
- Testcontainers voor echte infrastructure dependencies

Gebruik bijvoorbeeld PostgreSQL Testcontainers wanneer de applicatie PostgreSQL gebruikt.

Maak tests voor gedrag, niet alleen voor coverage.

Valideer:
- compile
- unit tests
- integration tests
- application context
- migrations
- container startup

Rapporteer welke risico's door de nieuwe tests worden afgedekt.
