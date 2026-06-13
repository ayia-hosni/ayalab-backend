package com.ayalab.dto;

import com.ayalab.entity.Problem;

import java.util.List;

/** Lightweight projection used in the problem list (no heavy description field). */
public record ProblemSummary(
        Long id,
        String title,
        String slug,
        double acceptance,
        String difficulty,
        String status,
        List<String> tags,
        boolean hasVisualizer
) {
    public static ProblemSummary from(Problem p) {
        return new ProblemSummary(
                p.getId(),
                p.getTitle(),
                p.getSlug(),
                p.getAcceptance(),
                p.getDifficulty().name().toLowerCase(),
                p.getStatus().name().toLowerCase(),
                List.copyOf(p.getTags()),
                p.isHasVisualizer()
        );
    }
}
