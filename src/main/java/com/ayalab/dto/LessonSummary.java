package com.ayalab.dto;

import com.ayalab.entity.Lesson;

public record LessonSummary(
        Long   id,
        int    ordinal,
        String icon,
        String titleEn,
        String titleAr,
        String descriptionEn,
        String descriptionAr,
        String sectionEn,
        String sectionAr,
        String categoryEn,
        String categoryAr,
        int    slideCount
) {
    public static LessonSummary from(Lesson l, long slideCount) {
        return new LessonSummary(
                l.getId(), l.getOrdinal(), l.getIcon(),
                l.getTitleEn(), l.getTitleAr(),
                l.getDescriptionEn(), l.getDescriptionAr(),
                l.getSectionEn(), l.getSectionAr(),
                l.getCategoryEn(), l.getCategoryAr(),
                (int) slideCount
        );
    }
}
