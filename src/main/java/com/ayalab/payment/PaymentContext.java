package com.ayalab.payment;

import java.util.Map;

public record PaymentContext(
        int amountCents,
        String currency,
        String internalRef,
        Map<String, Object> billingData,
        String phoneNumber
) {}
