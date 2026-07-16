from __future__ import annotations

import argparse
import hashlib
import os
import secrets
from datetime import datetime, timedelta, timezone

import psycopg


def main() -> int:
    parser = argparse.ArgumentParser(description="Gera um token único de recuperação de senha.")
    parser.add_argument("email")
    args = parser.parse_args()
    email = args.email.strip().lower()
    ttl_minutes = int(os.getenv("RESET_TOKEN_TTL_MINUTES", "30"))
    token = secrets.token_urlsafe(48)
    expires_at = datetime.now(timezone.utc) + timedelta(minutes=ttl_minutes)
    token_hash = hashlib.sha256(token.encode()).hexdigest()

    with psycopg.connect(os.environ["DATABASE_URL"]) as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT id, is_active FROM users WHERE email = %s", (email,))
            user = cursor.fetchone()
            if user is None:
                raise SystemExit("Usuário não encontrado.")
            if not user[1]:
                raise SystemExit("Usuário desativado.")
            cursor.execute(
                "UPDATE password_reset_tokens SET used_at = now() WHERE user_id = %s AND used_at IS NULL",
                (user[0],),
            )
            cursor.execute(
                "INSERT INTO password_reset_tokens (user_id, token_hash, expires_at) VALUES (%s, %s, %s)",
                (user[0], token_hash, expires_at),
            )

    print(f"TOKEN={token}")
    print(f"EXPIRES_AT={expires_at.isoformat()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
