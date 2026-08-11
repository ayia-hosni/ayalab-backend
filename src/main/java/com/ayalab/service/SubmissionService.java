package com.ayalab.service;

import com.ayalab.dto.SubmitRequest;
import com.ayalab.dto.SubmitResult;
import com.ayalab.entity.Problem;
import com.ayalab.entity.ProblemStatus;
import com.ayalab.entity.ProblemTestCase;
import com.ayalab.judge.JavaJudge;
import com.ayalab.judge.JavaScriptJudge;
import com.ayalab.judge.TestCase;
import com.ayalab.repository.ProblemRepository;
import com.ayalab.repository.ProblemTestCaseRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SubmissionService {

    private final JavaScriptJudge jsJudge;
    private final JavaJudge javaJudge;
    private final ProblemRepository problemRepository;
    private final ProblemTestCaseRepository testCaseRepository;
    private final ProblemService problemService;
    private final ObjectMapper objectMapper;

    public SubmissionService(JavaScriptJudge jsJudge,
                             JavaJudge javaJudge,
                             ProblemRepository problemRepository,
                             ProblemTestCaseRepository testCaseRepository,
                             ProblemService problemService,
                             ObjectMapper objectMapper) {
        this.jsJudge = jsJudge;
        this.javaJudge = javaJudge;
        this.problemRepository = problemRepository;
        this.testCaseRepository = testCaseRepository;
        this.problemService = problemService;
        this.objectMapper = objectMapper;
    }

    public SubmitResult submit(String slug, SubmitRequest request) {
        Problem problem = problemRepository.findBySlug(slug)
                .orElseThrow(() -> new IllegalArgumentException("Unknown problem: " + slug));

        boolean isJs = "javascript".equalsIgnoreCase(request.language());
        boolean isJava = "java".equalsIgnoreCase(request.language());
        if (!isJs && !isJava) {
            return new SubmitResult(false, "Unsupported Language",
                    "Server-side execution currently supports JavaScript and Java. "
                            + "Python solutions are provided as reference.",
                    0, List.of());
        }

        List<ProblemTestCase> rawCases = testCaseRepository.findByProblemIdOrderByOrdinal(problem.getId());
        // "Run" executes only sample cases (those shown in examples); "Submit" runs all.
        List<TestCase> cases = (request.submit()
                ? rawCases
                : rawCases.stream().filter(ProblemTestCase::isSample).toList())
                .stream()
                .map(this::toTestCase)
                .toList();

        SubmitResult result = isJava ? javaJudge.run(request.code(), cases) : jsJudge.run(request.code(), cases);

        if (result.accepted() && request.submit()) {
            problemService.updateStatus(problem.getId(), ProblemStatus.SOLVED);
        } else if (result.compileError() == null) {
            problemService.updateStatus(problem.getId(), ProblemStatus.ATTEMPTED);
        }

        return result;
    }

    private TestCase toTestCase(ProblemTestCase tc) {
        try {
            List<Integer> input  = objectMapper.readValue(tc.getInputJson(),  new TypeReference<>() {});
            List<Integer> output = objectMapper.readValue(tc.getOutputJson(), new TypeReference<>() {});
            return new TestCase(input, output);
        } catch (Exception e) {
            throw new IllegalStateException("Malformed test-case JSON for case id=" + tc.getId(), e);
        }
    }
}