package com.ayalab.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("ayalab API")
                        .description("REST API for the ayalab coding practice platform. " +
                                "Serves the problem catalogue and evaluates JavaScript submissions " +
                                "inside a sandboxed GraalVM engine.")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("ayalab")
                                .email("ayia.hosni@gmail.com")));
    }
}
