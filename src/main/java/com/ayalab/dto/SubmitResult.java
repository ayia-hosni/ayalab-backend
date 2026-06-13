package com.ayalab.dto;

import java.util.List;

/** Result of running a submission against the test cases. */
public record SubmitResult(
        boolean accepted,
        String verdict,
        String compileError,
        long runtimeMs,
        List<CaseResult> cases
) {
    /** Outcome for a single test case. */
    public record CaseResult(
            boolean passed,
            List<Integer> input,
            List<Integer> expected,
            List<Integer> actual,
            String error
    ) {
    }
}
