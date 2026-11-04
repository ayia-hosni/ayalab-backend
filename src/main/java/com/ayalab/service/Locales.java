package com.ayalab.service;

import java.util.List;
import java.util.Locale;
import java.util.Map;

/** Supported content locales and request locale resolution. English is the fallback for everything. */
public final class Locales {

    public static final String DEFAULT = "en";
    public static final List<String> SUPPORTED = List.of("en", "ar");

    private Locales() {}

    /** Picks the explicit {@code lang} param, else the first {@code Accept-Language} tag, else English. */
    public static String resolve(String explicit, String acceptLanguage) {
        String fromParam = normalize(explicit);
        if (fromParam != null) return fromParam;
        if (acceptLanguage != null) {
            try {
                for (Locale.LanguageRange r : Locale.LanguageRange.parse(acceptLanguage)) {
                    String tag = normalize(r.getRange());
                    if (tag != null) return tag;
                }
            } catch (IllegalArgumentException ignored) {
                // malformed header: fall through to the default
            }
        }
        return DEFAULT;
    }

    /** Returns the translation for {@code locale}, else the English one, else null. */
    public static <T> T pick(Map<String, T> translations, String locale) {
        T value = translations.get(locale);
        return value != null ? value : translations.get(DEFAULT);
    }

    private static String normalize(String tag) {
        if (tag == null || tag.isBlank()) return null;
        String primary = tag.trim().toLowerCase(Locale.ROOT).split("[-_]")[0];
        return SUPPORTED.contains(primary) ? primary : null;
    }
}
