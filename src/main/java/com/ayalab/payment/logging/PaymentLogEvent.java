package com.ayalab.payment.logging;

import com.ayalab.payment.PaymentMethodType;

/**
 * Spring ApplicationEvent published by business logic.
 * Persisted asynchronously after the originating transaction commits.
 */
public class PaymentLogEvent {

    private final PaymentEventType eventType;
    private final String internalRef;
    private final String paymobOrderId;
    private final PaymentMethodType method;
    private final Integer amountCents;
    private final String currency;
    private final String errorMessage;

    public PaymentLogEvent(PaymentEventType eventType,
                           String internalRef,
                           String paymobOrderId,
                           PaymentMethodType method,
                           Integer amountCents,
                           String currency,
                           String errorMessage) {
        this.eventType = eventType;
        this.internalRef = internalRef;
        this.paymobOrderId = paymobOrderId;
        this.method = method;
        this.amountCents = amountCents;
        this.currency = currency;
        this.errorMessage = errorMessage;
    }

    public PaymentEventType getEventType() { return eventType; }
    public String getInternalRef()         { return internalRef; }
    public String getPaymobOrderId()       { return paymobOrderId; }
    public PaymentMethodType getMethod()   { return method; }
    public Integer getAmountCents()        { return amountCents; }
    public String getCurrency()            { return currency; }
    public String getErrorMessage()        { return errorMessage; }
}
