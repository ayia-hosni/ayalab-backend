package com.ayalab.dto;

import com.ayalab.entity.Problem;

import com.ayalab.entity.ProblemGameConfig;
import com.ayalab.entity.ProblemTestCase;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public record AdminProblemDetail(
        Long                       id,
        String                     title,
        String                     slug,
        double                     acceptance,
        String                     difficulty,
        String                     status,
        List<String>               tags,
        boolean                    available,
        String                     visualizerType,
        String                     description,
        Map<String, String>        starterCode,
        List<AdminTestCaseRequest> testCases,
        Map<String, String>        gameConfigs
) {
    public static AdminProblemDetail from(Problem p, List<ProblemTestCase> cases, List<ProblemGameConfig> configs) {
        return new AdminProblemDetail(
                p.getId(),
                p.getTitle(),
                p.getSlug(),
                p.getAcceptance(),
                p.getDifficulty().name().toLowerCase(),
                p.getStatus().name().toLowerCase(),
                List.copyOf(p.getTags()),
                p.isAvailable(),
                p.getVisualizerType(),
                p.getDescription(),
                Map.copyOf(p.getStarterCode()),
                cases.stream()
                     .map(c -> new AdminTestCaseRequest(c.getId(), c.getOrdinal(), c.isSample(), c.getInputJson(), c.getOutputJson()))
                     .toList(),
                configs.stream()
                       .collect(Collectors.toMap(c -> c.getVisualizerKind().jsonKey(), ProblemGameConfig::getConfig))
        );
    }
}
