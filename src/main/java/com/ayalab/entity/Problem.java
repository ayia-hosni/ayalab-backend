package com.ayalab.entity;

import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Table;

import java.util.LinkedHashSet;
import java.util.Set;

@Entity
@Table(name = "problems")
public class Problem {

    /** LeetCode-style problem number, used as the primary key. */
    @Id
    private Long id;

    @Column(nullable = false)
    private String title;

    /** URL-friendly identifier, e.g. "reverse-linked-list". */
    @Column(nullable = false, unique = true)
    private String slug;

    @Column(nullable = false)
    private double acceptance;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Difficulty difficulty;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ProblemStatus status = ProblemStatus.TODO;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "problem_tags", joinColumns = @JoinColumn(name = "problem_id"))
    @Column(name = "tag")
    private Set<String> tags = new LinkedHashSet<>();

    /** Full markdown/HTML problem statement (only loaded for the detail view). */
    @Column(columnDefinition = "text")
    private String description;

    /** Whether this problem supports the in-browser pointer-trace visualizer. */
    @Column(nullable = false)
    private boolean hasVisualizer = false;

    /** Starter code keyed by language (javascript/python/java), stored as JSON text. */
    @Column(columnDefinition = "text")
    private String starterCode;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public double getAcceptance() { return acceptance; }
    public void setAcceptance(double acceptance) { this.acceptance = acceptance; }

    public Difficulty getDifficulty() { return difficulty; }
    public void setDifficulty(Difficulty difficulty) { this.difficulty = difficulty; }

    public ProblemStatus getStatus() { return status; }
    public void setStatus(ProblemStatus status) { this.status = status; }

    public Set<String> getTags() { return tags; }
    public void setTags(Set<String> tags) { this.tags = tags; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public boolean isHasVisualizer() { return hasVisualizer; }
    public void setHasVisualizer(boolean hasVisualizer) { this.hasVisualizer = hasVisualizer; }

    public String getStarterCode() { return starterCode; }
    public void setStarterCode(String starterCode) { this.starterCode = starterCode; }
}
