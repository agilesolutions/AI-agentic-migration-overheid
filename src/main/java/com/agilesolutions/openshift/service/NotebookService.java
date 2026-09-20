package com.agilesolutions.openshift.service;

import com.agilesolutions.openshift.dto.NotebookResponse;
import com.agilesolutions.openshift.entity.Notebook;
import com.agilesolutions.openshift.exception.NotebookNotFoundException;
import com.agilesolutions.openshift.repository.NotebookRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class NotebookService {

    private final NotebookRepository notebookRepository;

    @Transactional
    public NotebookResponse create(
            String title,
            String description) {

        Notebook notebook = new Notebook(title, description);

        Notebook savedNotebook = notebookRepository.save(notebook);

        return toResponse(savedNotebook);
    }

    public NotebookResponse findById(UUID id) {

        Notebook notebook = notebookRepository.findById(id)
                .orElseThrow(() -> new NotebookNotFoundException(id));

        return toResponse(notebook);
    }

    private NotebookResponse toResponse(Notebook notebook) {
        return new NotebookResponse(
                notebook.getId(),
                notebook.getTitle(),
                notebook.getDescription(),
                notebook.getCreatedAt(),
                notebook.getUpdatedAt()
        );
    }
}