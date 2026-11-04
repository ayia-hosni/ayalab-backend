package com.ayalab.service;

import com.ayalab.dto.LessonDetail;
import com.ayalab.dto.LessonSummary;
import com.ayalab.entity.Lesson;
import com.ayalab.repository.LessonRepository;
import com.ayalab.repository.LessonSlideRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Read side: published lessons, localized for a single locale. */
@Service
@Transactional(readOnly = true)
public class LessonService {

    private final LessonRepository lessons;
    private final LessonSlideRepository slides;
    private final LessonMapper mapper;

    public LessonService(LessonRepository lessons, LessonSlideRepository slides, LessonMapper mapper) {
        this.lessons = lessons;
        this.slides = slides;
        this.mapper = mapper;
    }

    public List<LessonSummary> list(String locale) {
        Map<Long, Integer> counts = new HashMap<>();
        for (Object[] row : slides.countGroupedByLesson()) {
            counts.put((Long) row[0], ((Long) row[1]).intValue());
        }
        return lessons.findPublishedWithTaxonomy().stream()
                .map(l -> mapper.toSummary(l, locale, counts.getOrDefault(l.getId(), 0)))
                .toList();
    }

    /** {@code idOrSlug} accepts a numeric id too, so links from before slugs existed keep working. */
    public LessonDetail get(String idOrSlug, String locale) {
        Lesson lesson = find(idOrSlug);
        if (!lesson.isPublished()) throw new NotFoundException("Lesson not found: " + idOrSlug);
        return mapper.toDetail(lesson, locale, slides.findByLessonIdOrderByOrdinal(lesson.getId()));
    }

    private Lesson find(String idOrSlug) {
        var found = idOrSlug.chars().allMatch(Character::isDigit)
                ? lessons.findByIdWithTaxonomy(Long.valueOf(idOrSlug))
                : lessons.findBySlugWithTaxonomy(idOrSlug);
        return found.orElseThrow(() -> new NotFoundException("Lesson not found: " + idOrSlug));
    }
}
