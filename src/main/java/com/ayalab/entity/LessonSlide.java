package com.ayalab.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

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

    @Column(name = "kicker_en", nullable = false, columnDefinition = "text")
    private String kickerEn;

    @Column(name = "kicker_ar", nullable = false, columnDefinition = "text")
    private String kickerAr;

    @Column(name = "title_en", nullable = false, columnDefinition = "text")
    private String titleEn;

    @Column(name = "title_ar", nullable = false, columnDefinition = "text")
    private String titleAr;

    /** Raw HTML for the slide's diagram/illustration. */
    @Column(nullable = false, columnDefinition = "text")
    private String visual;

    /** Structured builder spec (JSON) that generated `visual`; null for slides authored as raw HTML. */
    @Column(name = "visual_spec", columnDefinition = "text")
    private String visualSpec;

    @Column(name = "body_en", nullable = false, columnDefinition = "text")
    private String bodyEn;

    @Column(name = "body_ar", nullable = false, columnDefinition = "text")
    private String bodyAr;

    public LessonSlide() {}

    public LessonSlide(Long lessonId, int ordinal, String kickerEn, String kickerAr,
                        String titleEn, String titleAr, String visual, String visualSpec, String bodyEn, String bodyAr) {
        this.lessonId   = lessonId;
        this.ordinal    = ordinal;
        this.kickerEn   = kickerEn;
        this.kickerAr   = kickerAr;
        this.titleEn    = titleEn;
        this.titleAr    = titleAr;
        this.visual     = visual;
        this.visualSpec = visualSpec;
        this.bodyEn     = bodyEn;
        this.bodyAr     = bodyAr;
    }

    public Long getId()            { return id; }
    public Long getLessonId()      { return lessonId; }
    public int getOrdinal()        { return ordinal; }
    public String getKickerEn()    { return kickerEn; }
    public String getKickerAr()    { return kickerAr; }
    public String getTitleEn()     { return titleEn; }
    public String getTitleAr()     { return titleAr; }
    public String getVisual()      { return visual; }
    public String getVisualSpec()  { return visualSpec; }
    public String getBodyEn()      { return bodyEn; }
    public String getBodyAr()      { return bodyAr; }

    public void setLessonId(Long lessonId)     { this.lessonId = lessonId; }
    public void setOrdinal(int ordinal)        { this.ordinal = ordinal; }
    public void setKickerEn(String kickerEn)   { this.kickerEn = kickerEn; }
    public void setKickerAr(String kickerAr)   { this.kickerAr = kickerAr; }
    public void setTitleEn(String titleEn)     { this.titleEn = titleEn; }
    public void setTitleAr(String titleAr)     { this.titleAr = titleAr; }
    public void setVisual(String visual)       { this.visual = visual; }
    public void setVisualSpec(String v)        { this.visualSpec = v; }
    public void setBodyEn(String bodyEn)       { this.bodyEn = bodyEn; }
    public void setBodyAr(String bodyAr)       { this.bodyAr = bodyAr; }
}
