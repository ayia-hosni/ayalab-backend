package com.ayalab.controller;

import com.ayalab.dto.ProblemDetail;
import com.ayalab.dto.ProblemSummary;
import com.ayalab.service.ProblemService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Problems", description = "Browse and filter the problem catalogue")
@RestController
@RequestMapping("/api/problems")
public class ProblemController {

    private final ProblemService service;

    public ProblemController(ProblemService service) {
        this.service = service;
    }

    @Operation(summary = "List problems",
            description = "Returns all problems. All filter params are optional and combinable.")
    @ApiResponse(responseCode = "200", description = "List of matching problems")
    @GetMapping
    public List<ProblemSummary> list(
            @Parameter(description = "Difficulty level: `easy`, `medium`, or `hard`")
            @RequestParam(required = false) String difficulty,
            @Parameter(description = "Solve status: `todo`, `attempted`, or `solved`")
            @RequestParam(required = false) String status,
            @Parameter(description = "Full-text search on title and tags")
            @RequestParam(required = false) String search,
            @Parameter(description = "Topic tag, e.g. `Linked List` or `Dynamic Programming`")
            @RequestParam(required = false) String tag) {
        return service.list(difficulty, status, search, tag);
    }

    @Operation(summary = "List all topic tags",
            description = "Returns a sorted list of all distinct topic tags across all problems.")
    @ApiResponse(responseCode = "200", description = "Sorted tag list")
    @GetMapping("/tags")
    public List<String> tags() {
        return service.allTags();
    }

    @Operation(summary = "Get problem detail",
            description = "Returns the full problem including description and starter code.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Problem found"),
            @ApiResponse(responseCode = "404", description = "No problem with that slug")
    })
    @GetMapping("/{slug}")
    public ResponseEntity<ProblemDetail> get(
            @Parameter(description = "Problem slug, e.g. `two-sum`")
            @PathVariable String slug) {
        return service.getBySlug(slug)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
