package com.agilesolutions.openshift.service;

import com.agilesolutions.openshift.api.model.CreateNotebookRequest;
import com.agilesolutions.openshift.entity.NotebookEntity;
import com.agilesolutions.openshift.repository.NotebookRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class NotebookServiceTest {

    @Mock
    NotebookRepository notebookRepository;

    @InjectMocks
    NotebookService notebookService;

    @Test
    void create_callsRepositoryAndReturnsResponse() {
        NotebookEntity saved = new NotebookEntity("T", "D");
        saved.setId(UUID.randomUUID());
        saved.setCreatedAt(OffsetDateTime.now());
        saved.setUpdatedAt(OffsetDateTime.now());

        when(notebookRepository.save(any(NotebookEntity.class))).thenReturn(saved);

        CreateNotebookRequest request = new CreateNotebookRequest();
        request.setTitle("T");
        request.setDescription("D");

        var resp = notebookService.createNotebook(request);

        assertThat(resp.getTitle()).isEqualTo("T");
        verify(notebookRepository).save(any(NotebookEntity.class));
    }

    @Test
    void findById_returnsResponse() {
        UUID id = UUID.randomUUID();
        NotebookEntity nb = new NotebookEntity("TT", "DD");
        nb.setId(id);
        nb.setCreatedAt(OffsetDateTime.now());
        nb.setUpdatedAt(OffsetDateTime.now());

        when(notebookRepository.findById(id)).thenReturn(Optional.of(nb));

        var resp = notebookService.getNotebookById(id);

        assertThat(resp.getId()).isEqualTo(id);
        assertThat(resp.getTitle()).isEqualTo("TT");
    }

    @Test
    void findAll_returnsList() {
        NotebookEntity a = new NotebookEntity("A", "a");
        a.setId(UUID.randomUUID());
        a.setCreatedAt(OffsetDateTime.now());
        a.setUpdatedAt(OffsetDateTime.now());

        NotebookEntity b = new NotebookEntity("B", "b");
        b.setId(UUID.randomUUID());
        b.setCreatedAt(OffsetDateTime.now());
        b.setUpdatedAt(OffsetDateTime.now());

        when(notebookRepository.findAll()).thenReturn(List.of(a, b));

        var list = notebookService.getAllNotebooks();

        assertThat(list).hasSize(2);
    }
}