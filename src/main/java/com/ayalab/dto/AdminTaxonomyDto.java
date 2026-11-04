package com.ayalab.dto;

import java.util.List;
import java.util.Map;

public record AdminTaxonomyDto(List<Section> sections) {

    public record Section(Long id, String slug, int ordinal, Map<String, String> names, List<Category> categories) {}

    public record Category(Long id, String slug, int ordinal, Map<String, String> names) {}
}
