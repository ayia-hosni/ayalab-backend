package com.ayalab.payment;

import com.ayalab.payment.entity.PaymentOrder;
import com.ayalab.payment.entity.PaymentOrderStatus;
import com.ayalab.payment.logging.PaymentEventType;
import com.ayalab.payment.logging.PaymentLogEvent;
import com.ayalab.payment.repository.PaymentOrderRepository;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
public class PaymentOrchestrator {

    private final PaymobClient client;
    private final PaymentOrderRepository orderRepo;
    private final ApplicationEventPublisher events;
    private final Map<PaymentMethodType, PaymentMethod> methods;

    public PaymentOrchestrator(PaymobClient client,
                               PaymentOrderRepository orderRepo,
                               ApplicationEventPublisher events,
                               List<PaymentMethod> methodBeans) {
        this.client = client;
        this.orderRepo = orderRepo;
        this.events = events;
        this.methods = methodBeans.stream()
                .collect(Collectors.toMap(PaymentMethod::type, Function.identity()));
    }

    @Transactional
    public PaymentOrder initiate(PaymentMethodType methodType, PaymentContext ctx) {
        publish(PaymentEventType.PAYMENT_INITIATED, ctx.internalRef(), null, methodType,
                ctx.amountCents(), ctx.currency(), null);
        try {
            PaymentMethod method = resolve(methodType);

            String authToken;
            try {
                authToken = client.authenticate();
            } catch (Exception ex) {
                publish(PaymentEventType.PAYMOB_AUTH_FAILED, ctx.internalRef(), null,
                        methodType, ctx.amountCents(), ctx.currency(), ex.getMessage());
                throw ex;
            }
            publish(PaymentEventType.PAYMOB_AUTH_SUCCESS, ctx.internalRef(), null,
                    methodType, ctx.amountCents(), ctx.currency(), null);

            String paymobOrderId = client.registerOrder(authToken, ctx);
            publish(PaymentEventType.ORDER_REGISTERED, ctx.internalRef(), paymobOrderId,
                    methodType, ctx.amountCents(), ctx.currency(), null);

            String paymentKey = client.getPaymentKey(authToken, paymobOrderId, method.integrationId(), ctx);
            publish(PaymentEventType.PAYMENT_KEY_GENERATED, ctx.internalRef(), paymobOrderId,
                    methodType, ctx.amountCents(), ctx.currency(), null);

            PaymentOutcome outcome = method.execute(paymentKey, ctx, client);
            publish(PaymentEventType.METHOD_EXECUTED, ctx.internalRef(), paymobOrderId,
                    methodType, ctx.amountCents(), ctx.currency(), null);

            PaymentOrder order = new PaymentOrder();
            order.setInternalRef(ctx.internalRef());
            order.setPaymobOrderId(paymobOrderId);
            order.setAmountCents(ctx.amountCents());
            order.setCurrency(ctx.currency());
            order.setMethod(methodType);
            order.setRedirectUrl(outcome.redirectUrl());
            order.setBillReference(outcome.billReference());
            return orderRepo.save(order);

        } catch (Exception ex) {
            publish(PaymentEventType.PAYMENT_FAILED, ctx.internalRef(), null,
                    methodType, ctx.amountCents(), ctx.currency(), ex.getMessage());
            throw ex;
        }
    }

    @Transactional
    public void handleWebhookSuccess(String paymobOrderId) {
        orderRepo.findByPaymobOrderId(paymobOrderId).ifPresent(order -> {
            order.setStatus(PaymentOrderStatus.PAID);
            orderRepo.save(order);
            publish(PaymentEventType.PAYMENT_COMPLETED, order.getInternalRef(), paymobOrderId,
                    order.getMethod(), order.getAmountCents(), order.getCurrency(), null);
        });
    }

    @Transactional
    public void handleWebhookFailure(String paymobOrderId) {
        orderRepo.findByPaymobOrderId(paymobOrderId).ifPresent(order -> {
            if (order.getStatus() != PaymentOrderStatus.PAID) {
                order.setStatus(PaymentOrderStatus.FAILED);
                orderRepo.save(order);
                publish(PaymentEventType.PAYMENT_FAILED, order.getInternalRef(), paymobOrderId,
                        order.getMethod(), order.getAmountCents(), order.getCurrency(), "Webhook failure");
            }
        });
    }

    public PaymentOrder findByRef(String internalRef) {
        return orderRepo.findByInternalRef(internalRef)
                .orElseThrow(() -> new IllegalArgumentException("Payment order not found: " + internalRef));
    }

    private void publish(PaymentEventType type, String ref, String paymobOrderId,
                         PaymentMethodType method, Integer amount, String currency, String error) {
        events.publishEvent(new PaymentLogEvent(type, ref, paymobOrderId, method, amount, currency, error));
    }

    private PaymentMethod resolve(PaymentMethodType type) {
        PaymentMethod method = methods.get(type);
        if (method == null) throw new IllegalArgumentException("Unsupported payment method: " + type);
        return method;
    }
}
