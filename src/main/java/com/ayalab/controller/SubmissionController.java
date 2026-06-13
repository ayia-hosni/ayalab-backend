package com.ayalab.controller;

import com.ayalab.dto.SubmitRequest;
import com.ayalab.dto.SubmitResult;
import com.ayalab.service.SubmissionService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/problems")
public class SubmissionController {

    private final SubmissionService service;

    public SubmissionController(SubmissionService service) {
        this.service = service;
    }

    /** POST /api/problems/{slug}/submit -> runs the code against the test cases. */
    @PostMapping("/{slug}/submit")
    public SubmitResult submit(@PathVariable String slug,
                               @Valid @RequestBody SubmitRequest request) {
        return service.submit(slug, request);
    }
}
