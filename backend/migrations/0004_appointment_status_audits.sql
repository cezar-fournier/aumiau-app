CREATE TABLE IF NOT EXISTS appointment_status_audits (
    id BIGSERIAL PRIMARY KEY,
    appointment_id BIGINT NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
    actor_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    actor_role TEXT NOT NULL,
    previous_status TEXT,
    new_status TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS appointment_status_audits_appointment_idx
    ON appointment_status_audits (appointment_id, created_at DESC);

CREATE INDEX IF NOT EXISTS appointment_status_audits_actor_idx
    ON appointment_status_audits (actor_user_id, created_at DESC);
