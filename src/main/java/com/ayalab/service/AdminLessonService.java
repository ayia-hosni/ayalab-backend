package com.ayalab.service;

import com.ayalab.dto.AdminLessonDto;
import com.ayalab.dto.AdminLessonRequest;
import com.ayalab.dto.AdminSlideRequest;
import com.ayalab.dto.AdminTaxonomyDto;
import com.ayalab.dto.TaxonomyRequest;
import com.ayalab.entity.Lesson;
import com.ayalab.entity.LessonCategory;
import com.ayalab.entity.LessonSection;
import com.ayalab.entity.LessonSlide;
import com.ayalab.entity.LessonText;
import com.ayalab.entity.SlideText;
import com.ayalab.repository.LessonCategoryRepository;
import com.ayalab.repository.LessonRepository;
import com.ayalab.repository.LessonSectionRepository;
import com.ayalab.repository.LessonSlideRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

/** Write side (and full-fidelity reads) for the lesson editor. Validates before it touches the database. */
@Service
@Transactional
public class AdminLessonService {

    private final LessonRepository lessons;
    private final LessonSlideRepository slides;
    private final LessonSectionRepository sections;
    private final LessonCategoryRepository categories;
    private final LessonMapper mapper;
    private final SlideSpecValidator specValidator;
    private final TextSanitizer sanitizer;

    public AdminLessonService(LessonRepository lessons, LessonSlideRepository slides,
                              LessonSectionRepository sections, LessonCategoryRepository categories,
                              LessonMapper mapper, SlideSpecValidator specValidator, TextSanitizer sanitizer) {
        this.lessons = lessons;
        this.slides = slides;
        this.sections = sections;
        this.categories = categories;
        this.mapper = mapper;
        this.specValidator = specValidator;
        this.sanitizer = sanitizer;
    }

    @Transactional(readOnly = true)
    public List<AdminLessonDto> list() {
        List<Lesson> all = lessons.findAllWithTaxonomy();
        Map<Long, List<LessonSlide>> byLesson = slides
                .findByLessonIdInOrderByLessonIdAscOrdinalAsc(all.stream().map(Lesson::getId).toList())
                .stream().collect(Collectors.groupingBy(LessonSlide::getLessonId));
        return all.stream().map(l -> mapper.toAdmin(l, byLesson.getOrDefault(l.getId(), List.of()))).toList();
    }

    @Transactional(readOnly = true)
    public AdminLessonDto get(Long id) {
        Lesson l = lessons.findByIdWithTaxonomy(id).orElseThrow(() -> notFound(id));
        return mapper.toAdmin(l, slides.findByLessonIdOrderByOrdinal(id));
    }

    public AdminLessonDto create(AdminLessonRequest req) {
        validate(req, null);
        Lesson lesson = new Lesson();
        apply(lesson, req);
        lessons.saveAndFlush(lesson);
        syncSlides(lesson.getId(), req.slides());
        return get(lesson.getId());
    }

    public AdminLessonDto update(Long id, AdminLessonRequest req) {
        Lesson lesson = lessons.findByIdWithTaxonomy(id).orElseThrow(() -> notFound(id));
        validate(req, id);
        apply(lesson, req);
        lessons.saveAndFlush(lesson);
        syncSlides(id, req.slides());
        return get(id);
    }

    public void delete(Long id) {
        if (!lessons.existsById(id)) throw notFound(id);
        slides.deleteByLessonId(id);
        lessons.deleteById(id);
    }

