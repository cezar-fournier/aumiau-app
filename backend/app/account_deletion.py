from __future__ import annotations

import uuid
from typing import Any


def anonymized_email(user_id: int) -> str:
    return f"deleted-{user_id}-{uuid.uuid4().hex}@deleted.invalid"


def delete_account_data(cursor: Any, *, user_id: int, password_hash: str) -> list[str]:
    """Remove dados operacionais e anonimiza referências que precisam ser conservadas."""
    cursor.execute("SELECT id FROM partner_profiles WHERE owner_user_id = %s", (user_id,))
    partner_ids = [row[0] for row in cursor.fetchall()]

    cursor.execute(
        """UPDATE appointments
           SET pet_ref = %s, pet_name = 'Pet excluído', notes = '', updated_at = now()
           WHERE user_id = %s""",
        (f"deleted-user-{user_id}", user_id),
    )

    for table in (
        "user_snapshots", "user_entities", "entity_sync_operations",
        "sync_operations", "sync_batches", "user_addresses",
        "private_veterinary_contacts", "password_reset_tokens",
        "email_verification_tokens", "admin_mfa_challenges",
        "admin_mfa_recovery_codes", "user_roles",
    ):
        cursor.execute(f"DELETE FROM {table} WHERE user_id = %s", (user_id,))

    cursor.execute(
        "DELETE FROM family_access_grants WHERE owner_user_id = %s OR member_user_id = %s",
        (user_id, user_id),
    )
    cursor.execute(
        "DELETE FROM family_invitations WHERE owner_user_id = %s OR accepted_by_user_id = %s",
        (user_id, user_id),
    )
    cursor.execute(
        "UPDATE entitlements SET status = 'revoked', valid_until = now(), updated_at = now() WHERE user_id = %s",
        (user_id,),
    )
    cursor.execute(
        "UPDATE subscriptions SET status = 'cancelled', expires_at = LEAST(COALESCE(expires_at, now()), now()), updated_at = now() WHERE user_id = %s",
        (user_id,),
    )
    cursor.execute(
        "UPDATE auth_sessions SET revoked_at = COALESCE(revoked_at, now()) WHERE user_id = %s",
        (user_id,),
    )

    document_storage_keys: list[str] = []
    for partner_id in partner_ids:
        cursor.execute(
            "SELECT storage_key FROM partner_documents WHERE partner_id = %s",
            (partner_id,),
        )
        document_storage_keys.extend(row[0] for row in cursor.fetchall())
        cursor.execute("DELETE FROM partner_documents WHERE partner_id = %s", (partner_id,))
        cursor.execute(
            """UPDATE partner_professionals
               SET full_name = 'Profissional excluído', cpf = '', crmv_uf = '',
                   crmv_number = '', art_number = '', is_responsible_technical = FALSE,
                   verification_status = 'deleted', updated_at = now()
               WHERE partner_id = %s""",
            (partner_id,),
        )
        cursor.execute(
            """UPDATE partner_profiles
               SET owner_user_id = NULL, name = 'Parceiro excluído', cnpj = '', phone = '',
                   whatsapp = '', email = '', address = '', postal_code = '', city = '', state = '',
                   latitude = NULL, longitude = NULL, services = '[]'::jsonb,
                   accepts_urgency = FALSE, status = 'deleted', verification_status = 'deleted',
                   updated_at = now()
               WHERE id = %s""",
            (partner_id,),
        )

    cursor.execute(
        """UPDATE users
           SET email = %s, password_hash = %s, full_name = '', phone = '', birth_date = NULL,
               edition = 'deleted', plan_code = 'deleted', account_type = 'deleted',
               is_active = FALSE, email_verified = FALSE, deleted_at = now()
           WHERE id = %s""",
        (anonymized_email(user_id), password_hash, user_id),
    )
    return document_storage_keys
