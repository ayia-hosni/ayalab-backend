package com.ayalab.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Schema(description = "Result of running a submission against test cases")
public record SubmitResult(
        @Schema(description = "Whether all test cases passed")
        boolean accepted,

        @Schema(description = "Overall verdict", allowableValues = {"ACCEPTED", "WRONG_ANSWER", "RUNTIME_ERROR", "COMPILE_ERROR"})
        String verdict,

        @Schema(description = "Compile error message, null if code compiled successfully")
        String compileError,

        @Schema(description = "Total execution time across all test cases in milliseconds")
        long runtimeMs,

        @Schema(description = "Per-test-case results")
        List<CaseResult> cases
) {
    @Schema(description = "Outcome for a single test case")
    public record CaseResult(
            @Schema(description = "Whether this test case passed")
            boolean passed,

            @Schema(description = "Input values for this test case")
            List<Integer> input,

            @Schema(description = "Expected output")
            List<Integer> expected,

            @Schema(description = "Actual output produced by the submission")
            List<Integer> actual,

            @Schema(description = "Runtime error message for this case, null if none")
            String error
    ) {
    }
}
