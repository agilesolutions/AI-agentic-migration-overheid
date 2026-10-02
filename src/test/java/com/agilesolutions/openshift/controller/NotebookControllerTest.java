package com.agilesolutions.openshift.controller;

import com.agilesolutions.openshift.api.model.CreateNotebookRequest;
import com.agilesolutions.openshift.api.model.Notebook;
import com.agilesolutions.openshift.service.NotebookService;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

class NotebookControllerTest {

    @Test
    void createNotebook_returnsResponseEntityBody() {
        NotebookService service = Mockito.mock(NotebookService.class);
        NotebookController controller = new NotebookController(service);

        Notebook resp = new Notebook(UUID.randomUUID(), "T", "D", OffsetDateTime.now(), OffsetDateTime.now());
        when(service.createNotebook(any(CreateNotebookRequest.class))).thenReturn(resp);

        CreateNotebookRequest req = new CreateNotebookRequest();
        req.setTitle("T");
        req.setDescription("D");

        var response = controller.createNotebook(req);

        assertThat(response.getStatusCode().value()).isEqualTo(201);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getTitle()).isEqualTo("T");
    }

    @Test
    void getNotebook_and_getAll_returnResponses() {
        NotebookService service = Mockito.mock(NotebookService.class);
        NotebookController controller = new NotebookController(service);

        UUID id = UUID.randomUUID();
        Notebook resp = new Notebook(id, "T2", "D2", OffsetDateTime.now(), OffsetDateTime.now());
        when(service.getNotebookById(id)).thenReturn(resp);
        when(service.getAllNotebooks()).thenReturn(List.of(resp));

        var single = controller.getNotebookById(id);
        var all = controller.getAllNotebooks();

        assertThat(single.getBody()).isNotNull();
        assertThat(single.getBody().getId()).isEqualTo(id);
        assertThat(all.getBody()).hasSize(1);
    }
}