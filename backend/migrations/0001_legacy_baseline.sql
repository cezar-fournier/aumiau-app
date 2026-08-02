-- Transição do inicializador legado para migrações versionadas.
-- Toda nova alteração deve entrar em um novo arquivo imutável nesta pasta.

CREATE INDEX IF NOT EXISTS auth_sessions_user_active_idx
    ON auth_sessions (user_id, refresh_expires_at)
    WHERE revoked_at IS NULL;

CREATE INDEX IF NOT EXISTS billing_orders_user_created_idx
    ON billing_orders (user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS entitlements_status_validity_idx
    ON entitlements (entitlement_key, status, valid_until);

