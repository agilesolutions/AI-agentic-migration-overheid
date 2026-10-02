package com.agilesolutions.openshift.controller;

import com.agilesolutions.openshift.api.model.Notebook;
import com.agilesolutions.openshift.dto.CreateNotebookRequest;
import com.agilesolutions.openshift.dto.NotebookResponse;
import com.agilesolutions.openshift.service.NotebookService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

import static org.hamcrest.Matchers.hasSize;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class NotebookControllerMockMvcTest {

    ObjectMapper objectMapper = new ObjectMapper();

    @Test
    @DisplayName("POST /api/notebooks - success returns 201 and body")
    void postCreateNotebook_returnsCreated() throws Exception {
        NotebookService notebookService = Mockito.mock(NotebookService.class);
        UUID id = UUID.randomUUID();
        Notebook resp = new Notebook(id, "T", "D", OffsetDateTime.now(), OffsetDateTime.now());
        when(notebookService.createNotebook(any())).thenReturn(resp);

        CreateNotebookRequest req = new CreateNotebookRequest("T", "D");
        NotebookController controller = new NotebookController(notebookService);
        MockMvc mockMvc = MockMvcBuilders.standaloneSetup(controller).build();

        mockMvc.perform(post("/api/v1/notebooks")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.title").value("T"))
                .andExpect(jsonPath("$.id").isNotEmpty());
    }

    @Test
    @DisplayName("GET /api/notebooks/{id} and /api/notebooks - returns single and list")
    void getEndpoints_returnNotebookAndList() throws Exception {
        NotebookService notebookService = Mockito.mock(NotebookService.class);
        UUID id = UUID.randomUUID();
        Notebook resp = new Notebook(id, "T2", "D2", OffsetDateTime.now(), OffsetDateTime.now());
        when(notebookService.getNotebookById(id)).thenReturn(resp);
        when(notebookService.getAllNotebooks()).thenReturn(List.of(resp));

        NotebookController controller = new NotebookController(notebookService);
        MockMvc mockMvc = MockMvcBuilders.standaloneSetup(controller).build();

        mockMvc.perform(get("/api/v1/notebooks/{id}", id))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(id.toString()))
                .andExpect(jsonPath("$.title").value("T2"));

        mockMvc.perform(get("/api/v1/notebooks"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)));
    }
}
