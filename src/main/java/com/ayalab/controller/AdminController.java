package com.ayalab.controller;

import com.ayalab.dto.AdminProblemDetail;
import com.ayalab.dto.AdminProblemRequest;
import com.ayalab.entity.Difficulty;
import com.ayalab.entity.Problem;
import com.ayalab.entity.ProblemTestCase;
import com.ayalab.repository.ProblemRepository;
import com.ayalab.repository.ProblemTestCaseRepository;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;

@Tag(name = "Admin", description = "Problem catalogue management")
@RestController
@RequestMapping("/api/admin/problems")
public class AdminController {

    private final ProblemRepository problems;
    private final ProblemTestCaseRepository testCases;

    public AdminController(ProblemRepository problems, ProblemTestCaseRepository testCases) {
        this.problems  = problems;
        this.testCases = testCases;
    }

    @GetMapping
    @Transactional(readOnly = true)
    public List<AdminProblemDetail> list() {
        return problems.findAll().stream()
                .sorted((a, b) -> Long.compare(a.getId(), b.getId()))
                .map(p -> AdminProblemDetail.from(p, testCases.findByProblemIdOrderByOrdinal(p.getId())))
                .toList();
    }

    @GetMapping("/{id}")
    @Transactional(readOnly = true)
    public ResponseEntity<AdminProblemDetail> get(@PathVariable Long id) {
        return problems.findById(id)
                .map(p -> ResponseEntity.ok(AdminProblemDetail.from(p, testCases.findByProblemIdOrderByOrdinal(id))))
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    @Transactional
    public ResponseEntity<AdminProblemDetail> create(@RequestBody AdminProblemRequest req) {
        if (req.id() == null) return ResponseEntity.badRequest().build();
        if (problems.existsById(req.id())) return ResponseEntity.status(409).build();
        Problem p = applyRequest(new Problem(), req);
        problems.save(p);
        saveTestCases(p.getId(), req);
        return ResponseEntity.ok(AdminProblemDetail.from(p, testCases.findByProblemIdOrderByOrdinal(p.getId())));
    }

    @PutMapping("/{id}")
    @Transactional
    public ResponseEntity<AdminProblemDetail> update(@PathVariable Long id, @RequestBody AdminProblemRequest req) {
        return problems.findById(id).map(p -> {
            applyRequest(p, req);
            problems.save(p);
            // Replace test cases: delete existing, insert new.
            testCases.deleteAll(testCases.findByProblemIdOrderByOrdinal(id));
            saveTestCases(id, req);
            return ResponseEntity.ok(AdminProblemDetail.from(p, testCases.findByProblemIdOrderByOrdinal(id)));
        }).orElseGet(() -> ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    @Transactional
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        if (!problems.existsById(id)) return ResponseEntity.notFound().build();
        testCases.deleteAll(testCases.findByProblemIdOrderByOrdinal(id));
        problems.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    // ── helpers ───────────────────────────────────────────────────────────────

    private Problem applyRequest(Problem p, AdminProblemRequest req) {
        p.setId(req.id());
        p.setTitle(req.title());
        p.setSlug(req.slug());
        p.setAcceptance(req.acceptance());
        p.setDifficulty(Difficulty.valueOf(req.difficulty().toUpperCase()));
        p.setTags(req.tags() != null ? new LinkedHashSet<>(req.tags()) : new LinkedHashSet<>());
        p.setDescription(req.description());
        p.setVisualizerType(req.visualizerType() != null && !req.visualizerType().isBlank() ? req.visualizerType() : null);
        p.setStarterCode(req.starterCode() != null ? new LinkedHashMap<>(req.starterCode()) : new LinkedHashMap<>());
        p.setAvailable(req.available());
        return p;
    }

    private void saveTestCases(Long problemId, AdminProblemRequest req) {
        if (req.testCases() == null) return;
        List<ProblemTestCase> toSave = req.testCases().stream()
                .map(tc -> new ProblemTestCase(problemId, tc.ordinal(), tc.sample(), tc.inputJson(), tc.outputJson()))
                .toList();
        testCases.saveAll(toSave);
    }
}
