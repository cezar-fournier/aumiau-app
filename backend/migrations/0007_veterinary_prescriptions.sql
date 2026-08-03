CREATE TABLE IF NOT EXISTS veterinary_prescriptions (
    id BIGSERIAL PRIMARY KEY,
    appointment_id BIGINT NOT NULL REFERENCES appointments(id) ON DELETE RESTRICT,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    partner_id BIGINT NOT NULL REFERENCES partner_profiles(id) ON DELETE RESTRICT,
    professional_id BIGINT REFERENCES partner_professionals(id) ON DELETE RESTRICT,
    public_id UUID NOT NULL UNIQUE,
    verification_token_hash TEXT NOT NULL,
    prescription_type TEXT NOT NULL DEFAULT 'common'
        CHECK (prescription_type IN ('common', 'antimicrobial', 'special_control', 'controlled_notification')),
    status TEXT NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'ready_for_signature', 'signed', 'cancelled')),
    version INTEGER NOT NULL DEFAULT 1 CHECK (version > 0),
    patient_snapshot JSONB NOT NULL,
    owner_snapshot JSONB NOT NULL,
    prescriber_snapshot JSONB NOT NULL,
    items JSONB NOT NULL DEFAULT '[]'::JSONB,
    instructions TEXT NOT NULL DEFAULT '',
    pdf_storage_key TEXT,
    pdf_sha256 TEXT,
    signature_provider TEXT,
    signature_reference TEXT,
    signed_at TIMESTAMPTZ,
    prepared_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    cancellation_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS veterinary_prescriptions_appointment_active_idx
    ON veterinary_prescriptions (appointment_id)
    WHERE status <> 'cancelled';

CREATE INDEX IF NOT EXISTS veterinary_prescriptions_owner_idx
    ON veterinary_prescriptions (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS veterinary_prescriptions_partner_idx
    ON veterinary_prescriptions (partner_id, created_at DESC);

CREATE TABLE IF NOT EXISTS veterinary_prescription_versions (
    prescription_id BIGINT NOT NULL REFERENCES veterinary_prescriptions(id) ON DELETE RESTRICT,
    version INTEGER NOT NULL,
    patient_snapshot JSONB NOT NULL,
    owner_snapshot JSONB NOT NULL,
    prescriber_snapshot JSONB NOT NULL,
    items JSONB NOT NULL,
    instructions TEXT NOT NULL DEFAULT '',
    created_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (prescription_id, version)
);

CREATE TABLE IF NOT EXISTS veterinary_prescription_audits (
    id BIGSERIAL PRIMARY KEY,
    prescription_id BIGINT NOT NULL REFERENCES veterinary_prescriptions(id) ON DELETE RESTRICT,
    actor_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    previous_status TEXT,
    new_status TEXT,
    metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS veterinary_prescription_audits_prescription_idx
    ON veterinary_prescription_audits (prescription_id, created_at DESC);
