package com.ayalab.dto;

import java.util.List;

public record AdminLessonRequest(
        int    ordinal,
        String icon,
        String titleEn,
        String titleAr,
        String descriptionEn,
        String descriptionAr,
        List<AdminSlideRequest> slides
) {}
