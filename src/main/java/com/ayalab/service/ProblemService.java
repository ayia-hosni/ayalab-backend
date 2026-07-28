package com.ayalab.service;

import com.ayalab.dto.ProblemDetail;
import com.ayalab.dto.ProblemSummary;
import com.ayalab.entity.Difficulty;
import com.ayalab.entity.Problem;
import com.ayalab.entity.ProblemGameConfig;
import com.ayalab.entity.ProblemStatus;
import com.ayalab.repository.ProblemGameConfigRepository;
import com.ayalab.repository.ProblemRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class ProblemService {

    private final ProblemRepository repository;
    private final ProblemGameConfigRepository gameConfigs;

    public ProblemService(ProblemRepository repository, ProblemGameConfigRepository gameConfigs) {
        this.repository = repository;
        this.gameConfigs = gameConfigs;
    }

    public List<ProblemSummary> list(String difficulty, String status, String search, String tag) {
        Difficulty diff = parseEnum(Difficulty.class, difficulty);
        ProblemStatus st = parseEnum(ProblemStatus.class, status);
        String s = (search == null || search.isBlank()) ? null : search.trim().toLowerCase();
        String t = (tag == null || tag.isBlank()) ? null : tag.trim().toLowerCase();
        return repository.search(diff, st, s, t).stream()
                .map(ProblemSummary::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public Optional<ProblemDetail> getBySlug(String slug) {
        return repository.findBySlug(slug).map(p -> ProblemDetail.from(p, gameConfigsFor(p.getId())));
    }

    private Map<String, String> gameConfigsFor(Long problemId) {
        Map<String, String> byKey = new LinkedHashMap<>();
        for (ProblemGameConfig cfg : gameConfigs.findByProblemId(problemId)) {
            byKey.put(cfg.getVisualizerKind().jsonKey(), cfg.getConfig());
        }
        return byKey;
    }

    public List<String> allTags() {
        return repository.findAll().stream()
                .flatMap(p -> p.getTags().stream())
                .distinct()
                .sorted()
                .toList();
    }

    /** Marks a problem solved/attempted; ignored if the problem does not exist. */
    public void updateStatus(Long id, ProblemStatus status) {
        repository.findById(id).ifPresent(p -> {
            // Never downgrade SOLVED back to ATTEMPTED.
            if (p.getStatus() == ProblemStatus.SOLVED && status == ProblemStatus.ATTEMPTED) {
                return;
            }
            p.setStatus(status);
            repository.save(p);
        });
    }

    private <E extends Enum<E>> E parseEnum(Class<E> type, String value) {
        if (value == null || value.isBlank() || value.equalsIgnoreCase("all")) {
            return null;
        }
        try {
            return Enum.valueOf(type, value.trim().toUpperCase());
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }
}
