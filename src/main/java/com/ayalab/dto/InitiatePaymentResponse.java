package com.ayalab.dto;

import com.ayalab.payment.PaymentMethodType;
import com.ayalab.payment.entity.PaymentOrder;
import com.ayalab.payment.entity.PaymentOrderStatus;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Result of a payment initiation")
public record InitiatePaymentResponse(

        @Schema(description = "Internal order reference")
        String ref,

        @Schema(description = "Payment method used")
        PaymentMethodType method,

        @Schema(description = "Current status")
        PaymentOrderStatus status,

        @Schema(description = "Redirect URL for CARD and WALLET methods — open in browser/iframe")
        String redirectUrl,

        @Schema(description = "Bill reference code for KIOSK payments")
        String billReference
) {
    public static InitiatePaymentResponse from(PaymentOrder order) {
        return new InitiatePaymentResponse(
                order.getInternalRef(),
                order.getMethod(),
                order.getStatus(),
                order.getRedirectUrl(),
                order.getBillReference()
        );
    }
}
