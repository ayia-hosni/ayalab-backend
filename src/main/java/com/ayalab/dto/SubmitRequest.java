package com.ayalab.dto;

import jakarta.validation.constraints.NotBlank;

/** A code submission for a given problem. Currently only JavaScript is executed. */
public record SubmitRequest(
        @NotBlank String language,
        @NotBlank String code,
        /** When true, all hidden test cases run; otherwise only the sample subset. */
        boolean submit
) {
}
