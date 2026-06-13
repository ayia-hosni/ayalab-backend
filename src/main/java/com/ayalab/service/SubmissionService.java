package com.ayalab.service;

import com.ayalab.dto.SubmitRequest;
import com.ayalab.dto.SubmitResult;
import com.ayalab.entity.Problem;
import com.ayalab.entity.ProblemStatus;
import com.ayalab.judge.JavaScriptJudge;
import com.ayalab.judge.TestCase;
import com.ayalab.repository.ProblemRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SubmissionService {

    private final JavaScriptJudge judge;
    private final ProblemRepository problemRepository;
    private final ProblemService problemService;

    public SubmissionService(JavaScriptJudge judge,
                             ProblemRepository problemRepository,
                             ProblemService problemService) {
        this.judge = judge;
        this.problemRepository = problemRepository;
        this.problemService = problemService;
    }

    /** Hidden test cases for Reverse Linked List (problem 206). */
    private static final List<TestCase> REVERSE_LINKED_LIST_TESTS = List.of(
            new TestCase(List.of(1, 2, 3, 4, 5), List.of(5, 4, 3, 2, 1)),
            new TestCase(List.of(1, 2), List.of(2, 1)),
            new TestCase(List.of(), List.of()),
            new TestCase(List.of(7), List.of(7)),
            new TestCase(List.of(-3, 0, 9, -1), List.of(-1, 9, 0, -3))
    );

    public SubmitResult submit(String slug, SubmitRequest request) {
        Problem problem = problemRepository.findBySlug(slug)
                .orElseThrow(() -> new IllegalArgumentException("Unknown problem: " + slug));

        if (!"javascript".equalsIgnoreCase(request.language())) {
            return new SubmitResult(false, "Unsupported Language",
                    "Server-side execution currently supports JavaScript only. "
                            + "Python and Java solutions are provided as reference.",
                    0, List.of());
        }

        List<TestCase> all = testsFor(slug);
        // "Run" uses the first 3 sample cases; "Submit" runs everything.
        List<TestCase> cases = request.submit() ? all : all.subList(0, Math.min(3, all.size()));

        SubmitResult result = judge.run(request.code(), cases);

        // Update solve status based on the outcome.
        if (result.accepted() && request.submit()) {
            problemService.updateStatus(problem.getId(), ProblemStatus.SOLVED);
        } else if (result.compileError() == null) {
            problemService.updateStatus(problem.getId(), ProblemStatus.ATTEMPTED);
        }

        return result;
    }

    private List<TestCase> testsFor(String slug) {
        // A real system would load these from the DB per problem; we ship the
        // Reverse Linked List set since that is the fully playable problem.
        return REVERSE_LINKED_LIST_TESTS;
    }
}
