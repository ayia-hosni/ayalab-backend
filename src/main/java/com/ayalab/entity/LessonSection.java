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

/** Topic group a lesson belongs to, e.g. "Linked Lists". */
@Entity
@Table(name = "lesson_sections")
public class LessonSection {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String slug;

    @Column(nullable = false)
    private int ordinal;

    /** Display name per locale. */
    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "lesson_section_i18n", joinColumns = @JoinColumn(name = "section_id"))
    @MapKeyColumn(name = "locale")
    @Column(name = "name", nullable = false)
    @BatchSize(size = 50)
    private Map<String, String> names = new HashMap<>();

    protected LessonSection() {}

    public LessonSection(String slug, int ordinal, Map<String, String> names) {
        this.slug = slug;
        this.ordinal = ordinal;
        this.names = new HashMap<>(names);
    }

    public Long getId()                  { return id; }
    public String getSlug()              { return slug; }
    public int getOrdinal()              { return ordinal; }
    public Map<String, String> getNames() { return names; }
}
