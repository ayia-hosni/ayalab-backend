package com.ayalab.service;

import com.ayalab.dto.ProblemDetail;
import com.ayalab.dto.ProblemSummary;
import com.ayalab.entity.Difficulty;
import com.ayalab.entity.Problem;
import com.ayalab.entity.ProblemStatus;
import com.ayalab.repository.ProblemRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ProblemService {

    private final ProblemRepository repository;

    public ProblemService(ProblemRepository repository) {
        this.repository = repository;
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

    public Optional<ProblemDetail> getBySlug(String slug) {
        return repository.findBySlug(slug).map(ProblemDetail::from);
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
