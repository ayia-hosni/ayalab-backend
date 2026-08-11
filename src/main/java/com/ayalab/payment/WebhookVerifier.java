package com.ayalab.payment;

import java.util.Map;

public interface WebhookVerifier {
    boolean verify(Map<String, Object> payload, String receivedHmac);
}
