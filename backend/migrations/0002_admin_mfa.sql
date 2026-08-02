ALTER TABLE users
    ADD COLUMN IF NOT EXISTS mfa_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS mfa_secret_encrypted TEXT,
    ADD COLUMN IF NOT EXISTS mfa_pending_secret_encrypted TEXT;

ALTER TABLE auth_sessions
    ADD COLUMN IF NOT EXISTS mfa_verified BOOLEAN NOT NULL DEFAULT FALSE;

CREATE TABLE IF NOT EXISTS admin_mfa_recovery_codes (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    code_hash TEXT NOT NULL,
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, code_hash)
);

CREATE TABLE IF NOT EXISTS admin_mfa_challenges (
    jti TEXT PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at TIMESTAMPTZ NOT NULL,
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS admin_mfa_challenges_expiry_idx
    ON admin_mfa_challenges (expires_at)
    WHERE used_at IS NULL;
