package com.ayalab.controller;

import com.ayalab.dto.LessonDetail;
import com.ayalab.dto.LessonSummary;
import com.ayalab.repository.LessonRepository;
import com.ayalab.repository.LessonSlideRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Lessons", description = "Browse the bilingual lesson slide decks")
@RestController
@RequestMapping("/api/lessons")
public class LessonController {

    private final LessonRepository lessons;
    private final LessonSlideRepository slides;

    public LessonController(LessonRepository lessons, LessonSlideRepository slides) {
        this.lessons = lessons;
        this.slides  = slides;
    }

    @Operation(summary = "List lessons", description = "Returns all lessons in display order, without slide bodies.")
    @ApiResponse(responseCode = "200", description = "List of lessons")
    @GetMapping
    @Transactional(readOnly = true)
    public List<LessonSummary> list() {
        return lessons.findAllByOrderByOrdinal().stream()
                .map(l -> LessonSummary.from(l, slides.countByLessonId(l.getId())))
                .toList();
    }

    @Operation(summary = "Get lesson detail", description = "Returns a lesson including its ordered slides.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lesson found"),
            @ApiResponse(responseCode = "404", description = "No lesson with that id")
    })
    @GetMapping("/{id}")
    @Transactional(readOnly = true)
    public ResponseEntity<LessonDetail> get(@PathVariable Long id) {
        return lessons.findById(id)
                .map(l -> ResponseEntity.ok(LessonDetail.from(l, slides.findByLessonIdOrderByOrdinal(id))))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
