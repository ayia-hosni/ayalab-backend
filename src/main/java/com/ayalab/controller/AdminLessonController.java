package com.ayalab.controller;

import com.ayalab.dto.AdminLessonDto;
import com.ayalab.dto.AdminLessonRequest;
import com.ayalab.dto.AdminTaxonomyDto;
import com.ayalab.dto.TaxonomyRequest;
import com.ayalab.service.AdminLessonService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Admin", description = "Lesson content management")
@RestController
@RequestMapping("/api/admin/lessons")
public class AdminLessonController {

    private final AdminLessonService service;

    public AdminLessonController(AdminLessonService service) {
        this.service = service;
    }

    @GetMapping
    public List<AdminLessonDto> list() {
        return service.list();
    }

    @GetMapping("/{id}")
    public AdminLessonDto get(@PathVariable Long id) {
        return service.get(id);
    }

    @PostMapping
    public AdminLessonDto create(@Valid @RequestBody AdminLessonRequest req) {
        return service.create(req);
    }

    @PutMapping("/{id}")
    public AdminLessonDto update(@PathVariable Long id, @Valid @RequestBody AdminLessonRequest req) {
        return service.update(id, req);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.noContent().build();
    }

    // ── taxonomy (sections / categories) ──────────────────────────────────────

    @GetMapping("/taxonomy")
    public AdminTaxonomyDto taxonomy() {
        return service.taxonomy();
    }

    @PostMapping("/taxonomy/sections")
    public AdminTaxonomyDto createSection(@Valid @RequestBody TaxonomyRequest req) {
        return service.createSection(req);
    }

    @PostMapping("/taxonomy/categories")
    public AdminTaxonomyDto createCategory(@Valid @RequestBody TaxonomyRequest req) {
        return service.createCategory(req);
    }
}
