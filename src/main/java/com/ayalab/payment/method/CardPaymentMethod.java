package com.ayalab.payment.method;

import com.ayalab.payment.PaymentContext;
import com.ayalab.payment.PaymentMethod;
import com.ayalab.payment.PaymentMethodType;
import com.ayalab.payment.PaymentOutcome;
import com.ayalab.payment.PaymobClient;
import com.ayalab.payment.PaymobProperties;
import org.springframework.stereotype.Component;

@Component
public class CardPaymentMethod implements PaymentMethod {

    private static final String IFRAME_URL =
            "https://accept.paymob.com/api/acceptance/iframes/%s?payment_token=%s";

    private final PaymobProperties props;

    public CardPaymentMethod(PaymobProperties props) {
        this.props = props;
    }

    @Override
    public PaymentMethodType type() {
        return PaymentMethodType.CARD;
    }

    @Override
    public int integrationId() {
        return props.cardIntegrationId();
    }

    @Override
    public PaymentOutcome execute(String paymentKey, PaymentContext ctx, PaymobClient client) {
        String url = IFRAME_URL.formatted(props.cardIframeId(), paymentKey);
        return new PaymentOutcome(url, null);
    }
}
