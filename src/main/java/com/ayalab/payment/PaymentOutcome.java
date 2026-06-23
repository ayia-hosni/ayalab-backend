package com.ayalab.payment;

public record PaymentOutcome(
        String redirectUrl,
        String billReference
) {}
