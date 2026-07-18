package com.ayalab.dto;

import com.ayalab.entity.Lesson;
import com.ayalab.entity.LessonSlide;

import java.util.List;

public record LessonDetail(
        Long   id,
        int    ordinal,
        String icon,
        String titleEn,
        String titleAr,
        String descriptionEn,
        String descriptionAr,
        List<SlideDto> slides
) {
    public static LessonDetail from(Lesson l, List<LessonSlide> slides) {
        return new LessonDetail(
                l.getId(), l.getOrdinal(), l.getIcon(),
                l.getTitleEn(), l.getTitleAr(),
                l.getDescriptionEn(), l.getDescriptionAr(),
                slides.stream().map(SlideDto::from).toList()
        );
    }
}
