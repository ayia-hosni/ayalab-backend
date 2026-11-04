package com.ayalab.service;

import com.ayalab.dto.AdminLessonDto;
import com.ayalab.dto.AdminLessonRequest.LessonTextDto;
import com.ayalab.dto.AdminSlideRequest.SlideTextDto;
import com.ayalab.dto.LessonDetail;
import com.ayalab.dto.LessonSummary;
import com.ayalab.dto.SlideDto;
import com.ayalab.dto.TaxonomyRef;
import com.ayalab.entity.Lesson;
import com.ayalab.entity.LessonCategory;
import com.ayalab.entity.LessonSection;
import com.ayalab.entity.LessonSlide;
import com.ayalab.entity.LessonText;
import com.ayalab.entity.SlideText;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Entity -> DTO conversion; reader DTOs are flattened to a single locale with English fallback. */
@Component
public class LessonMapper {

    public LessonSummary toSummary(Lesson l, String locale, int slideCount) {
        LessonText t = Locales.pick(l.getTranslations(), locale);
        return new LessonSummary(l.getId(), l.getSlug(), l.getOrdinal(), l.getIcon(),
                t.getTitle(), t.getDescription(),
                sectionRef(l.getSection(), locale), categoryRef(l.getCategory(), locale), slideCount);
    }

    public LessonDetail toDetail(Lesson l, String locale, List<LessonSlide> slides) {
        LessonText t = Locales.pick(l.getTranslations(), locale);
        return new LessonDetail(l.getId(), l.getSlug(), l.getOrdinal(), l.getIcon(),
                t.getTitle(), t.getDescription(),
                sectionRef(l.getSection(), locale), categoryRef(l.getCategory(), locale),
                slides.stream().map(s -> toSlide(s, locale)).toList());
    }

    public SlideDto toSlide(LessonSlide s, String locale) {
        SlideText t = Locales.pick(s.getTranslations(), locale);
        return new SlideDto(s.getId(), s.getOrdinal(), t.getKicker(), t.getTitle(), t.getBody(), s.getSpec());
    }

    public AdminLessonDto toAdmin(Lesson l, List<LessonSlide> slides) {
        Map<String, LessonTextDto> translations = new LinkedHashMap<>();
        l.getTranslations().forEach((loc, t) -> translations.put(loc, new LessonTextDto(t.getTitle(), t.getDescription())));
        List<AdminLessonDto.AdminSlideDto> slideDtos = slides.stream().map(s -> {
            Map<String, SlideTextDto> st = new LinkedHashMap<>();
            s.getTranslations().forEach((loc, t) -> st.put(loc, new SlideTextDto(t.getKicker(), t.getTitle(), t.getBody())));
            return new AdminLessonDto.AdminSlideDto(s.getId(), s.getOrdinal(), s.getSpec(), st);
        }).toList();
        return new AdminLessonDto(l.getId(), l.getSlug(), l.getOrdinal(), l.getIcon(), l.isPublished(),
                l.getSection().getId(), l.getCategory() == null ? null : l.getCategory().getId(),
                translations, slideDtos);
    }

    private TaxonomyRef sectionRef(LessonSection s, String locale) {
        return new TaxonomyRef(s.getSlug(), Locales.pick(s.getNames(), locale));
    }

    private TaxonomyRef categoryRef(LessonCategory c, String locale) {
        return c == null ? null : new TaxonomyRef(c.getSlug(), Locales.pick(c.getNames(), locale));
    }
}
