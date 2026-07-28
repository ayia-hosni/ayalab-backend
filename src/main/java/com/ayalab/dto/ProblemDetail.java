package com.ayalab.dto;

import com.ayalab.entity.Problem;
import io.swagger.v3.oas.annotations.media.Schema;

import java.util.List;
import java.util.Map;

@Schema(description = "Full problem payload including description and starter code")
public record ProblemDetail(
        @Schema(description = "Unique problem ID") Long id,
        @Schema(description = "Problem title", example = "Two Sum") String title,
        @Schema(description = "URL-friendly identifier", example = "two-sum") String slug,
        @Schema(description = "Acceptance rate (0–100)", example = "78.4") double acceptance,
        @Schema(description = "Difficulty level", allowableValues = {"easy", "medium", "hard"}) String difficulty,
        @Schema(description = "Solve status", allowableValues = {"todo", "attempted", "solved"}) String status,
        @Schema(description = "Topic tags", example = "[\"Array\", \"Hash Table\"]") List<String> tags,
        @Schema(description = "Whether a step-by-step visualizer is available") boolean hasVisualizer,
        @Schema(description = "Full problem description in Markdown") String description,
        @Schema(description = "Arabic translation of the description; null when not yet translated") String descriptionAr,
        @Schema(description = "Starter code per language, e.g. {\"javascript\":\"…\"}") Map<String, String> starterCode,
        @Schema(description = "Interactive game content per visualizer tab, e.g. {\"traceGame\":\"{...}\"}. " +
                "Values are raw JSON strings owned by the frontend engines; empty when the problem has no games.")
        Map<String, String> gameConfigs
) {
    public static ProblemDetail from(Problem p, Map<String, String> gameConfigs) {
        return new ProblemDetail(
                p.getId(),
                p.getTitle(),
                p.getSlug(),
                p.getAcceptance(),
                p.getDifficulty().name().toLowerCase(),
                p.getStatus().name().toLowerCase(),
                List.copyOf(p.getTags()),
                p.getVisualizerType() != null,
                p.getDescription(),
                p.getDescriptionAr(),
                Map.copyOf(p.getStarterCode()),
                gameConfigs
        );
    }
}
