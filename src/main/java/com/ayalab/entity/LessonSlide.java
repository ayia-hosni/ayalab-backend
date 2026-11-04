package com.ayalab.entity;

import com.fasterxml.jackson.databind.JsonNode;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.MapKeyColumn;
import jakarta.persistence.Table;
import org.hibernate.annotations.BatchSize;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.util.HashMap;
import java.util.Map;

@Entity
@Table(name = "lesson_slides")
public class LessonSlide {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "lesson_id", nullable = false)
    private Long lessonId;

    /** Position within the lesson; determines slide order. */
    @Column(nullable = false)
    private int ordinal;

    /** Structured diagram description; discriminated by its {@code kind} field. */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    private JsonNode spec;

    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "lesson_slide_i18n", joinColumns = @JoinColumn(name = "slide_id"))
    @MapKeyColumn(name = "locale")
    @BatchSize(size = 100)
    private Map<String, SlideText> translations = new HashMap<>();

    protected LessonSlide() {}

    public LessonSlide(Long lessonId) {
        this.lessonId = lessonId;
    }

    public Long getId()                             { return id; }
    public Long getLessonId()                       { return lessonId; }
    public int getOrdinal()                         { return ordinal; }
    public JsonNode getSpec()                       { return spec; }
    public Map<String, SlideText> getTranslations() { return translations; }

    public void setOrdinal(int ordinal) { this.ordinal = ordinal; }
    public void setSpec(JsonNode spec)  { this.spec = spec; }

    public void replaceTranslations(Map<String, SlideText> next) {
        translations.clear();
        translations.putAll(next);
    }
}
