package com.ayalab.dto;

import com.fasterxml.jackson.databind.JsonNode;

/** A slide in one locale. {@code visual} is the structured spec; the client renders it. */
public record SlideDto(
        Long     id,
        int      ordinal,
        String   kicker,
        String   title,
        String   body,
        JsonNode visual
) {}
