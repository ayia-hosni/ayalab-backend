package com.ayalab.controller;

import com.ayalab.dto.LessonDetail;
import com.ayalab.dto.LessonSummary;
import com.ayalab.service.LessonService;
import com.ayalab.service.Locales;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Lessons", description = "Browse the lesson slide decks")
@RestController
@RequestMapping("/api/lessons")
public class LessonController {

    private final LessonService service;

    public LessonController(LessonService service) {
        this.service = service;
    }

    @Operation(summary = "List lessons",
            description = "Published lessons in display order, localized. Locale comes from ?lang= or Accept-Language (en fallback).")
    @ApiResponse(responseCode = "200", description = "List of lessons")
    @GetMapping
    public ResponseEntity<List<LessonSummary>> list(
            @RequestParam(required = false) String lang,
            @RequestHeader(name = HttpHeaders.ACCEPT_LANGUAGE, required = false) String acceptLanguage) {
        return varyOnLanguage(service.list(Locales.resolve(lang, acceptLanguage)));
    }

    @Operation(summary = "Get lesson detail",
            description = "A lesson with its ordered slides. Accepts a slug, or a numeric id for older links.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lesson found"),
            @ApiResponse(responseCode = "404", description = "No published lesson with that slug or id")
    })
    @GetMapping("/{idOrSlug}")
    public ResponseEntity<LessonDetail> get(
            @PathVariable String idOrSlug,
            @RequestParam(required = false) String lang,
            @RequestHeader(name = HttpHeaders.ACCEPT_LANGUAGE, required = false) String acceptLanguage) {
        return varyOnLanguage(service.get(idOrSlug, Locales.resolve(lang, acceptLanguage)));
    }

    private static <T> ResponseEntity<T> varyOnLanguage(T body) {
        return ResponseEntity.ok().header(HttpHeaders.VARY, HttpHeaders.ACCEPT_LANGUAGE).body(body);
    }
}
