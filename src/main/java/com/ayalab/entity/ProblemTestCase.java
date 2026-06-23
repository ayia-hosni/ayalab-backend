package com.ayalab.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "problem_test_cases")
public class ProblemTestCase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "problem_id", nullable = false)
    private Long problemId;

    @Column(nullable = false)
    private short ordinal;

    @Column(name = "is_sample", nullable = false)
    private boolean sample;

    @Column(name = "input_json", nullable = false, columnDefinition = "text")
    private String inputJson;

    @Column(name = "output_json", nullable = false, columnDefinition = "text")
    private String outputJson;

    public ProblemTestCase() {}

    public ProblemTestCase(Long problemId, short ordinal, boolean sample, String inputJson, String outputJson) {
        this.problemId = problemId;
        this.ordinal   = ordinal;
        this.sample    = sample;
        this.inputJson = inputJson;
        this.outputJson = outputJson;
    }

    public Long getId()                  { return id; }
    public Long getProblemId()           { return problemId; }
    public short getOrdinal()            { return ordinal; }
    public boolean isSample()            { return sample; }
    public String getInputJson()         { return inputJson; }
    public String getOutputJson()        { return outputJson; }

    public void setProblemId(Long problemId)   { this.problemId = problemId; }
    public void setOrdinal(short ordinal)      { this.ordinal = ordinal; }
    public void setSample(boolean sample)      { this.sample = sample; }
    public void setInputJson(String inputJson) { this.inputJson = inputJson; }
    public void setOutputJson(String v)        { this.outputJson = v; }
}
