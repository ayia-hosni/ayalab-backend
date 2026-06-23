package com.ayalab.dto;

import java.util.List;
import java.util.Map;

public record DashboardStats(
        long total,
        long succeeded,
        long failed,
        double successRate,
        long totalRevenueCents,
        Map<String, Long> byMethod,
        List<TimelinePoint> timeline
) {}
