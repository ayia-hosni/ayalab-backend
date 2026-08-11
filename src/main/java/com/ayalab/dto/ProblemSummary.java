package com.ayalab.dto;

import com.ayalab.entity.Problem;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;

@Schema(description = "Lightweight problem projection used in the list view")
public record ProblemSummary(
        @Schema(description = "Unique problem ID") Long id,
        @Schema(description = "Problem title", example = "Two Sum") String title,
        @Schema(description = "URL-friendly identifier", example = "two-sum") String slug,
        @Schema(description = "Acceptance rate (0–100)", example = "78.4") double acceptance,
        @Schema(description = "Difficulty level", allowableValues = {"easy", "medium", "hard"}) String difficulty,
        @Schema(description = "Solve status", allowableValues = {"todo", "attempted", "solved"}) String status,
        @Schema(description = "Topic tags", example = "[\"Array\", \"Hash Table\"]") List<String> tags,
        @Schema(description = "Whether a step-by-step visualizer is available") boolean hasVisualizer,
        @Schema(description = "Whether this problem is fully implemented; false means Coming Soon") boolean available
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
                p.getVisualizerType() != null,
                p.isAvailable()
        );
    }
}
