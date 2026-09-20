package com.agilesolutions.openshift.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/notebooks")
@RequiredArgsConstructor
@Tag(
        name = "Notebooks",
        description = "REST API for managing notebooks"
)
public class NotebookController {

    private final NotebookService notebookService;

    @Operation(
            summary = "Create a notebook",
            description = "Creates a new notebook"
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "201",
                    description = "Notebook created successfully"
            ),
            @ApiResponse(
                    responseCode = "400",
                    description = "Invalid request",
                    content = @Content(
                            schema = @Schema(
                                    implementation = ErrorResponse.class
                            )
                    )
            )
    })
    @PostMapping
    public ResponseEntity<NotebookResponse> createNotebook(
            @Valid @RequestBody CreateNotebookRequest request) {

        NotebookResponse response = notebookService.create(
                request.title(),
                request.description()
        );

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(response);
    }

    @Operation(
            summary = "Get a notebook",
            description = "Returns a notebook by its UUID"
    )
    @ApiResponses({
            @ApiResponse(
                    responseCode = "200",
                    description = "Notebook found"
            ),
            @ApiResponse(
                    responseCode = "404",
                    description = "Notebook not found",
                    content = @Content(
                            schema = @Schema(
                                    implementation = ErrorResponse.class
                            )
                    )
            )
    })
    @GetMapping("/{id}")
    public NotebookResponse getNotebook(
            @Parameter(
                    description = "Notebook UUID",
                    required = true,
                    example = "550e8400-e29b-41d4-a716-446655440000"
            )
            @PathVariable UUID id) {

        return notebookService.findById(id);
    }
}