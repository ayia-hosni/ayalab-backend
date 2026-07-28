package com.ayalab.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

/**
 * The content driving one interactive visualizer tab for one problem. The {@link #config}
 * JSON is opaque to the backend — it's parsed and rendered entirely by the matching
 * frontend engine (chain-trace, pointer-drag, or recursion-tree).
 */
@Entity
@Table(name = "problem_game_configs")
public class ProblemGameConfig {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "problem_id", nullable = false)
    private Long problemId;

    @Enumerated(EnumType.STRING)
    @Column(name = "visualizer_kind", nullable = false)
    private VisualizerKind visualizerKind;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private String config;

    public ProblemGameConfig() {}

    public ProblemGameConfig(Long problemId, VisualizerKind visualizerKind, String config) {
        this.problemId = problemId;
        this.visualizerKind = visualizerKind;
        this.config = config;
    }

    public Long getId()                                     { return id; }
    public Long getProblemId()                               { return problemId; }
    public void setProblemId(Long problemId)                 { this.problemId = problemId; }
    public VisualizerKind getVisualizerKind()                { return visualizerKind; }
    public void setVisualizerKind(VisualizerKind kind)       { this.visualizerKind = kind; }
    public String getConfig()                                { return config; }
    public void setConfig(String config)                     { this.config = config; }
}
