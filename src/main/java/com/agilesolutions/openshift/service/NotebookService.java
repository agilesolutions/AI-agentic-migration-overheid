package com.agilesolutions.openshift.service;

import com.agilesolutions.openshift.api.model.CreateNotebookRequest;
import com.agilesolutions.openshift.api.model.Notebook;
import com.agilesolutions.openshift.api.model.UpdateNotebookRequest;
import com.agilesolutions.openshift.entity.NotebookEntity;
import com.agilesolutions.openshift.exception.NotebookNotFoundException;
import com.agilesolutions.openshift.repository.NotebookRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class NotebookService {

    private final NotebookRepository repository;


    public NotebookService(NotebookRepository repository) {
        this.repository = repository;
    }


    @Transactional(readOnly = true)
    public List<Notebook> getAllNotebooks() {

        return repository.findAll()
                .stream()
                .map(this::toApiModel)
                .toList();
    }


    @Transactional(readOnly = true)
    public Notebook getNotebookById(UUID id) {

        NotebookEntity entity = repository.findById(id)
                .orElseThrow(() ->
                        new NotebookNotFoundException(id));

        return toApiModel(entity);
    }


    public Notebook createNotebook(
            CreateNotebookRequest request) {

        NotebookEntity entity = new NotebookEntity();

        entity.setTitle(request.getTitle());
        entity.setDescription(request.getDescription());

        NotebookEntity saved =
                repository.save(entity);

        return toApiModel(saved);
    }


    public Notebook updateNotebook(
            UUID id,
            UpdateNotebookRequest request) {

        NotebookEntity entity = repository.findById(id)
                .orElseThrow(() ->
                        new NotebookNotFoundException(id));

        entity.setTitle(request.getTitle());
        entity.setDescription(request.getDescription());

        NotebookEntity saved =
                repository.save(entity);

        return toApiModel(saved);
    }


    public void deleteNotebook(UUID id) {

        if (!repository.existsById(id)) {
            throw new NotebookNotFoundException(id);
        }

        repository.deleteById(id);
    }


    private Notebook toApiModel(
            NotebookEntity entity) {

        Notebook notebook = new Notebook();

        notebook.setId(entity.getId());
        notebook.setTitle(entity.getTitle());
        notebook.setDescription(entity.getDescription());
        notebook.setCreatedAt(entity.getCreatedAt());
        notebook.setUpdatedAt(entity.getUpdatedAt());

        return notebook;
    }
}