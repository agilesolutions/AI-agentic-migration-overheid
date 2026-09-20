package com.agilesolutions.openshift.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.OffsetDateTime;
import java.util.UUID;

@Schema(description = "Notebook")
public record NotebookResponse(

        @Schema(
                description = "Unique identifier of the notebook",
                example = "550e8400-e29b-41d4-a716-446655440000"
        )
        UUID id,

        @Schema(
                description = "Name of the notebook",
                example = "Work Notes"
        )
        String title,

        @Schema(
                description = "Description of the notebook",
                example = "Notes and information related to work"
        )
        String description,

        @Schema(
                description = "Timestamp when the notebook was created",
                example = "2026-09-20T10:15:30Z"
        )
        OffsetDateTime createdAt,

        @Schema(
                description = "Timestamp when the notebook was last updated",
                example = "2026-09-20T10:20:00Z"
        )
        OffsetDateTime updatedAt
) {
}