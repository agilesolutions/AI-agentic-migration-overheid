package com.agilesolutions.openshift.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Schema(description = "Request to create a notebook")
public record CreateNotebookRequest(

        @Schema(
                description = "Name of the notebook",
                example = "Work Notes",
                maxLength = 255,
                requiredMode = Schema.RequiredMode.REQUIRED
        )
        @NotBlank(message = "Title is required")
        @Size(
                max = 255,
                message = "Title must not exceed 255 characters"
        )
        String title,

        @Schema(
                description = "Optional description of the notebook",
                example = "Notes and information related to work"
        )
        String description
) {
}