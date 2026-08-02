ALTER TABLE user_snapshots
    ADD COLUMN IF NOT EXISTS revision BIGINT NOT NULL DEFAULT 1;

ALTER TABLE user_snapshots
    ADD COLUMN IF NOT EXISTS generated_at TIMESTAMPTZ NOT NULL DEFAULT now();

CREATE INDEX IF NOT EXISTS user_snapshots_updated_idx
    ON user_snapshots (updated_at DESC);
