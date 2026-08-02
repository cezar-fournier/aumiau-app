from __future__ import annotations

import hashlib
from pathlib import Path
from typing import Protocol


MIGRATIONS_DIR = Path(__file__).resolve().parent.parent / "migrations"


class Cursor(Protocol):
    def execute(self, query: str, params: tuple[object, ...] | None = None) -> object: ...

    def fetchall(self) -> list[tuple[object, ...]]: ...


def discover_migrations(directory: Path = MIGRATIONS_DIR) -> list[Path]:
    return sorted(directory.glob("[0-9][0-9][0-9][0-9]_*.sql"))


def migration_checksum(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def apply_migrations(cursor: Cursor, directory: Path = MIGRATIONS_DIR) -> list[str]:
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS schema_migrations (
            version TEXT PRIMARY KEY,
            checksum TEXT NOT NULL,
            applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """
    )
    cursor.execute("SELECT version, checksum FROM schema_migrations ORDER BY version")
    applied = {str(version): str(checksum) for version, checksum in cursor.fetchall()}
    executed: list[str] = []

    for path in discover_migrations(directory):
        version = path.name.split("_", 1)[0]
        checksum = migration_checksum(path)
        if version in applied:
            if applied[version] != checksum:
                raise RuntimeError(f"Migração {version} foi alterada após aplicação.")
            continue
        cursor.execute(path.read_text(encoding="utf-8"))
        cursor.execute(
            "INSERT INTO schema_migrations (version, checksum) VALUES (%s, %s)",
            (version, checksum),
        )
        executed.append(version)

    return executed

