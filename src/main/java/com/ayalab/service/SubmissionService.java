package com.ayalab.service;

import com.ayalab.dto.SubmitRequest;
import com.ayalab.dto.SubmitResult;
import com.ayalab.entity.Problem;
import com.ayalab.entity.ProblemStatus;
import com.ayalab.entity.ProblemTestCase;
import com.ayalab.judge.JavaJudge;
import com.ayalab.judge.JavaScriptJudge;
import com.ayalab.judge.JudgeSpec;
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

        JudgeSpec spec = judgeSpecFor(problem);
        if (spec == null) {
            // Not an error in the user's code, so report it plainly and leave the problem's status alone.
            return new SubmitResult(false, "Judge Unavailable",
                    "Running code isn't available for this problem yet.", 0, List.of());
        }

        List<ProblemTestCase> rawCases = testCaseRepository.findByProblemIdOrderByOrdinal(problem.getId());
        // "Run" executes only sample cases (those shown in examples); "Submit" runs all.
        List<TestCase> cases = (request.submit()
                ? rawCases
                : rawCases.stream().filter(ProblemTestCase::isSample).toList())
                .stream()
                .map(tc -> toTestCase(tc, spec))
                .toList();
        if (cases.isEmpty()) {
            // An empty run would otherwise pass vacuously.
            return new SubmitResult(false, "No Test Cases",
                    "This problem has no test cases to run yet.", 0, List.of());
        }

        SubmitResult result = isJava ? javaJudge.run(request.code(), spec, cases) : jsJudge.run(request.code(), spec, cases);

        if (result.accepted() && request.submit()) {
            problemService.updateStatus(problem.getId(), ProblemStatus.SOLVED);
        } else if (result.compileError() == null) {
            problemService.updateStatus(problem.getId(), ProblemStatus.ATTEMPTED);
        }

        return result;
    }

    private JudgeSpec judgeSpecFor(Problem problem) {
        if (problem.getJudgeMethod() == null || problem.getJudgeArgsKind() == null || problem.getJudgeResultKind() == null) {
            return null;
        }
        return new JudgeSpec(problem.getJudgeMethod(),
                JudgeSpec.ArgsKind.valueOf(problem.getJudgeArgsKind()),
                JudgeSpec.ResultKind.valueOf(problem.getJudgeResultKind()));
    }

    private TestCase toTestCase(ProblemTestCase tc, JudgeSpec spec) {
        try {
            Object input = switch (spec.args()) {
                case LIST -> objectMapper.readValue(tc.getInputJson(), new TypeReference<List<Integer>>() {});
                case LIST_AND_INT -> objectMapper.readValue(tc.getInputJson(), new TypeReference<List<Object>>() {});
                case INT -> objectMapper.readValue(tc.getInputJson(), Integer.class);
            };
            Object output = switch (spec.result()) {
                case LIST -> objectMapper.readValue(tc.getOutputJson(), new TypeReference<List<Integer>>() {});
                case BOOLEAN -> objectMapper.readValue(tc.getOutputJson(), Boolean.class);
                case INT -> objectMapper.readValue(tc.getOutputJson(), Integer.class);
            };
            return new TestCase(input, output);
        } catch (Exception e) {
            throw new IllegalStateException("Malformed test-case JSON for case id=" + tc.getId(), e);
        }
    }
}
