package com.agilesolutions.openshift.service;

import com.agilesolutions.openshift.dto.NotebookResponse;
import com.agilesolutions.openshift.entity.Notebook;
import com.agilesolutions.openshift.exception.NotebookNotFoundException;
import com.agilesolutions.openshift.repository.NotebookRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class NotebookService {

    private final NotebookRepository notebookRepository;

    @Transactional
    public NotebookResponse create(
            String title,
            String description) {

        log.info("Saving notebook with title {}", title);


        Notebook notebook = new Notebook(title, description);

        Notebook savedNotebook = notebookRepository.save(notebook);

        log.info("Saved notebook with title {}", title);

        return toResponse(savedNotebook);
    }

    public NotebookResponse findById(UUID id) {

        Notebook notebook = notebookRepository.findById(id)
                .orElseThrow(() -> new NotebookNotFoundException(id));

        log.info("Searching notebook by id {}", id);

        return toResponse(notebook);
    }

    public List<NotebookResponse> findAll() {

        log.info("Listing up all notebooks");

        return notebookRepository.findAll()
                .stream()
                .map(this::toResponse)
                .toList();
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