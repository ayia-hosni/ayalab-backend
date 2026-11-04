package com.ayalab.dto;

import com.fasterxml.jackson.databind.JsonNode;

import java.util.List;
import java.util.Map;

/** Full lesson with every locale, for the editor. */
public record AdminLessonDto(
        Long    id,
        String  slug,
        int     ordinal,
        String  icon,
        boolean published,
        Long    sectionId,
        Long    categoryId,
        Map<String, AdminLessonRequest.LessonTextDto> translations,
        List<AdminSlideDto> slides
) {
    public record AdminSlideDto(
            Long     id,
            int      ordinal,
            JsonNode spec,
            Map<String, AdminSlideRequest.SlideTextDto> translations
    ) {}
}
