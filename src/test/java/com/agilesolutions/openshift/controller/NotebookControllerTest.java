package com.agilesolutions.openshift.controller;

import com.agilesolutions.openshift.dto.CreateNotebookRequest;
import com.agilesolutions.openshift.dto.NotebookResponse;
import com.agilesolutions.openshift.service.NotebookService;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;

class NotebookControllerTest {

    @Test
    void createNotebook_returnsResponseEntityBody() {
        NotebookService service = Mockito.mock(NotebookService.class);
        NotebookController controller = new NotebookController(service);

        NotebookResponse resp = new NotebookResponse(UUID.randomUUID(), "T", "D", OffsetDateTime.now(), OffsetDateTime.now());
        when(service.create(anyString(), anyString())).thenReturn(resp);

        CreateNotebookRequest req = new CreateNotebookRequest("T", "D");
        var response = controller.createNotebook(req);

        assertThat(response.getStatusCode().value()).isEqualTo(201);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().title()).isEqualTo("T");
    }

    @Test
    void getNotebook_and_getAll_returnResponses() {
        NotebookService service = Mockito.mock(NotebookService.class);
        NotebookController controller = new NotebookController(service);

        UUID id = UUID.randomUUID();
        NotebookResponse resp = new NotebookResponse(id, "T2", "D2", OffsetDateTime.now(), OffsetDateTime.now());
        when(service.findById(id)).thenReturn(resp);
        when(service.findAll()).thenReturn(List.of(resp));

        var single = controller.getNotebook(id);
        var all = controller.getAllNotebooks();

        assertThat(single.id()).isEqualTo(id);
        assertThat(all).hasSize(1);
    }
}