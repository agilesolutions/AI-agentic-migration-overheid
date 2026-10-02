package com.agilesolutions.openshift.repository;

import org.junit.jupiter.api.Test;
import org.springframework.data.jpa.repository.JpaRepository;

import static org.assertj.core.api.Assertions.assertThat;

class NotebookRepositoryTest {

    @Test
    void repositoryIsInterfaceExtendingJpaRepository() {
        assertThat(NotebookRepository.class.isInterface()).isTrue();
        boolean extendsJpa = false;
        for (Class<?> iface : NotebookRepository.class.getInterfaces()) {
            if (iface.equals(JpaRepository.class)) {
                extendsJpa = true;
                break;
            }
        }
        assertThat(extendsJpa).isTrue();
    }
}