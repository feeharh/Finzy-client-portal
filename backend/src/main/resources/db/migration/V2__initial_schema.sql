-- Finzy Client Portal MVP schema (19 domain tables)
-- See docs/erd.md

CREATE TABLE admin_users (
    id                      UUID PRIMARY KEY,
    first_name              VARCHAR(100) NOT NULL,
    last_name               VARCHAR(100) NOT NULL,
    email                   VARCHAR(255) NOT NULL UNIQUE,
    password_hash           VARCHAR(255) NOT NULL,
    role                    VARCHAR(50) NOT NULL,
    account_status          VARCHAR(50) NOT NULL,
    last_login_at           TIMESTAMP,
    failed_login_attempts   INTEGER NOT NULL DEFAULT 0,
    locked_until            TIMESTAMP,
    created_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE customers (
    id                              UUID PRIMARY KEY,
    customer_number                 VARCHAR(30) NOT NULL UNIQUE,
    first_name                      VARCHAR(100) NOT NULL,
    last_name                       VARCHAR(100) NOT NULL,
    email                           VARCHAR(255),
    phone_number                    VARCHAR(30),
    whatsapp_number                 VARCHAR(30),
    preferred_communication_method  VARCHAR(30),
    notes                           TEXT,
    is_active                       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at                      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at                      TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT customers_contact_required CHECK (
        email IS NOT NULL OR phone_number IS NOT NULL OR whatsapp_number IS NOT NULL
    )
);

CREATE TABLE customer_access_tokens (
    id                  UUID PRIMARY KEY,
    customer_id         UUID NOT NULL REFERENCES customers(id),
    token_hash          VARCHAR(255) NOT NULL UNIQUE,
    expires_at          TIMESTAMP,
    revoked_at          TIMESTAMP,
    last_used_at        TIMESTAMP,
    created_by_admin_id UUID REFERENCES admin_users(id),
    created_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE appointments (
    id                          UUID PRIMARY KEY,
    appointment_number          VARCHAR(30) NOT NULL UNIQUE,
    customer_id                 UUID NOT NULL REFERENCES customers(id),
    appointment_type            VARCHAR(50) NOT NULL,
    status                      VARCHAR(50) NOT NULL,
    preferred_start_at          TIMESTAMP,
    preferred_completion_date   DATE,
    scheduled_start_at          TIMESTAMP,
    scheduled_end_at            TIMESTAMP,
    service_description         TEXT,
    customer_notes              TEXT,
    internal_notes              TEXT,
    rush_service_requested      BOOLEAN NOT NULL DEFAULT FALSE,
    information_requested_at    TIMESTAMP,
    approved_at                 TIMESTAMP,
    declined_at                 TIMESTAMP,
    cancelled_at                TIMESTAMP,
    completed_at                TIMESTAMP,
    created_at                  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at                  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE appointment_status_history (
    id                  UUID PRIMARY KEY,
    appointment_id      UUID NOT NULL REFERENCES appointments(id),
    previous_status     VARCHAR(50),
    new_status          VARCHAR(50) NOT NULL,
    changed_by_admin_id UUID REFERENCES admin_users(id),
    change_source       VARCHAR(30) NOT NULL,
    note                TEXT,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE garments (
    id                  UUID PRIMARY KEY,
    garment_number      VARCHAR(30) NOT NULL UNIQUE,
    appointment_id      UUID NOT NULL REFERENCES appointments(id),
    garment_type        VARCHAR(50) NOT NULL,
    description         TEXT,
    color               VARCHAR(100),
    brand               VARCHAR(150),
    size_label          VARCHAR(50),
    status              VARCHAR(50) NOT NULL,
    customer_notes      TEXT,
    internal_notes      TEXT,
    quoted_price        NUMERIC(12, 2),
    final_price         NUMERIC(12, 2),
    received_at         TIMESTAMP,
    ready_for_pickup_at TIMESTAMP,
    picked_up_at        TIMESTAMP,
    completed_at        TIMESTAMP,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT garments_quoted_price_nonneg CHECK (quoted_price IS NULL OR quoted_price >= 0),
    CONSTRAINT garments_final_price_nonneg CHECK (final_price IS NULL OR final_price >= 0)
);

CREATE TABLE garment_status_history (
    id                  UUID PRIMARY KEY,
    garment_id          UUID NOT NULL REFERENCES garments(id),
    previous_status     VARCHAR(50),
    new_status          VARCHAR(50) NOT NULL,
    changed_by_admin_id UUID REFERENCES admin_users(id),
    change_source       VARCHAR(30) NOT NULL,
    note                TEXT,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE alterations (
    id              UUID PRIMARY KEY,
    garment_id      UUID NOT NULL REFERENCES garments(id),
    alteration_type VARCHAR(100) NOT NULL,
    description     TEXT,
    status          VARCHAR(50) NOT NULL,
    quantity        INTEGER NOT NULL DEFAULT 1,
    unit_price      NUMERIC(12, 2),
    total_price     NUMERIC(12, 2),
    internal_notes  TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT alterations_quantity_positive CHECK (quantity > 0)
);

CREATE TABLE measurement_profiles (
    id                      UUID PRIMARY KEY,
    customer_id             UUID NOT NULL REFERENCES customers(id),
    profile_name            VARCHAR(150) NOT NULL,
    measurement_date        DATE NOT NULL,
    unit                    VARCHAR(20) NOT NULL,
    is_current              BOOLEAN NOT NULL DEFAULT FALSE,
    notes                   TEXT,
    measured_by_admin_id    UUID REFERENCES admin_users(id),
    created_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE measurement_values (
    id                      UUID PRIMARY KEY,
    measurement_profile_id  UUID NOT NULL REFERENCES measurement_profiles(id),
    measurement_type        VARCHAR(100) NOT NULL,
    "value"                 NUMERIC(8, 2) NOT NULL,
    note                    VARCHAR(255),
    display_order           INTEGER,
    created_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT measurement_values_unique_type UNIQUE (measurement_profile_id, measurement_type)
);

CREATE TABLE quotes (
    id                  UUID PRIMARY KEY,
    quote_number        VARCHAR(30) NOT NULL UNIQUE,
    appointment_id      UUID NOT NULL REFERENCES appointments(id),
    garment_id          UUID REFERENCES garments(id),
    status              VARCHAR(50) NOT NULL,
    version_number      INTEGER NOT NULL DEFAULT 1,
    currency            CHAR(3) NOT NULL DEFAULT 'USD',
    subtotal            NUMERIC(12, 2) NOT NULL,
    material_fee        NUMERIC(12, 2) NOT NULL DEFAULT 0,
    rush_fee            NUMERIC(12, 2) NOT NULL DEFAULT 0,
    discount_amount     NUMERIC(12, 2) NOT NULL DEFAULT 0,
    tax_amount          NUMERIC(12, 2) NOT NULL DEFAULT 0,
    total_amount        NUMERIC(12, 2) NOT NULL,
    customer_message    TEXT,
    internal_notes      TEXT,
    sent_at             TIMESTAMP,
    expires_at          TIMESTAMP,
    approved_at         TIMESTAMP,
    rejected_at         TIMESTAMP,
    created_by_admin_id UUID NOT NULL REFERENCES admin_users(id),
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE quote_line_items (
    id              UUID PRIMARY KEY,
    quote_id        UUID NOT NULL REFERENCES quotes(id) ON DELETE CASCADE,
    alteration_id   UUID REFERENCES alterations(id),
    description     VARCHAR(255) NOT NULL,
    quantity        NUMERIC(10, 2) NOT NULL DEFAULT 1,
    unit_price      NUMERIC(12, 2) NOT NULL,
    line_total      NUMERIC(12, 2) NOT NULL,
    display_order   INTEGER,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT quote_line_items_quantity_positive CHECK (quantity > 0)
);

CREATE TABLE marketplace_purchases (
    id                              UUID PRIMARY KEY,
    garment_id                      UUID NOT NULL UNIQUE REFERENCES garments(id),
    marketplace_source              VARCHAR(50) NOT NULL,
    listing_url                     TEXT,
    external_listing_id             VARCHAR(255),
    seller_name                     VARCHAR(255),
    listing_title                   VARCHAR(255),
    listed_size                     VARCHAR(50),
    purchase_price                  NUMERIC(12, 2),
    selected_measurement_profile_id UUID REFERENCES measurement_profiles(id),
    customer_fit_concern            TEXT,
    created_at                      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at                      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE file_assets (
    id                      UUID PRIMARY KEY,
    customer_id             UUID REFERENCES customers(id),
    appointment_id          UUID REFERENCES appointments(id),
    garment_id              UUID REFERENCES garments(id),
    marketplace_purchase_id UUID REFERENCES marketplace_purchases(id),
    storage_provider        VARCHAR(50) NOT NULL,
    storage_key             VARCHAR(500) NOT NULL UNIQUE,
    original_file_name      VARCHAR(255) NOT NULL,
    mime_type               VARCHAR(150) NOT NULL,
    file_size_bytes         BIGINT NOT NULL,
    resource_type           VARCHAR(50) NOT NULL,
    access_level            VARCHAR(30) NOT NULL,
    uploaded_by_type        VARCHAR(30) NOT NULL,
    uploaded_by_id          UUID,
    created_at              TIMESTAMP NOT NULL DEFAULT NOW(),
    deleted_at              TIMESTAMP,
    CONSTRAINT file_assets_size_positive CHECK (file_size_bytes > 0)
);

CREATE TABLE communication_logs (
    id                  UUID PRIMARY KEY,
    customer_id         UUID NOT NULL REFERENCES customers(id),
    appointment_id      UUID REFERENCES appointments(id),
    garment_id          UUID REFERENCES garments(id),
    communication_type  VARCHAR(30) NOT NULL,
    direction           VARCHAR(20),
    subject             VARCHAR(255),
    message_summary     TEXT NOT NULL,
    customer_visible    BOOLEAN NOT NULL DEFAULT FALSE,
    external_message_id VARCHAR(255),
    recorded_by_admin_id UUID REFERENCES admin_users(id),
    occurred_at         TIMESTAMP NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE notifications (
    id                  UUID PRIMARY KEY,
    customer_id         UUID NOT NULL REFERENCES customers(id),
    appointment_id      UUID REFERENCES appointments(id),
    garment_id          UUID REFERENCES garments(id),
    quote_id            UUID REFERENCES quotes(id),
    notification_type   VARCHAR(50) NOT NULL,
    channel             VARCHAR(30) NOT NULL,
    recipient_address   VARCHAR(255) NOT NULL,
    subject             VARCHAR(255),
    message_body        TEXT NOT NULL,
    status              VARCHAR(30) NOT NULL,
    scheduled_at        TIMESTAMP,
    sent_at             TIMESTAMP,
    failure_reason      TEXT,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE notification_attempts (
    id                  UUID PRIMARY KEY,
    notification_id     UUID NOT NULL REFERENCES notifications(id) ON DELETE CASCADE,
    attempt_number      INTEGER NOT NULL,
    provider            VARCHAR(50),
    provider_message_id VARCHAR(255),
    status              VARCHAR(30) NOT NULL,
    response_code       VARCHAR(100),
    failure_reason      TEXT,
    attempted_at        TIMESTAMP NOT NULL
);

CREATE TABLE policy_agreements (
    id              UUID PRIMARY KEY,
    appointment_id  UUID NOT NULL REFERENCES appointments(id),
    customer_id     UUID NOT NULL REFERENCES customers(id),
    policy_name     VARCHAR(150) NOT NULL,
    policy_version  VARCHAR(50) NOT NULL,
    agreed          BOOLEAN NOT NULL,
    agreed_at       TIMESTAMP NOT NULL,
    ip_address      VARCHAR(64),
    user_agent      TEXT,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE audit_logs (
    id              UUID PRIMARY KEY,
    actor_admin_id  UUID REFERENCES admin_users(id),
    actor_type      VARCHAR(30) NOT NULL,
    action_type     VARCHAR(100) NOT NULL,
    entity_type     VARCHAR(100) NOT NULL,
    entity_id       UUID,
    before_values   JSON,
    after_values    JSON,
    ip_address      VARCHAR(64),
    correlation_id  VARCHAR(100),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_customers_phone ON customers(phone_number);
CREATE INDEX idx_customers_whatsapp ON customers(whatsapp_number);
CREATE INDEX idx_customers_name ON customers(last_name, first_name);

CREATE INDEX idx_appointments_customer ON appointments(customer_id);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_scheduled_start ON appointments(scheduled_start_at);
CREATE INDEX idx_appointments_created ON appointments(created_at);

CREATE INDEX idx_garments_appointment ON garments(appointment_id);
CREATE INDEX idx_garments_status ON garments(status);

CREATE INDEX idx_measurement_profiles_customer ON measurement_profiles(customer_id);
CREATE INDEX idx_measurement_profiles_customer_date ON measurement_profiles(customer_id, measurement_date DESC);

CREATE INDEX idx_quotes_appointment ON quotes(appointment_id);
CREATE INDEX idx_quotes_garment ON quotes(garment_id);
CREATE INDEX idx_quotes_status ON quotes(status);

CREATE INDEX idx_customer_access_tokens_customer ON customer_access_tokens(customer_id);
CREATE INDEX idx_customer_access_tokens_expires ON customer_access_tokens(expires_at);

CREATE INDEX idx_notifications_status_scheduled ON notifications(status, scheduled_at);
CREATE INDEX idx_notifications_customer ON notifications(customer_id);
CREATE INDEX idx_notifications_appointment ON notifications(appointment_id);

CREATE INDEX idx_communication_logs_customer_occurred ON communication_logs(customer_id, occurred_at DESC);
CREATE INDEX idx_communication_logs_appointment ON communication_logs(appointment_id);
CREATE INDEX idx_communication_logs_garment ON communication_logs(garment_id);

CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_actor ON audit_logs(actor_admin_id);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at DESC);
CREATE INDEX idx_audit_logs_correlation ON audit_logs(correlation_id);
