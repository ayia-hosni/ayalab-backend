package com.ayalab.dto;

import java.util.List;
import java.util.Map;
import java.util.Set;

public record AdminProblemRequest(
        Long               id,
        String             title,
        String             slug,
        double             acceptance,
        String             difficulty,
        Set<String>        tags,
        String             description,
        String             visualizerType,
        Map<String, String> starterCode,
        boolean            available,
        List<AdminTestCaseRequest> testCases
) {}
