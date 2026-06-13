package com.ayalab.dto;

import com.ayalab.entity.Problem;

import java.util.List;

/** Full problem payload for the detail page. */
public record ProblemDetail(
        Long id,
        String title,
        String slug,
        double acceptance,
        String difficulty,
        String status,
        List<String> tags,
        boolean hasVisualizer,
        String description,
        String starterCode
) {
    public static ProblemDetail from(Problem p) {
        return new ProblemDetail(
                p.getId(),
                p.getTitle(),
                p.getSlug(),
                p.getAcceptance(),
                p.getDifficulty().name().toLowerCase(),
                p.getStatus().name().toLowerCase(),
                List.copyOf(p.getTags()),
                p.isHasVisualizer(),
                p.getDescription(),
                p.getStarterCode()
        );
    }
}
