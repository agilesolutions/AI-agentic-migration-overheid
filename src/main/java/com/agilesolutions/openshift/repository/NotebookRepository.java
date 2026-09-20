package com.agilesolutions.openshift.repository;

import com.agilesolutions.openshift.entity.Notebook;

import java.util.UUID;

public interface NotebookRepository extends JpaRepository<Notebook, UUID> {
}