    // ── taxonomy ──────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public AdminTaxonomyDto taxonomy() {
        Map<Long, List<AdminTaxonomyDto.Category>> cats = categories.findAllByOrderBySectionIdAscOrdinalAsc().stream()
                .collect(Collectors.groupingBy(LessonCategory::getSectionId, LinkedHashMap::new,
                        Collectors.mapping(c -> new AdminTaxonomyDto.Category(c.getId(), c.getSlug(), c.getOrdinal(),
                                new LinkedHashMap<>(c.getNames())), Collectors.toList())));
        return new AdminTaxonomyDto(sections.findAllByOrderByOrdinal().stream()
                .map(s -> new AdminTaxonomyDto.Section(s.getId(), s.getSlug(), s.getOrdinal(),
                        new LinkedHashMap<>(s.getNames()), cats.getOrDefault(s.getId(), List.of())))
                .toList());
    }

    public AdminTaxonomyDto createSection(TaxonomyRequest req) {
        requireLocales(req.names().keySet(), "names");
        if (sections.existsBySlug(req.slug())) throw new IllegalArgumentException("Section slug already exists: " + req.slug());
        sections.save(new LessonSection(req.slug(), (int) sections.count(), cleanNames(req.names())));
        return taxonomy();
    }

    public AdminTaxonomyDto createCategory(TaxonomyRequest req) {
        if (req.sectionId() == null) throw new IllegalArgumentException("sectionId is required for a category");
        requireLocales(req.names().keySet(), "names");
        if (!sections.existsById(req.sectionId())) throw new IllegalArgumentException("Unknown section: " + req.sectionId());
        if (categories.existsBySectionIdAndSlug(req.sectionId(), req.slug())) {
            throw new IllegalArgumentException("Category slug already exists in that section: " + req.slug());
        }
        long next = categories.findAllByOrderBySectionIdAscOrdinalAsc().stream()
                .filter(c -> c.getSectionId().equals(req.sectionId())).count();
        categories.save(new LessonCategory(req.sectionId(), req.slug(), (int) next, cleanNames(req.names())));
        return taxonomy();
    }

    // ── helpers ───────────────────────────────────────────────────────────────

    private void validate(AdminLessonRequest req, Long existingId) {
        List<String> errors = new ArrayList<>();

        boolean slugTaken = existingId == null
                ? lessons.existsBySlug(req.slug())
                : lessons.existsBySlugAndIdNot(req.slug(), existingId);
        if (slugTaken) errors.add("slug already in use: " + req.slug());

        if (!sections.existsById(req.sectionId())) {
            errors.add("unknown section: " + req.sectionId());
        } else if (req.categoryId() != null) {
            var category = categories.findById(req.categoryId());
            if (category.isEmpty()) errors.add("unknown category: " + req.categoryId());
            else if (!category.get().getSectionId().equals(req.sectionId())) errors.add("category does not belong to the chosen section");
        }

        collectLocaleErrors(req.translations().keySet(), "translations", errors);

        for (int i = 0; i < req.slides().size(); i++) {
            AdminSlideRequest s = req.slides().get(i);
            String where = "slides[" + i + "]";
            collectLocaleErrors(s.translations().keySet(), where + ".translations", errors);
            specValidator.validate(s.spec()).forEach(e -> errors.add(where + ".spec: " + e));
        }

        if (!errors.isEmpty()) throw new IllegalArgumentException(String.join("; ", errors));
    }

    private void requireLocales(Set<String> locales, String field) {
        List<String> errors = new ArrayList<>();
        collectLocaleErrors(locales, field, errors);
        if (!errors.isEmpty()) throw new IllegalArgumentException(String.join("; ", errors));
    }

    private void collectLocaleErrors(Set<String> locales, String field, List<String> errors) {
        if (!locales.contains(Locales.DEFAULT)) errors.add(field + " must include '" + Locales.DEFAULT + "'");
        for (String l : locales) {
            if (!Locales.SUPPORTED.contains(l)) errors.add(field + " has unsupported locale '" + l + "'");
        }
    }

    private void apply(Lesson lesson, AdminLessonRequest req) {
        lesson.setSlug(req.slug());
        lesson.setOrdinal(req.ordinal());
        lesson.setIcon(req.icon());
        lesson.setPublished(req.published());
        lesson.setSection(sections.getReferenceById(req.sectionId()));
        lesson.setCategory(req.categoryId() == null ? null : categories.getReferenceById(req.categoryId()));
        Map<String, LessonText> texts = new HashMap<>();
        req.translations().forEach((loc, t) ->
                texts.put(loc, new LessonText(sanitizer.clean(t.title()), sanitizer.clean(t.description()))));
        lesson.replaceTranslations(texts);
    }

    /**
     * Upserts by id so unchanged slides keep their row; position in the list becomes the ordinal
     * (the unique constraint is deferred, so reordering within a transaction is safe).
     */
    private void syncSlides(Long lessonId, List<AdminSlideRequest> requested) {
        Map<Long, LessonSlide> existing = slides.findByLessonIdOrderByOrdinal(lessonId).stream()
                .collect(Collectors.toMap(LessonSlide::getId, Function.identity()));
        List<LessonSlide> keep = new ArrayList<>();
        for (int i = 0; i < requested.size(); i++) {
            AdminSlideRequest r = requested.get(i);
            LessonSlide slide;
            if (r.id() == null) {
                slide = new LessonSlide(lessonId);
            } else {
                slide = existing.remove(r.id());
                if (slide == null) throw new IllegalArgumentException("slides[" + i + "].id does not belong to this lesson: " + r.id());
            }
            slide.setOrdinal(i);
            slide.setSpec(r.spec());
            Map<String, SlideText> texts = new HashMap<>();
            r.translations().forEach((loc, t) -> texts.put(loc,
                    new SlideText(sanitizer.clean(t.kicker()), sanitizer.clean(t.title()), sanitizer.clean(t.body()))));
            slide.replaceTranslations(texts);
            keep.add(slide);
        }
        slides.deleteAll(existing.values());
        slides.saveAll(keep);
    }

    private Map<String, String> cleanNames(Map<String, String> names) {
        Map<String, String> out = new HashMap<>();
        names.forEach((k, v) -> out.put(k, sanitizer.clean(v)));
        return out;
    }

    private NotFoundException notFound(Long id) {
        return new NotFoundException("Lesson not found: " + id);
    }
}
