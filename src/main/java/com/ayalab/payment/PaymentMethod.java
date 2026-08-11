package com.ayalab.payment;

/**
 * OCP contract: closed for modification, open for extension.
 * Add a new payment method by implementing this interface — zero existing files change.
 */
public interface PaymentMethod {

    PaymentMethodType type();

    int integrationId();

    /** Executes the method-specific payment step after the shared auth/order/key flow. */
    PaymentOutcome execute(String paymentKey, PaymentContext ctx, PaymobClient client);
}
