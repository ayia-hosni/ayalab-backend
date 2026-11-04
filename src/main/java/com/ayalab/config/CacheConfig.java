package com.ayalab.config;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.ShallowEtagHeaderFilter;

/** Conditional GETs for the read-only lesson endpoints: clients revalidate, so edits show immediately. */
@Configuration
public class CacheConfig {

    @Bean
    public FilterRegistrationBean<ShallowEtagHeaderFilter> lessonEtagFilter() {
        FilterRegistrationBean<ShallowEtagHeaderFilter> bean = new FilterRegistrationBean<>(new ShallowEtagHeaderFilter());
        bean.addUrlPatterns("/api/lessons", "/api/lessons/*");
        bean.setName("lessonEtagFilter");
        return bean;
    }
}
