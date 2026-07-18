package com.ayalab.controller;

import com.ayalab.dto.AdminLessonRequest;
import com.ayalab.dto.AdminSlideRequest;
import com.ayalab.dto.LessonDetail;
import com.ayalab.entity.Lesson;
import com.ayalab.entity.LessonSlide;
import com.ayalab.repository.LessonRepository;
import com.ayalab.repository.LessonSlideRepository;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Admin", description = "Lesson content management")
@RestController
@RequestMapping("/api/admin/lessons")
public class AdminLessonController {

    private final LessonRepository lessons;
    private final LessonSlideRepository slides;

    public AdminLessonController(LessonRepository lessons, LessonSlideRepository slides) {
        this.lessons = lessons;
        this.slides  = slides;
    }

    @GetMapping
    @Transactional(readOnly = true)
    public List<LessonDetail> list() {
        return lessons.findAllByOrderByOrdinal().stream()
                .map(l -> LessonDetail.from(l, slides.findByLessonIdOrderByOrdinal(l.getId())))
                .toList();
    }

    @GetMapping("/{id}")
    @Transactional(readOnly = true)
    public ResponseEntity<LessonDetail> get(@PathVariable Long id) {
        return lessons.findById(id)
                .map(l -> ResponseEntity.ok(LessonDetail.from(l, slides.findByLessonIdOrderByOrdinal(id))))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    @Transactional
    public ResponseEntity<LessonDetail> create(@RequestBody AdminLessonRequest req) {
        Lesson l = applyRequest(new Lesson(), req);
        lessons.save(l);
        saveSlides(l.getId(), req);
        return ResponseEntity.ok(LessonDetail.from(l, slides.findByLessonIdOrderByOrdinal(l.getId())));
    }

    @PutMapping("/{id}")
    @Transactional
    public ResponseEntity<LessonDetail> update(@PathVariable Long id, @RequestBody AdminLessonRequest req) {
        return lessons.findById(id).map(l -> {
            applyRequest(l, req);
            lessons.save(l);
            slides.deleteAll(slides.findByLessonIdOrderByOrdinal(id));
            saveSlides(id, req);
            return ResponseEntity.ok(LessonDetail.from(l, slides.findByLessonIdOrderByOrdinal(id)));
        }).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    @Transactional
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (!lessons.existsById(id)) return ResponseEntity.notFound().build();
        slides.deleteAll(slides.findByLessonIdOrderByOrdinal(id));
        lessons.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    // ── helpers ───────────────────────────────────────────────────────────────

    private Lesson applyRequest(Lesson l, AdminLessonRequest req) {
        l.setOrdinal(req.ordinal());
        l.setIcon(req.icon());
        l.setTitleEn(req.titleEn());
        l.setTitleAr(req.titleAr());
        l.setDescriptionEn(req.descriptionEn());
        l.setDescriptionAr(req.descriptionAr());
        return l;
    }

    private void saveSlides(Long lessonId, AdminLessonRequest req) {
        if (req.slides() == null) return;
        List<LessonSlide> toSave = req.slides().stream()
                .map(s -> toEntity(lessonId, s))
                .toList();
        slides.saveAll(toSave);
    }

    private LessonSlide toEntity(Long lessonId, AdminSlideRequest s) {
        return new LessonSlide(lessonId, s.ordinal(), s.kickerEn(), s.kickerAr(),
                s.titleEn(), s.titleAr(), s.visual(), s.visualSpec(), s.bodyEn(), s.bodyAr());
    }
}
