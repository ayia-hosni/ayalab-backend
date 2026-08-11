package com.ayalab.payment;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "paymob")
public record PaymobProperties(
        String apiKey,
        String hmacSecret,
        String baseUrl,
        int cardIntegrationId,
        String cardIframeId,
        int walletIntegrationId,
        int kioskIntegrationId
) {
    public PaymobProperties {
        if (baseUrl == null || baseUrl.isBlank()) {
            baseUrl = "https://accept.paymob.com/api";
        }
    }
}
