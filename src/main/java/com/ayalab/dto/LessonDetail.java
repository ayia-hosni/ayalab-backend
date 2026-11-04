package com.ayalab.dto;

import java.util.List;

public record LessonDetail(
        Long        id,
        String      slug,
        int         ordinal,
        String      icon,
        String      title,
        String      description,
        TaxonomyRef section,
        TaxonomyRef category,
        List<SlideDto> slides
) {}
