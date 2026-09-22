# Copilot instructions for Spring Boot microservices engineering

- Prefer clean, layered Java architecture: controller -> service -> repository/model -> DTOs.
- Keep Spring Boot applications production-ready: configuration externalization, validation, health checks, structured logging, and secure defaults.
- Use Java 25+ idioms and Spring Boot 4 conventions.
- Favor dependency injection, small cohesive services, and explicit contracts.
- Validate request payloads with Jakarta Validation annotations.
- Use meaningful package names and domain-focused classes.
- Write unit tests for business logic and integration tests for HTTP + persistence flows.
- Prefer constructor injection and immutable DTOs when practical.
- For microservices, design APIs with clear boundaries, idempotency awareness, and versioning strategy.
- When adding persistence, prefer JPA with repository abstractions and migration tooling.
- Keep secrets, environment-specific values, and connection settings in configuration properties or environment variables.
- Document public APIs with clear endpoint descriptions and error semantics.

# Java Spring Boot Code Generation Rules
- **Stack:** Java 25+, Spring Boot 4.x, Spring Data JPA, Lombok (no @Data on entities).
- **Architecture:** Maintain strict separation of Controller -> Service -> Repository layers.
- **API Contracts:** Never return JPA Entities from Controllers. Always map to Java `record` objects as DTOs.
- **Dependency Injection:** Always use constructor injection instead of `@Autowired` field injection.
- **Validation:** Always use `jakarta.validation.constraints` on inputs and validate via `@Valid` in controllers.
