CREATE TABLE IF NOT EXISTS user_entities (
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    version BIGINT NOT NULL DEFAULT 1,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    payload JSONB,
    changed_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, entity_type, entity_id),
    CHECK (entity_type IN ('pet', 'vaccine', 'weight', 'medication')),
    CHECK ((deleted IS TRUE AND payload IS NULL) OR deleted IS FALSE)
);

CREATE INDEX IF NOT EXISTS user_entities_owner_type_idx
    ON user_entities (user_id, entity_type, updated_at, entity_id);

CREATE TABLE IF NOT EXISTS entity_sync_operations (
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    operation_id BIGINT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    version BIGINT NOT NULL,
    processed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, operation_id)
);
