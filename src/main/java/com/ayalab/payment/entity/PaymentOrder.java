package com.ayalab.payment.entity;

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

@Entity
@Table(name = "payment_orders")
public class PaymentOrder {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true)
    private String internalRef;

    private String paymobOrderId;

    @Column(nullable = false)
    private int amountCents;

    @Column(nullable = false)
    private String currency;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentMethodType method;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PaymentOrderStatus status = PaymentOrderStatus.PENDING;

    private String redirectUrl;

    private String billReference;

    @Column(nullable = false, updatable = false)
    private Instant createdAt = Instant.now();

    private Instant updatedAt = Instant.now();

    public UUID getId() { return id; }

    public String getInternalRef() { return internalRef; }
    public void setInternalRef(String internalRef) { this.internalRef = internalRef; }

    public String getPaymobOrderId() { return paymobOrderId; }
    public void setPaymobOrderId(String paymobOrderId) { this.paymobOrderId = paymobOrderId; }

    public int getAmountCents() { return amountCents; }
    public void setAmountCents(int amountCents) { this.amountCents = amountCents; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public PaymentMethodType getMethod() { return method; }
    public void setMethod(PaymentMethodType method) { this.method = method; }

    public PaymentOrderStatus getStatus() { return status; }
    public void setStatus(PaymentOrderStatus status) {
        this.status = status;
        this.updatedAt = Instant.now();
    }

    public String getRedirectUrl() { return redirectUrl; }
    public void setRedirectUrl(String redirectUrl) { this.redirectUrl = redirectUrl; }

    public String getBillReference() { return billReference; }
    public void setBillReference(String billReference) { this.billReference = billReference; }

    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
}
