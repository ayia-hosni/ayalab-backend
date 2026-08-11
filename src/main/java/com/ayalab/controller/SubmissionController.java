package com.ayalab.controller;

import com.ayalab.dto.SubmitRequest;
import com.ayalab.dto.SubmitResult;
import com.ayalab.service.SubmissionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Submissions", description = "Submit and evaluate JavaScript solutions")
@RestController
@RequestMapping("/api/problems")
public class SubmissionController {

    private final SubmissionService service;

    public SubmissionController(SubmissionService service) {
        this.service = service;
    }

    @Operation(summary = "Submit a solution",
            description = "Runs JavaScript code against test cases inside a sandboxed GraalVM engine. " +
                    "Set `submit: true` to run all hidden cases; `false` runs only the sample subset.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Submission evaluated — check `accepted` and `cases` for results"),
            @ApiResponse(responseCode = "400", description = "Request body is invalid"),
            @ApiResponse(responseCode = "404", description = "No problem with that slug")
    })
    @PostMapping("/{slug}/submit")
    public SubmitResult submit(
            @Parameter(description = "Problem slug, e.g. `two-sum`")
            @PathVariable String slug,
            @RequestBody @Valid SubmitRequest request) {
        return service.submit(slug, request);
    }
}
