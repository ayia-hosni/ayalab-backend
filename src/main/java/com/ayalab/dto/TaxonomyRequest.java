package com.ayalab.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Pattern;

import java.util.Map;

/** Used to create a section (sectionId ignored) or a category (sectionId required). */
public record TaxonomyRequest(
        @NotBlank @Pattern(regexp = "[a-z0-9]+(-[a-z0-9]+)*") String slug,
        Long sectionId,
        @NotEmpty Map<@NotBlank String, @NotBlank String> names
) {}
