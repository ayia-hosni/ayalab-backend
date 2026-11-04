package com.ayalab.service;

import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

class LocalesTest {

    @Test
    void explicitParamWinsOverHeader() {
        assertThat(Locales.resolve("ar", "en-US,en;q=0.9")).isEqualTo("ar");
    }

    @Test
    void usesFirstSupportedHeaderLanguage() {
        assertThat(Locales.resolve(null, "fr-FR,ar;q=0.8,en;q=0.5")).isEqualTo("ar");
    }

    @Test
    void regionalTagsReduceToPrimaryLanguage() {
        assertThat(Locales.resolve("AR-EG", null)).isEqualTo("ar");
    }

    @Test
    void unsupportedOrMalformedFallsBackToEnglish() {
        assertThat(Locales.resolve("xx", "fr")).isEqualTo("en");
        assertThat(Locales.resolve(null, ";;;")).isEqualTo("en");
        assertThat(Locales.resolve(null, null)).isEqualTo("en");
    }

    @Test
    void pickFallsBackToEnglishWhenTranslationMissing() {
        assertThat(Locales.pick(Map.of("en", "Hello"), "ar")).isEqualTo("Hello");
        assertThat(Locales.pick(Map.of("en", "Hello", "ar", "مرحبا"), "ar")).isEqualTo("مرحبا");
    }
}
