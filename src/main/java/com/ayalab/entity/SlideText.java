package com.ayalab.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;

/** Translatable slide fields for one locale. {@code body} is sanitized rich text. */
@Embeddable
public class SlideText {

    @Column(nullable = false, columnDefinition = "text")
    private String kicker;

    @Column(nullable = false, columnDefinition = "text")
    private String title;

    @Column(nullable = false, columnDefinition = "text")
    private String body;

    protected SlideText() {}

    public SlideText(String kicker, String title, String body) {
        this.kicker = kicker;
        this.title = title;
        this.body = body;
    }

    public String getKicker() { return kicker; }
    public String getTitle()  { return title; }
    public String getBody()   { return body; }
}
