package com.ayalab.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;

import java.util.List;
import java.util.Map;

public record AdminLessonRequest(
        @NotBlank @Size(max = 150)
        @Pattern(regexp = "[a-z0-9]+(-[a-z0-9]+)*", message = "slug must be lowercase letters, digits and dashes")
        String slug,
        @PositiveOrZero int ordinal,
        @NotBlank @Size(max = 32) String icon,
        boolean published,
        @NotNull Long sectionId,
        Long categoryId,
        @NotEmpty Map<@NotBlank String, @Valid @NotNull LessonTextDto> translations,
        @NotNull List<@Valid AdminSlideRequest> slides
) {
    public record LessonTextDto(@NotBlank String title, @NotBlank String description) {}
}
