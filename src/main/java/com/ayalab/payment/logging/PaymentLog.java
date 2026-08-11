package com.ayalab.payment.logging;

import com.ayalab.payment.PaymentMethodType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.UUID;

/**
 * Append-only audit log of every payment lifecycle event.
 * Never updated — only inserted. BRIN index on created_at makes
 * time-range dashboard queries fast with minimal index overhead.
 */
@Entity
@Table(name = "payment_logs")
public class PaymentLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    private String internalRef;

    private String paymobOrderId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentEventType eventType;

    @Enumerated(EnumType.STRING)
    private PaymentMethodType method;

    private Integer amountCents;

    private String currency;

    @Column(columnDefinition = "text")
    private String errorMessage;

    @Column(nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    public UUID getId()                  { return id; }
    public String getInternalRef()       { return internalRef; }
    public String getPaymobOrderId()     { return paymobOrderId; }
    public PaymentEventType getEventType() { return eventType; }
    public PaymentMethodType getMethod() { return method; }
    public Integer getAmountCents()      { return amountCents; }
    public String getCurrency()          { return currency; }
    public String getErrorMessage()      { return errorMessage; }
    public Instant getCreatedAt()        { return createdAt; }

    public void setInternalRef(String v)   { this.internalRef = v; }
    public void setPaymobOrderId(String v) { this.paymobOrderId = v; }
    public void setEventType(PaymentEventType v) { this.eventType = v; }
    public void setMethod(PaymentMethodType v)    { this.method = v; }
    public void setAmountCents(Integer v)  { this.amountCents = v; }
    public void setCurrency(String v)      { this.currency = v; }
    public void setErrorMessage(String v)  { this.errorMessage = v; }
}
