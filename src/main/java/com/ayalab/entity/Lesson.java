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
import jakarta.persistence.ManyToOne;
import jakarta.persistence.MapKeyColumn;
import jakarta.persistence.Table;
import org.hibernate.annotations.BatchSize;

import java.util.HashMap;
import java.util.Map;

@Entity
@Table(name = "lessons")
public class Lesson {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Public URL identifier, e.g. "linked-list-basics". */
    @Column(nullable = false, unique = true)
    private String slug;

    /** Position among all lessons; determines display order. */
    @Column(nullable = false)
    private int ordinal;

    /** HTML entity or emoji shown next to the lesson title. */
    @Column(nullable = false)
    private String icon;

    @Column(nullable = false)
    private boolean published = true;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "section_id")
    private LessonSection section;

    /** Null means uncategorized within the section. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private LessonCategory category;

    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "lesson_i18n", joinColumns = @JoinColumn(name = "lesson_id"))
    @MapKeyColumn(name = "locale")
    @BatchSize(size = 50)
    private Map<String, LessonText> translations = new HashMap<>();

    public Long getId()                              { return id; }
    public String getSlug()                          { return slug; }
    public int getOrdinal()                          { return ordinal; }
    public String getIcon()                          { return icon; }
    public boolean isPublished()                     { return published; }
    public LessonSection getSection()                { return section; }
    public LessonCategory getCategory()              { return category; }
    public Map<String, LessonText> getTranslations() { return translations; }

    public void setSlug(String slug)                 { this.slug = slug; }
    public void setOrdinal(int ordinal)              { this.ordinal = ordinal; }
    public void setIcon(String icon)                 { this.icon = icon; }
    public void setPublished(boolean published)      { this.published = published; }
    public void setSection(LessonSection section)    { this.section = section; }
    public void setCategory(LessonCategory category) { this.category = category; }

    /** Replaces all translations in place (keeps the Hibernate-managed map instance). */
    public void replaceTranslations(Map<String, LessonText> next) {
        translations.clear();
        translations.putAll(next);
    }
}
