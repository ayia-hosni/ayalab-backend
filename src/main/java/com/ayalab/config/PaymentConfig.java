package com.ayalab.config;

import com.ayalab.payment.PaymobProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties(PaymobProperties.class)
public class PaymentConfig {}
