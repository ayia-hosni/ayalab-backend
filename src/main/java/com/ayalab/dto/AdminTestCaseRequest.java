package com.ayalab.dto;

public record AdminTestCaseRequest(
        Long   id,
        short  ordinal,
        boolean sample,
        String inputJson,
        String outputJson
) {}
