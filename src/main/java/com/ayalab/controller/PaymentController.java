package com.ayalab.controller;

import com.ayalab.dto.InitiatePaymentRequest;
import com.ayalab.dto.InitiatePaymentResponse;
import com.ayalab.payment.PaymentContext;
import com.ayalab.payment.PaymentOrchestrator;
import com.ayalab.payment.WebhookVerifier;
import com.ayalab.payment.entity.PaymentOrder;
import com.ayalab.payment.logging.PaymentEventType;
import com.ayalab.payment.logging.PaymentLogEvent;
import org.springframework.context.ApplicationEventPublisher;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.UUID;

@Tag(name = "Payments", description = "Paymob payment integration")
@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    private final PaymentOrchestrator orchestrator;
    private final WebhookVerifier webhookVerifier;
    private final ApplicationEventPublisher events;

    public PaymentController(PaymentOrchestrator orchestrator,
                             WebhookVerifier webhookVerifier,
                             ApplicationEventPublisher events) {
        this.orchestrator = orchestrator;
        this.webhookVerifier = webhookVerifier;
        this.events = events;
    }

    @Operation(summary = "Initiate a payment",
            description = "Creates a Paymob order and returns a redirect URL (CARD/WALLET) or bill reference (KIOSK).")
    @PostMapping("/initiate")
    public ResponseEntity<InitiatePaymentResponse> initiate(
            @Valid @RequestBody InitiatePaymentRequest req) {

        if (req.method().name().equals("WALLET") &&
                (req.phoneNumber() == null || req.phoneNumber().isBlank())) {
            throw new IllegalArgumentException("phoneNumber is required for WALLET payments");
        }

        // Paymob expects Egyptian national format: 01XXXXXXXXX (11 digits).
        // The frontend shows "+20" as a prefix label and the user enters the subscriber
        // number (e.g. "1012345678"), so we prepend "0" when the leading zero is missing.
        String normalizedPhone = req.phoneNumber();
        if (normalizedPhone != null && !normalizedPhone.isBlank()) {
            if (normalizedPhone.startsWith("+20")) {
                normalizedPhone = "0" + normalizedPhone.substring(3);
            } else if (!normalizedPhone.startsWith("0")) {
                normalizedPhone = "0" + normalizedPhone;
            }
        }

        Map<String, Object> billing = new java.util.LinkedHashMap<>();
        billing.put("first_name", req.firstName());
        billing.put("last_name", req.lastName());
        billing.put("email", req.email());
        billing.put("phone_number", normalizedPhone != null ? normalizedPhone : "N/A");
        billing.put("apartment", "N/A");
        billing.put("floor", "N/A");
        billing.put("street", "N/A");
        billing.put("building", "N/A");
        billing.put("shipping_method", "N/A");
        billing.put("postal_code", "N/A");
        billing.put("city", "N/A");
        billing.put("country", "EG");
        billing.put("state", "N/A");

        PaymentContext ctx = new PaymentContext(
                req.amountCents(),
                req.currency(),
                "AYA-" + UUID.randomUUID().toString().replace("-", "").substring(0, 12).toUpperCase(),
                billing,
                normalizedPhone
        );

        PaymentOrder order = orchestrator.initiate(req.method(), ctx);
        return ResponseEntity.ok(InitiatePaymentResponse.from(order));
    }

    @Operation(summary = "Paymob transaction webhook",
            description = "Receives transaction callbacks from Paymob. Verifies HMAC before updating order status.")
    @PostMapping("/webhook")
    @SuppressWarnings("unchecked")
    public ResponseEntity<Void> webhook(
            @RequestParam(required = false) String hmac,
            @RequestBody Map<String, Object> payload) {

        events.publishEvent(new PaymentLogEvent(PaymentEventType.WEBHOOK_RECEIVED,
                null, null, null, null, null, null));

        if (hmac == null || !webhookVerifier.verify(payload, hmac)) {
            events.publishEvent(new PaymentLogEvent(PaymentEventType.WEBHOOK_REJECTED,
                    null, null, null, null, null, "HMAC mismatch"));
            return ResponseEntity.badRequest().build();
        }

        events.publishEvent(new PaymentLogEvent(PaymentEventType.WEBHOOK_VERIFIED,
                null, null, null, null, null, null));

        Map<String, Object> obj = (Map<String, Object>) payload.getOrDefault("obj", Map.of());
        Map<String, Object> order = (Map<String, Object>) obj.getOrDefault("order", Map.of());
        String paymobOrderId = String.valueOf(order.get("id"));
        boolean success = Boolean.TRUE.equals(obj.get("success"));

        if (success) {
            orchestrator.handleWebhookSuccess(paymobOrderId);
        } else {
            orchestrator.handleWebhookFailure(paymobOrderId);
        }

        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Get payment status", description = "Poll payment status by internal reference.")
    @GetMapping("/{ref}/status")
    public ResponseEntity<InitiatePaymentResponse> status(@PathVariable String ref) {
        return ResponseEntity.ok(InitiatePaymentResponse.from(orchestrator.findByRef(ref)));
    }
}
