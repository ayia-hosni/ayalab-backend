package com.ayalab.controller;

import com.ayalab.dto.ProblemDetail;
import com.ayalab.dto.ProblemSummary;
import com.ayalab.service.ProblemService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/problems")
public class ProblemController {

    private final ProblemService service;

    public ProblemController(ProblemService service) {
        this.service = service;
    }

    /** GET /api/problems?difficulty=easy&status=solved&search=reverse&tag=Linked List */
    @GetMapping
    public List<ProblemSummary> list(
            @RequestParam(required = false) String difficulty,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String tag) {
        return service.list(difficulty, status, search, tag);
    }

    /** GET /api/problems/tags -> distinct sorted tag list for the filter chips. */
    @GetMapping("/tags")
    public List<String> tags() {
        return service.allTags();
    }

    /** GET /api/problems/{slug} -> full detail. */
    @GetMapping("/{slug}")
    public ResponseEntity<ProblemDetail> get(@PathVariable String slug) {
        return service.getBySlug(slug)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
