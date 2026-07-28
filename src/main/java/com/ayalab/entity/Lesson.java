package com.ayalab.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "lessons")
public class Lesson {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /** Position among all lessons; determines display order. */
    @Column(nullable = false)
    private int ordinal;

    /** HTML entity or emoji shown next to the lesson title. */
    @Column(nullable = false)
    private String icon;

    @Column(name = "title_en", nullable = false, columnDefinition = "text")
    private String titleEn;

    @Column(name = "title_ar", nullable = false, columnDefinition = "text")
    private String titleAr;

    @Column(name = "description_en", nullable = false, columnDefinition = "text")
    private String descriptionEn;

    @Column(name = "description_ar", nullable = false, columnDefinition = "text")
    private String descriptionAr;

    /** Topic group, e.g. "Linked Lists" — every lesson belongs to one. */
    @Column(name = "section_en", nullable = false, columnDefinition = "text")
    private String sectionEn;

    @Column(name = "section_ar", nullable = false, columnDefinition = "text")
    private String sectionAr;

    /** Optional sub-tag within the section, e.g. "Insertion"; null means uncategorized. */
    @Column(name = "category_en", columnDefinition = "text")
    private String categoryEn;

    @Column(name = "category_ar", columnDefinition = "text")
    private String categoryAr;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public int getOrdinal() { return ordinal; }
    public void setOrdinal(int ordinal) { this.ordinal = ordinal; }

    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }

    public String getTitleEn() { return titleEn; }
    public void setTitleEn(String titleEn) { this.titleEn = titleEn; }

    public String getTitleAr() { return titleAr; }
    public void setTitleAr(String titleAr) { this.titleAr = titleAr; }

    public String getDescriptionEn() { return descriptionEn; }
    public void setDescriptionEn(String descriptionEn) { this.descriptionEn = descriptionEn; }

    public String getDescriptionAr() { return descriptionAr; }
    public void setDescriptionAr(String descriptionAr) { this.descriptionAr = descriptionAr; }

    public String getSectionEn() { return sectionEn; }
    public void setSectionEn(String sectionEn) { this.sectionEn = sectionEn; }

    public String getSectionAr() { return sectionAr; }
    public void setSectionAr(String sectionAr) { this.sectionAr = sectionAr; }

    public String getCategoryEn() { return categoryEn; }
    public void setCategoryEn(String categoryEn) { this.categoryEn = categoryEn; }

    public String getCategoryAr() { return categoryAr; }
    public void setCategoryAr(String categoryAr) { this.categoryAr = categoryAr; }
}
