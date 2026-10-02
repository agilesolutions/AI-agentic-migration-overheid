package com.agilesolutions.openshift.repository;

import com.agilesolutions.openshift.entity.NotebookEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface NotebookRepository extends JpaRepository<NotebookEntity, UUID> {
}