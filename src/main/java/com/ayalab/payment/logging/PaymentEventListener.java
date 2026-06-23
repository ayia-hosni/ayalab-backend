package com.ayalab.payment.logging;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

/**
 * Persists PaymentLogEvents in an independent REQUIRES_NEW transaction so that:
 * - Failure events inside a rolled-back payment transaction are still recorded.
 * - Webhook events published outside any transaction are still recorded.
 * Exceptions are swallowed so logging can never affect the payment flow.
 */
@Component
public class PaymentEventListener {

    private static final Logger log = LoggerFactory.getLogger(PaymentEventListener.class);

    private final PaymentLogRepository repo;

    public PaymentEventListener(PaymentLogRepository repo) {
        this.repo = repo;
    }

    @EventListener
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void on(PaymentLogEvent event) {
        try {
            PaymentLog entry = new PaymentLog();
            entry.setInternalRef(event.getInternalRef());
            entry.setPaymobOrderId(event.getPaymobOrderId());
            entry.setEventType(event.getEventType());
            entry.setMethod(event.getMethod());
            entry.setAmountCents(event.getAmountCents());
            entry.setCurrency(event.getCurrency());
            entry.setErrorMessage(event.getErrorMessage());
            repo.save(entry);
        } catch (Exception e) {
            log.warn("Failed to persist payment log event {}: {}", event.getEventType(), e.getMessage());
        }
    }
}
