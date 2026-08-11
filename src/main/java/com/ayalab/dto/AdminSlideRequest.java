package com.ayalab.dto;

public record AdminSlideRequest(
        Long   id,
        int    ordinal,
        String kickerEn,
        String kickerAr,
        String titleEn,
        String titleAr,
        String visual,
        String visualSpec,
        String bodyEn,
        String bodyAr
) {}
