package com.ayalab.dto;

public record LessonSummary(
        Long        id,
        String      slug,
        int         ordinal,
        String      icon,
        String      title,
        String      description,
        TaxonomyRef section,
        TaxonomyRef category,
        int         slideCount
) {}
