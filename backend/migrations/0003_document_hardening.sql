CREATE TABLE IF NOT EXISTS partner_document_access_audits (
    id BIGSERIAL PRIMARY KEY,
    document_id BIGINT NOT NULL REFERENCES partner_documents(id) ON DELETE CASCADE,
    partner_id BIGINT NOT NULL REFERENCES partner_profiles(id) ON DELETE CASCADE,
    actor_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    action TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS partner_document_access_audits_document_idx
    ON partner_document_access_audits (document_id, created_at DESC);

CREATE INDEX IF NOT EXISTS partner_document_access_audits_actor_idx
    ON partner_document_access_audits (actor_user_id, created_at DESC);

CREATE UNIQUE INDEX IF NOT EXISTS partner_documents_storage_key_idx
    ON partner_documents (storage_key);
