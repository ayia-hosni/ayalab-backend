package com.ayalab.controller;

import com.ayalab.dto.DashboardStats;
import com.ayalab.dto.PaymentLogEntry;
import com.ayalab.dto.TimelinePoint;
import com.ayalab.payment.logging.PaymentEventType;
import com.ayalab.payment.logging.PaymentLog;
import com.ayalab.payment.logging.PaymentLogRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Tag(name = "Dashboard", description = "Payment analytics and audit logs")
@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    private final PaymentLogRepository repo;

    public DashboardController(PaymentLogRepository repo) {
        this.repo = repo;
    }

    @Operation(summary = "Aggregate stats", description = "KPIs and timeline for the given period (day / week / month).")
    @GetMapping("/stats")
    public DashboardStats stats(@RequestParam(defaultValue = "week") String period) {
        Instant since = since(period);

        long total     = repo.countByEventTypeAndSince(PaymentEventType.PAYMENT_INITIATED, since);
        long succeeded = repo.countByEventTypeAndSince(PaymentEventType.PAYMENT_COMPLETED, since);
        long failed    = repo.countByEventTypeAndSince(PaymentEventType.PAYMENT_FAILED, since);
        long revenue   = repo.sumRevenueSince(since);
        double rate    = total == 0 ? 0 : (succeeded * 100.0 / total);

        Map<String, Long> byMethod = new LinkedHashMap<>();
        for (Object[] row : repo.countByMethodSince(since)) {
            if (row[0] != null) byMethod.put(row[0].toString(), ((Number) row[1]).longValue());
        }

        List<Object[]> raw = period.equals("day")
                ? repo.hourlyTimeline(since)
                : repo.dailyTimeline(since);

        List<TimelinePoint> timeline = raw.stream()
                .map(r -> new TimelinePoint(
                        r[0].toString(),
                        ((Number) r[1]).longValue(),
                        ((Number) r[2]).longValue(),
                        ((Number) r[3]).longValue()))
                .toList();

        return new DashboardStats(total, succeeded, failed, rate, revenue, byMethod, timeline);
    }

    @Operation(summary = "Audit log", description = "Paginated payment event log, newest first.")
    @GetMapping("/logs")
    public Page<PaymentLogEntry> logs(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String eventType) {

        PageRequest pageable = PageRequest.of(page, Math.min(size, 100));

        Page<PaymentLog> raw = (eventType != null && !eventType.isBlank())
                ? repo.findByEventTypeOrderByCreatedAtDesc(PaymentEventType.valueOf(eventType), pageable)
                : repo.findAllByOrderByCreatedAtDesc(pageable);

        return raw.map(PaymentLogEntry::from);
    }

    private Instant since(String period) {
        return switch (period) {
            case "day"   -> Instant.now().minus(1,  ChronoUnit.DAYS);
            case "month" -> Instant.now().minus(30, ChronoUnit.DAYS);
            default      -> Instant.now().minus(7,  ChronoUnit.DAYS);
        };
    }
}
