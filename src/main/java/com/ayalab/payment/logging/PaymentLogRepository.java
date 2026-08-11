package com.ayalab.payment.logging;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface PaymentLogRepository extends JpaRepository<PaymentLog, UUID> {

    Page<PaymentLog> findAllByOrderByCreatedAtDesc(Pageable pageable);

    Page<PaymentLog> findByEventTypeOrderByCreatedAtDesc(PaymentEventType eventType, Pageable pageable);

    @Query("SELECT COUNT(l) FROM PaymentLog l WHERE l.eventType = :type AND l.createdAt > :since")
    long countByEventTypeAndSince(PaymentEventType type, Instant since);

    @Query(value = "SELECT COALESCE(SUM(amount_cents), 0) FROM payment_logs WHERE event_type = 'PAYMENT_COMPLETED' AND created_at > :since", nativeQuery = true)
    long sumRevenueSince(Instant since);

    @Query(value = "SELECT method, COUNT(*) FROM payment_logs WHERE event_type = 'PAYMENT_INITIATED' AND created_at > :since AND method IS NOT NULL GROUP BY method", nativeQuery = true)
    List<Object[]> countByMethodSince(Instant since);

    /** Hourly buckets — used for 24-hour period. */
    @Query(value = """
            SELECT TO_CHAR(DATE_TRUNC('hour', created_at AT TIME ZONE 'UTC'), 'YYYY-MM-DD"T"HH24:00') AS ts,
                   COUNT(*) FILTER (WHERE event_type = 'PAYMENT_INITIATED')  AS initiated,
                   COUNT(*) FILTER (WHERE event_type = 'PAYMENT_COMPLETED')  AS completed,
                   COALESCE(SUM(amount_cents) FILTER (WHERE event_type = 'PAYMENT_COMPLETED'), 0) AS revenue
            FROM payment_logs
            WHERE created_at > :since
            GROUP BY DATE_TRUNC('hour', created_at AT TIME ZONE 'UTC')
            ORDER BY DATE_TRUNC('hour', created_at AT TIME ZONE 'UTC')
            """, nativeQuery = true)
    List<Object[]> hourlyTimeline(Instant since);

    /** Daily buckets — used for 7-day and 30-day periods. */
    @Query(value = """
            SELECT TO_CHAR(DATE_TRUNC('day', created_at AT TIME ZONE 'UTC'), 'YYYY-MM-DD') AS ts,
                   COUNT(*) FILTER (WHERE event_type = 'PAYMENT_INITIATED')  AS initiated,
                   COUNT(*) FILTER (WHERE event_type = 'PAYMENT_COMPLETED')  AS completed,
                   COALESCE(SUM(amount_cents) FILTER (WHERE event_type = 'PAYMENT_COMPLETED'), 0) AS revenue
            FROM payment_logs
            WHERE created_at > :since
            GROUP BY DATE_TRUNC('day', created_at AT TIME ZONE 'UTC')
            ORDER BY DATE_TRUNC('day', created_at AT TIME ZONE 'UTC')
            """, nativeQuery = true)
    List<Object[]> dailyTimeline(Instant since);
}
