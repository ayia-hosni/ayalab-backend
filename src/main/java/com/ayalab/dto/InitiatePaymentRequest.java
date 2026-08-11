package com.ayalab.dto;

import com.ayalab.payment.PaymentMethodType;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Request to start a Paymob payment")
public record InitiatePaymentRequest(

        @Schema(description = "Payment method", allowableValues = {"CARD", "WALLET", "KIOSK"})
        @NotNull PaymentMethodType method,

        @Schema(description = "Amount in smallest currency unit (piastres for EGP)", example = "9900")
        @Min(100) int amountCents,

        @Schema(description = "ISO 4217 currency code", example = "EGP")
        @NotBlank String currency,

        @Schema(description = "Mobile number — required for WALLET", example = "01012345678")
        String phoneNumber,

        @Schema(description = "Customer first name")
        @NotBlank String firstName,

        @Schema(description = "Customer last name")
        @NotBlank String lastName,

        @Schema(description = "Customer email")
        @NotBlank String email
) {}
