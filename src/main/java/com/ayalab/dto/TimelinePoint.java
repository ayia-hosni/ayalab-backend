package com.ayalab.dto;

public record TimelinePoint(
        String ts,
        long initiated,
        long completed,
        long revenueCents
) {}
