package com.ayalab.controller;

import com.ayalab.service.AdminLessonService;
import com.ayalab.service.LessonService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest({LessonController.class, AdminLessonController.class})
class AdminLessonControllerTest {

    @Autowired MockMvc mvc;
    @MockitoBean LessonService service;
    @MockitoBean AdminLessonService admin;

    @Test
    void rejectsMalformedBodyBeforeReachingTheService() throws Exception {
        String body = """
                {"slug":"Bad Slug","ordinal":0,"icon":"","published":true,"sectionId":null,
                 "translations":{},"slides":[]}""";
        mvc.perform(post("/api/admin/lessons").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").exists());
        verifyNoInteractions(admin);
    }

    @Test
    void surfacesSpecValidationErrorsAs400() throws Exception {
        String body = """
                {"slug":"ok","ordinal":0,"icon":"x","published":true,"sectionId":1,
                 "translations":{"en":{"title":"T","description":"D"}},
                 "slides":[{"spec":{"kind":"pie"},"translations":{"en":{"kicker":"k","title":"t","body":"b"}}}]}""";
        doThrow(new IllegalArgumentException("slides[0].spec: unknown spec kind 'pie'"))
                .when(admin).create(any());
        mvc.perform(post("/api/admin/lessons").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("slides[0].spec: unknown spec kind 'pie'"));
    }
}
