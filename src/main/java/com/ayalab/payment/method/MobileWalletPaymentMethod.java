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
public class MobileWalletPaymentMethod implements PaymentMethod {

    private final PaymobProperties props;

    public MobileWalletPaymentMethod(PaymobProperties props) {
        this.props = props;
    }

    @Override
    public PaymentMethodType type() {
        return PaymentMethodType.WALLET;
    }

    @Override
    public int integrationId() {
        return props.walletIntegrationId();
    }

    @Override
    public PaymentOutcome execute(String paymentKey, PaymentContext ctx, PaymobClient client) {
        Map<String, Object> body = Map.of(
                "source", Map.of(
                        "identifier", ctx.phoneNumber(),
                        "subtype", "WALLET"
                ),
                "payment_token", paymentKey
        );
        Map<String, Object> resp = client.pay(body);
        String redirect = (String) resp.getOrDefault("redirect_url",
                resp.get("iframe_redirection_url"));
        return new PaymentOutcome(redirect, null);
    }
}
