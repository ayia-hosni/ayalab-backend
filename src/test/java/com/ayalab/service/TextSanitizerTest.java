package com.ayalab.service;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class TextSanitizerTest {

    private final TextSanitizer sanitizer = new TextSanitizer();

    @Test
    void keepsAllowedMarkupAndClasses() {
        String html = "<p>Use <code class=\"x\">head</code> and <strong>next</strong></p>";
        assertThat(sanitizer.clean(html)).isEqualTo(html);
    }

    @Test
    void stripsScriptsHandlersAndUnknownTags() {
        String cleaned = sanitizer.clean("<p onclick=\"evil()\">hi</p><script>alert(1)</script><iframe src=x></iframe>");
        assertThat(cleaned).isEqualTo("<p>hi</p>");
    }

    @Test
    void removesJavascriptLinks() {
        assertThat(sanitizer.clean("<a href=\"javascript:alert(1)\">x</a>")).isEqualTo("x");
    }

    @Test
    void nullStaysNull() {
        assertThat(sanitizer.clean(null)).isNull();
    }
}
