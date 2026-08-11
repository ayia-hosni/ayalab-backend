package com.ayalab.payment.method;

import com.ayalab.payment.PaymentContext;
import com.ayalab.payment.PaymentMethod;
import com.ayalab.payment.PaymentMethodType;
import com.ayalab.payment.PaymentOutcome;
import com.ayalab.payment.PaymobClient;
import com.ayalab.payment.PaymobProperties;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class KioskPaymentMethod implements PaymentMethod {

    private final PaymobProperties props;

    public KioskPaymentMethod(PaymobProperties props) {
        this.props = props;
    }

    @Override
    public PaymentMethodType type() {
        return PaymentMethodType.KIOSK;
    }

    @Override
    public int integrationId() {
        return props.kioskIntegrationId();
    }

    @Override
    @SuppressWarnings("unchecked")
    public PaymentOutcome execute(String paymentKey, PaymentContext ctx, PaymobClient client) {
        Map<String, Object> body = Map.of(
                "source", Map.of(
                        "identifier", "AGGREGATOR",
                        "subtype", "AGGREGATOR"
                ),
                "payment_token", paymentKey
        );
        Map<String, Object> resp = client.pay(body);
        Map<String, Object> data = (Map<String, Object>) resp.getOrDefault("data", Map.of());
        String billRef = String.valueOf(data.get("bill_reference"));
        return new PaymentOutcome(null, billRef);
    }
}
