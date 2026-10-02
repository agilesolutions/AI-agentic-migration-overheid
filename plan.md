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
  - JaCoCo test coverage is enabled via the jacoco plugin; unit job runs ./gradlew jacocoTestReport to publish coverage XML/html for CI.

Notes:
- Integration tests use Testcontainers + Flyway and require Docker. On Windows ensure Testcontainers can access Docker Desktop (DOCKER_HOST or npipe config may be needed).
