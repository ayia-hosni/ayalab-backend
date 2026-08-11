CREATE TABLE payment_orders (
    id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    internal_ref    VARCHAR(64)  NOT NULL UNIQUE,
    paymob_order_id VARCHAR(64),
    amount_cents    INTEGER      NOT NULL,
    currency        VARCHAR(8)   NOT NULL DEFAULT 'EGP',
    method          VARCHAR(32)  NOT NULL,
    status          VARCHAR(32)  NOT NULL DEFAULT 'PENDING',
    redirect_url    TEXT,
    bill_reference  VARCHAR(64),
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payment_orders_internal_ref   ON payment_orders (internal_ref);
CREATE INDEX idx_payment_orders_paymob_order_id ON payment_orders (paymob_order_id);
CREATE INDEX idx_payment_orders_status         ON payment_orders (status);
