package com.ayalab.entity;

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

import java.util.HashMap;
import java.util.Map;

/** Optional sub-tag within a section, e.g. "Insertion". */
@Entity
@Table(name = "lesson_categories")
public class LessonCategory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "section_id", nullable = false)
    private Long sectionId;

    @Column(nullable = false)
    private String slug;

    @Column(nullable = false)
    private int ordinal;

    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "lesson_category_i18n", joinColumns = @JoinColumn(name = "category_id"))
    @MapKeyColumn(name = "locale")
    @Column(name = "name", nullable = false)
    @BatchSize(size = 50)
    private Map<String, String> names = new HashMap<>();

    protected LessonCategory() {}

    public LessonCategory(Long sectionId, String slug, int ordinal, Map<String, String> names) {
        this.sectionId = sectionId;
        this.slug = slug;
        this.ordinal = ordinal;
        this.names = new HashMap<>(names);
    }

    public Long getId()                  { return id; }
    public Long getSectionId()           { return sectionId; }
    public String getSlug()              { return slug; }
    public int getOrdinal()              { return ordinal; }
    public Map<String, String> getNames() { return names; }
}
