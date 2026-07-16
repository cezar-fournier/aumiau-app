from __future__ import annotations

import argparse
import getpass
import os
import sys

import bcrypt
import psycopg


def main() -> int:
    parser = argparse.ArgumentParser(description="Cria uma conta AuMiau sem expor a senha.")
    parser.add_argument("email")
    args = parser.parse_args()
    email = args.email.strip().lower()
    password = getpass.getpass("Senha da conta: ")
    if len(password) < 8:
        print("A senha precisa ter pelo menos 8 caracteres.", file=sys.stderr)
        return 2

    database_url = os.environ["DATABASE_URL"]
    password_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
    with psycopg.connect(database_url) as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1 FROM users WHERE email = %s", (email,))
            if cursor.fetchone() is not None:
                print("A conta já existe.", file=sys.stderr)
                return 3
            cursor.execute(
                "INSERT INTO users (email, password_hash) VALUES (%s, %s)",
                (email, password_hash),
            )
    print(f"Conta criada: {email}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
