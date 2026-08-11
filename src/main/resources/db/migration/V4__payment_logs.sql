-- Append-only payment audit log.
-- BRIN index on created_at: designed for monotonically-increasing timestamps —
-- orders of magnitude smaller than B-tree, with equivalent range-scan performance.
-- To migrate to TimescaleDB later: SELECT create_hypertable('payment_logs','created_at',migrate_data=>true);

CREATE TABLE payment_logs (
    id              UUID         NOT NULL DEFAULT gen_random_uuid(),
    internal_ref    VARCHAR(64),
    paymob_order_id VARCHAR(64),
    event_type      VARCHAR(64)  NOT NULL,
    method          VARCHAR(32),
    amount_cents    INTEGER,
    currency        VARCHAR(8),
    error_message   TEXT,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id)
);

-- BRIN: tiny index, fast for time-range queries on append-only data
CREATE INDEX idx_payment_logs_created_at_brin ON payment_logs USING BRIN (created_at);

-- B-tree on high-cardinality filter columns used in dashboard queries
CREATE INDEX idx_payment_logs_event_type    ON payment_logs (event_type);
CREATE INDEX idx_payment_logs_method        ON payment_logs (method);
CREATE INDEX idx_payment_logs_internal_ref  ON payment_logs (internal_ref);

-- Partial index: only completed payments need revenue aggregation
CREATE INDEX idx_payment_logs_completed_revenue
    ON payment_logs (created_at, amount_cents)
    WHERE event_type = 'PAYMENT_COMPLETED';
