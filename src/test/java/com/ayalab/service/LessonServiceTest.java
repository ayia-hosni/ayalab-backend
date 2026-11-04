package com.ayalab.service;

import com.ayalab.dto.LessonDetail;
import com.ayalab.dto.LessonSummary;
import com.ayalab.entity.Lesson;
import com.ayalab.entity.LessonCategory;
import com.ayalab.entity.LessonSection;
import com.ayalab.entity.LessonSlide;
import com.ayalab.entity.LessonText;
import com.ayalab.entity.SlideText;
import com.ayalab.repository.LessonRepository;
import com.ayalab.repository.LessonSlideRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Collections;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class LessonServiceTest {

    private final LessonRepository lessons = mock(LessonRepository.class);
    private final LessonSlideRepository slides = mock(LessonSlideRepository.class);
    private final LessonService service = new LessonService(lessons, slides, new LessonMapper());

    private Lesson lesson;

    @BeforeEach
    void setUp() throws Exception {
        LessonSection section = new LessonSection("linked-lists", 0, Map.of("en", "Linked Lists", "ar", "القوائم"));
        LessonCategory category = new LessonCategory(1L, "insertion", 0, Map.of("en", "Insertion"));
        lesson = new Lesson();
        ReflectionTestUtils.setField(lesson, "id", 7L);
        lesson.setSlug("insert-first");
        lesson.setIcon("x");
        lesson.setSection(section);
        lesson.setCategory(category);
        lesson.replaceTranslations(Map.of(
                "en", new LessonText("Insert First", "desc"),
                "ar", new LessonText("إضافة في الأول", "وصف")));

        LessonSlide slide = new LessonSlide(7L);
        ReflectionTestUtils.setField(slide, "id", 70L);
        slide.setSpec(new ObjectMapper().readTree("{\"kind\":\"chain\",\"frames\":[]}"));
        slide.replaceTranslations(Map.of("en", new SlideText("k", "t", "<p>b</p>")));

        when(lessons.findPublishedWithTaxonomy()).thenReturn(List.of(lesson));
        when(lessons.findBySlugWithTaxonomy("insert-first")).thenReturn(Optional.of(lesson));
        when(lessons.findByIdWithTaxonomy(7L)).thenReturn(Optional.of(lesson));
        when(slides.countGroupedByLesson()).thenReturn(Collections.singletonList(new Object[]{7L, 1L}));
        when(slides.findByLessonIdOrderByOrdinal(7L)).thenReturn(List.of(slide));
    }

    @Test
    void listIsLocalizedAndCountsSlidesWithoutPerLessonQueries() {
        LessonSummary s = service.list("ar").get(0);
        assertThat(s.title()).isEqualTo("إضافة في الأول");
        assertThat(s.section().name()).isEqualTo("القوائم");
        assertThat(s.category().name()).isEqualTo("Insertion"); // no AR name -> English fallback
        assertThat(s.slideCount()).isEqualTo(1);
    }

    @Test
    void getBySlugReturnsSlidesWithSpecAndFallbackText() {
        LessonDetail d = service.get("insert-first", "ar");
        assertThat(d.title()).isEqualTo("إضافة في الأول");
        assertThat(d.slides()).hasSize(1);
        assertThat(d.slides().get(0).title()).isEqualTo("t"); // slide has only English
        assertThat(d.slides().get(0).visual().path("kind").asText()).isEqualTo("chain");
    }

    @Test
    void numericIdStillResolves() {
        assertThat(service.get("7", "en").slug()).isEqualTo("insert-first");
    }

    @Test
    void unpublishedAndMissingLessonsAreNotFound() {
        lesson.setPublished(false);
        assertThatThrownBy(() -> service.get("insert-first", "en")).isInstanceOf(NotFoundException.class);
        assertThatThrownBy(() -> service.get("nope", "en")).isInstanceOf(NotFoundException.class);
    }
}
