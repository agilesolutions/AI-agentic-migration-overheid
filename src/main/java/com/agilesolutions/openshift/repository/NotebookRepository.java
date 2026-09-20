package com.agilesolutions.openshift.repository;

import com.agilesolutions.openshift.entity.Notebook;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface NotebookRepository extends JpaRepository<Notebook, UUID> {
}