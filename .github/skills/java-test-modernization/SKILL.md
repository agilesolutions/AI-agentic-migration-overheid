# Java Test Modernization
Improve migration confidence using JUnit 5, Mockito where appropriate, Spring test support and Testcontainers.
Discover JUnit/Mockito versions, Spring test setup, existing conventions, coverage, integration tests, infrastructure dependencies and changed/new production classes without tests.
Prioritize migration-affected code, new classes, critical business logic, security-sensitive code, persistence/integration boundaries and error handling.
Use focused behavioral unit tests. Cover happy paths, boundaries, validation, exceptions and important branches.
Use Testcontainers for real infrastructure such as PostgreSQL where practical. Avoid replacing all integration tests with mocks.
Choose the smallest suitable test type: pure unit, Spring slice, full context or Testcontainers integration test.
Each migration milestone should run compile, unit tests, integration tests, packaging and container smoke tests where relevant.
Report gaps, tests added/changed, infrastructure covered, commands, failures and remaining risk.
