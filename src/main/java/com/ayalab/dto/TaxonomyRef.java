package com.ayalab.dto;

/** A section or category as shown to readers: stable slug plus the name in the requested locale. */
public record TaxonomyRef(String slug, String name) {}
