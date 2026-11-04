package com.ayalab.service;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.safety.Safelist;
import org.springframework.stereotype.Component;

/**
 * Cleans author-supplied rich text before it is stored. Only simple inline/paragraph markup
 * survives; scripts, event handlers, styles and unknown tags are removed.
 */
@Component
public class TextSanitizer {

    private static final Safelist ALLOWED = new Safelist()
            .addTags("p", "br", "strong", "b", "em", "i", "code", "ul", "ol", "li", "span")
            .addAttributes(":all", "class");

    private static final Document.OutputSettings OUTPUT = new Document.OutputSettings().prettyPrint(false);

    public String clean(String html) {
        return html == null ? null : Jsoup.clean(html, "", ALLOWED, OUTPUT);
    }
}
