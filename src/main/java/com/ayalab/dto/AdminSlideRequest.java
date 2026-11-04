package com.ayalab.dto;

import com.fasterxml.jackson.databind.JsonNode;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.Map;

/** {@code id} is null for a new slide; an existing id keeps its row (and id) stable across saves. */
public record AdminSlideRequest(
        Long id,
        @NotNull JsonNode spec,
        @NotEmpty Map<@NotBlank String, @Valid @NotNull SlideTextDto> translations
) {
    public record SlideTextDto(@NotBlank String kicker, @NotBlank String title, @NotBlank String body) {}
}
