package com.ayalab.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

/** Translatable lesson fields for one locale. */
@Embeddable
public class LessonText {

    @Column(nullable = false, columnDefinition = "text")
    private String title;

    @Column(nullable = false, columnDefinition = "text")
    private String description;

    protected LessonText() {}

    public LessonText(String title, String description) {
        this.title = title;
        this.description = description;
    }

    public String getTitle()       { return title; }
    public String getDescription() { return description; }
}
