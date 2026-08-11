package com.ayalab.payment;

import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.HashMap;
import java.util.Map;

@Component
public class PaymobClient {

    private static final ParameterizedTypeReference<Map<String, Object>> MAP_TYPE =
            new ParameterizedTypeReference<>() {};

    private final RestClient http;
    private final PaymobProperties props;

    public PaymobClient(RestClient.Builder builder, PaymobProperties props) {
        this.props = props;
        this.http = builder.baseUrl(props.baseUrl()).build();
    }

    public String authenticate() {
        Map<String, Object> body = Map.of("api_key", props.apiKey());
        Map<String, Object> resp = post("/auth/tokens", body);
        return (String) resp.get("token");
    }

    public String registerOrder(String authToken, PaymentContext ctx) {
        Map<String, Object> body = Map.of(
                "auth_token", authToken,
                "delivery_needed", false,
                "amount_cents", ctx.amountCents(),
                "currency", ctx.currency(),
                "merchant_order_id", ctx.internalRef()
        );
        Map<String, Object> resp = post("/ecommerce/orders", body);
        return String.valueOf(resp.get("id"));
    }

    public String getPaymentKey(String authToken, String paymobOrderId, int integrationId,
                                PaymentContext ctx) {
        Map<String, Object> body = new HashMap<>();
        body.put("auth_token", authToken);
        body.put("amount_cents", ctx.amountCents());
        body.put("expiration", 3600);
        body.put("order_id", paymobOrderId);
        body.put("billing_data", ctx.billingData());
        body.put("currency", ctx.currency());
        body.put("integration_id", integrationId);

        Map<String, Object> resp = post("/acceptance/payment_keys", body);
        return (String) resp.get("token");
    }

    public Map<String, Object> pay(Map<String, Object> body) {
        return post("/acceptance/payments/pay", body);
    }

    private Map<String, Object> post(String path, Map<String, Object> body) {
        return http.post()
                .uri(path)
                .body(body)
                .retrieve()
                .body(MAP_TYPE);
    }
}
