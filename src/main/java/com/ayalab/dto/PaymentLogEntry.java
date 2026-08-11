package com.ayalab.dto;

import com.ayalab.payment.logging.PaymentLog;

import java.time.Instant;
import java.util.UUID;

public record PaymentLogEntry(
        UUID id,
        String internalRef,
        String paymobOrderId,
        String eventType,
        String method,
        Integer amountCents,
        String currency,
        String errorMessage,
        Instant createdAt
) {
    public static PaymentLogEntry from(PaymentLog l) {
        return new PaymentLogEntry(
                l.getId(),
                l.getInternalRef(),
                l.getPaymobOrderId(),
                l.getEventType() != null ? l.getEventType().name() : null,
                l.getMethod() != null ? l.getMethod().name() : null,
                l.getAmountCents(),
                l.getCurrency(),
                l.getErrorMessage(),
                l.getCreatedAt()
        );
    }
}
