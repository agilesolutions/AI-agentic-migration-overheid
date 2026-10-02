Plan: Add unit and integration tests

Problem
- The codebase lacks automated tests across controller, service and repository layers and lacks integration-level tests against a real PostgreSQL instance with schema migrations.

Proposed approach
- Add unit tests for controllers, services and repositories using JUnit 5 and Mockito (or Spring test slices where appropriate).
- Add integration tests at the service level using Testcontainers' PostgreSQL container.
- Apply Flyway migrations to the Testcontainers PostgreSQL database during integration test startup.
- Keep tests isolated via a `test` profile and test-specific application properties.

Key changes / files to add
- Build config (pom.xml or build.gradle): add Testcontainers, flyway-core (if not present), testcontainers-postgresql, spring-boot-starter-test.
- src/test/java/.../controller/*ControllerTest.java — @WebMvcTest or plain unit tests using MockMvc + Mockito.
- src/test/java/.../service/*ServiceTest.java — JUnit + Mockito for service logic.
- src/test/java/.../repository/*RepositoryTest.java — @DataJpaTest or unit tests with an in-memory DB or Testcontainers depending on repo complexity.
- src/test/java/.../integration/*ServicePostgresIT.java — @SpringBootTest with Testcontainers PostgreSQL and Flyway migrations applied.
- src/test/resources/application-test.properties (or application-test.yml): configure datasource for Testcontainers or placeholders that integration test replaces.
- src/test/resources/db/migration/V1__init.sql (if migrations live in repo) — ensure Flyway migrations are available to the test runtime.

Testing details
- Integration tests: annotate test class with @Testcontainers and declare a @Container PostgreSQLContainer<> that exposes host/port to the Spring context (use DynamicPropertySource to wire JDBC URL, username, password). Configure Flyway to run on startup so the test DB is migrated before tests run.
- Use @ActiveProfiles("test") for integration tests or programmatic property wiring.
- Keep unit tests fast and isolated; integration tests run in a separate CI stage or with an "integration" maven/gradle profile if desired.

Todos (for session tracking)
- unit-tests-controller: write unit tests for controllers using MockMvc/@WebMvcTest
- unit-tests-service: write unit tests for service layer with Mockito
- unit-tests-repository: add repository tests (DataJpaTest or equivalent)
- add-test-dependencies: add Testcontainers, Flyway and test libs to build config
- integration-tests-service-postgres-flyway: implement service-level integration tests using Testcontainers Postgres + Flyway migrations

Notes and considerations
- If Flyway migrations are currently maintained elsewhere, adapt tests to point to the same migration path.
- Prefer Testcontainers over embedded DB for fidelity with production Postgres.
- Confirm CI runner supports Docker (required for Testcontainers). If not available, add a lightweight fallback plan (e.g., use embedded H2 with PostgreSQL mode for CI).
- Use database cleanup strategies between integration tests (Flyway clean+migrate or container restart) to ensure idempotent tests.

Next step
- After plan approval, implement changes in small commits per todo and validate with targeted test runs.
# Test additions and CI separation

What was done:

- Added MockMvc (@WebMvcTest) tests for controller endpoints: POST /api/notebooks, GET /api/notebooks/{id}, GET /api/notebooks. New file: src/test/java/com/agilesolutions/openshift/controller/NotebookControllerMockMvcTest.java
- Separated unit vs integration tests in Gradle:
    - Default 'test' task now excludes integration tests (classes ending with *IT).
    - Added 'integrationTest' Test task to run **/*IT.class. It is registered as a verification task and hooked into 'check'.

How to run locally:

- Unit tests only: ./gradlew test
- Integration tests: ./gradlew integrationTest (requires Docker)
- Full verification (unit + integration): ./gradlew check

GitLab CI:

- The repository CI (.gitlab-ci.yml) runs both flavors:
    - "test" job runs unit tests (./gradlew test). Integration tests are excluded from the default test task via build.gradle.
    - "integration-test" job runs integration tests (./gradlew integrationTest) and uses docker:dind so Testcontainers can start Postgres containers. Ensure your GitLab runner supports privileged + docker-in-docker.

Notes:
- Integration tests use Testcontainers + Flyway and require Docker. On Windows ensure Testcontainers can access Docker Desktop (DOCKER_HOST or npipe config may be needed).

# Test additions and CI separation

What was done:

- Added MockMvc (@WebMvcTest) tests for controller endpoints: POST /api/notebooks, GET /api/notebooks/{id}, GET /api/notebooks. New file: src/test/java/com/agilesolutions/openshift/controller/NotebookControllerMockMvcTest.java
- Separated unit vs integration tests in Gradle:
    - Default 'test' task now excludes integration tests (classes ending with *IT).
    - Added 'integrationTest' Test task to run **/*IT.class. It is registered as a verification task and hooked into 'check'.

How to run locally:

- Unit tests only: ./gradlew test
- Integration tests: ./gradlew integrationTest (requires Docker)
- Full verification (unit + integration): ./gradlew check

GitLab CI:

- The repository CI (.gitlab-ci.yml) runs both flavors:
    - "test" job runs unit tests (./gradlew test). Integration tests are excluded from the default test task via build.gradle.
    - "integration-test" job runs integration tests (./gradlew integrationTest) and uses docker:dind so Testcontainers can start Postgres containers. Ensure your GitLab runner supports privileged + docker-in-docker.

Notes:
- Integration tests use Testcontainers + Flyway and require Docker. On Windows ensure Testcontainers can access Docker Desktop (DOCKER_HOST or npipe config may be needed).

