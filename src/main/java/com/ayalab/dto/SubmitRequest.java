package com.ayalab.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "A code submission for a problem")
public record SubmitRequest(
        @Schema(description = "Programming language", example = "javascript", allowableValues = {"javascript"})
        @NotBlank String language,

        @Schema(description = "Solution source code", example = "function solution(arr) { return arr.reverse(); }")
        @NotBlank String code,

        @Schema(description = "true = run all hidden test cases; false = run sample cases only")
        boolean submit
) {
}
