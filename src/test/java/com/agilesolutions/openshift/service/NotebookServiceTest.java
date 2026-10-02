package com.agilesolutions.openshift.service;

import com.agilesolutions.openshift.entity.Notebook;
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
        Notebook saved = new Notebook("T","D");
        saved.setId(UUID.randomUUID());
        saved.setCreatedAt(OffsetDateTime.now());
        saved.setUpdatedAt(OffsetDateTime.now());

        when(notebookRepository.save(any(Notebook.class))).thenReturn(saved);

        var resp = notebookService.create("T","D");

        assertThat(resp.title()).isEqualTo("T");
        verify(notebookRepository).save(any(Notebook.class));
    }

    @Test
    void findById_returnsResponse() {
        UUID id = UUID.randomUUID();
        Notebook nb = new Notebook("TT","DD");
        nb.setId(id);
        nb.setCreatedAt(OffsetDateTime.now());
        nb.setUpdatedAt(OffsetDateTime.now());

        when(notebookRepository.findById(id)).thenReturn(Optional.of(nb));

        var resp = notebookService.findById(id);

        assertThat(resp.id()).isEqualTo(id);
        assertThat(resp.title()).isEqualTo("TT");
    }

    @Test
    void findAll_returnsList() {
        Notebook a = new Notebook("A","a");
        a.setId(UUID.randomUUID());
        a.setCreatedAt(OffsetDateTime.now());
        a.setUpdatedAt(OffsetDateTime.now());

        Notebook b = new Notebook("B","b");
        b.setId(UUID.randomUUID());
        b.setCreatedAt(OffsetDateTime.now());
        b.setUpdatedAt(OffsetDateTime.now());

        when(notebookRepository.findAll()).thenReturn(List.of(a, b));

        var list = notebookService.findAll();

        assertThat(list).hasSize(2);
    }
}