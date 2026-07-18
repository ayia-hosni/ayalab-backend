package com.ayalab.dto;

import com.ayalab.entity.LessonSlide;

public record SlideDto(
        Long   id,
        int    ordinal,
        String kickerEn,
        String kickerAr,
        String titleEn,
        String titleAr,
        String visual,
        String visualSpec,
        String bodyEn,
        String bodyAr
) {
    public static SlideDto from(LessonSlide s) {
        return new SlideDto(
                s.getId(), s.getOrdinal(),
                s.getKickerEn(), s.getKickerAr(),
                s.getTitleEn(), s.getTitleAr(),
                s.getVisual(), s.getVisualSpec(),
                s.getBodyEn(), s.getBodyAr()
        );
    }
}
