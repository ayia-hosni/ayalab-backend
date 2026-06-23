package com.ayalab.payment;

import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;

@Component
public class PaymobWebhookVerifier implements WebhookVerifier {

    /** Ordered fields Paymob uses for HMAC concatenation. */
    private static final List<String> HMAC_FIELDS = List.of(
            "amount_cents", "created_at", "currency", "error_occured",
            "has_parent_transaction", "id", "integration_id", "is_3d_secure",
            "is_auth", "is_capture", "is_refunded", "is_standalone_payment",
            "is_voided", "order", "owner", "pending",
            "source_data.pan", "source_data.sub_type", "source_data.type", "success"
    );

    private final PaymobProperties props;

    public PaymobWebhookVerifier(PaymobProperties props) {
        this.props = props;
    }

    @Override
    @SuppressWarnings("unchecked")
    public boolean verify(Map<String, Object> payload, String receivedHmac) {
        try {
            Map<String, Object> obj = (Map<String, Object>) payload.getOrDefault("obj", Map.of());
            StringBuilder concat = new StringBuilder();
            for (String field : HMAC_FIELDS) {
                concat.append(resolve(obj, field));
            }
            String expected = hmacSha512(props.hmacSecret(), concat.toString());
            return expected.equalsIgnoreCase(receivedHmac);
        } catch (Exception e) {
            return false;
        }
    }

    private Object resolve(Map<String, Object> obj, String dotPath) {
        String[] parts = dotPath.split("\\.");
        Object current = obj;
        for (String part : parts) {
            if (!(current instanceof Map<?, ?> map)) return "";
            current = map.get(part);
        }
        return current == null ? "" : current;
    }

    private String hmacSha512(String secret, String data) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA512");
        mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
        byte[] raw = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
        return HexFormat.of().formatHex(raw);
    }
}
