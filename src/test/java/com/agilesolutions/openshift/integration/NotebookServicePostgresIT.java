package com.agilesolutions.openshift.integration;

import com.agilesolutions.openshift.dto.NotebookResponse;
import com.agilesolutions.openshift.service.NotebookService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Testcontainers
@Tag("integration")
class NotebookServicePostgresIT {

    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15-alpine")
            .withDatabaseName("test")
            .withUsername("test")
            .withPassword("test");

    @DynamicPropertySource
    static void properties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", postgres::getJdbcUrl);
        registry.add("spring.datasource.username", postgres::getUsername);
        registry.add("spring.datasource.password", postgres::getPassword);
        registry.add("spring.datasource.driver-class-name", () -> "org.postgresql.Driver");
        registry.add("spring.flyway.enabled", () -> "true");
    }

    @Autowired
    NotebookService notebookService;

    @Test
    void createAndFind_persistsWithMigrations() {
        NotebookResponse created = notebookService.create("IT-Note", "integration");
        assertThat(created.id()).isNotNull();

        NotebookResponse found = notebookService.findById(created.id());
        assertThat(found.title()).isEqualTo("IT-Note");
    }
}