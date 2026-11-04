package com.ayalab.controller;

import com.ayalab.dto.LessonDetail;
import com.ayalab.dto.LessonSummary;
import com.ayalab.dto.TaxonomyRef;
import com.ayalab.service.AdminLessonService;
import com.ayalab.service.LessonService;
import com.ayalab.service.NotFoundException;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.hamcrest.Matchers.hasItem;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest({LessonController.class, AdminLessonController.class})
class LessonControllerTest {

    @Autowired MockMvc mvc;
    @MockitoBean LessonService service;
    @MockitoBean AdminLessonService admin;

    private static LessonSummary summary() {
        return new LessonSummary(1L, "tree-basics", 5, "x", "Tree Basics", "d",
                new TaxonomyRef("trees", "Trees"), null, 8);
    }

    @Test
    void listUsesLangParamAndVariesOnAcceptLanguage() throws Exception {
        when(service.list("ar")).thenReturn(List.of(summary()));
        mvc.perform(get("/api/lessons").param("lang", "ar"))
                .andExpect(status().isOk())
                .andExpect(header().stringValues("Vary", hasItem("Accept-Language")))
                .andExpect(jsonPath("$[0].slug").value("tree-basics"))
                .andExpect(jsonPath("$[0].section.name").value("Trees"))
                .andExpect(jsonPath("$[0].titleEn").doesNotExist());
    }

    @Test
    void listFallsBackToAcceptLanguageHeader() throws Exception {
        when(service.list("ar")).thenReturn(List.of());
        mvc.perform(get("/api/lessons").header("Accept-Language", "ar-EG,ar;q=0.9"))
                .andExpect(status().isOk());
        verify(service).list(eq("ar"));
    }

    @Test
    void detailReturns404ForUnknownLesson() throws Exception {
        when(service.get("nope", "en")).thenThrow(new NotFoundException("Lesson not found: nope"));
        mvc.perform(get("/api/lessons/nope"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error").value("Lesson not found: nope"));
    }

    @Test
    void detailReturnsLesson() throws Exception {
        when(service.get("tree-basics", "en")).thenReturn(new LessonDetail(1L, "tree-basics", 5, "x", "T", "d",
                new TaxonomyRef("trees", "Trees"), null, List.of()));
        mvc.perform(get("/api/lessons/tree-basics"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.slides").isArray());
    }
}
