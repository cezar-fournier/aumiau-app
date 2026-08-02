from pathlib import Path

import pytest

from app.migrations import apply_migrations, discover_migrations


class FakeCursor:
    def __init__(self, applied: list[tuple[str, str]] | None = None) -> None:
        self.applied = applied or []
        self.queries: list[tuple[str, tuple[object, ...] | None]] = []

    def execute(self, query: str, params: tuple[object, ...] | None = None) -> None:
        self.queries.append((query, params))

    def fetchall(self) -> list[tuple[object, ...]]:
        return list(self.applied)


def test_migrations_are_discovered_in_version_order(tmp_path: Path) -> None:
    (tmp_path / "0002_second.sql").write_text("SELECT 2;", encoding="utf-8")
    (tmp_path / "0001_first.sql").write_text("SELECT 1;", encoding="utf-8")
    assert [path.name for path in discover_migrations(tmp_path)] == [
        "0001_first.sql",
        "0002_second.sql",
    ]


def test_applies_each_pending_migration_once(tmp_path: Path) -> None:
    (tmp_path / "0001_first.sql").write_text("SELECT 1;", encoding="utf-8")
    cursor = FakeCursor()
    assert apply_migrations(cursor, tmp_path) == ["0001"]
    assert any(query == "SELECT 1;" for query, _ in cursor.queries)
    assert any(params and params[0] == "0001" for _, params in cursor.queries)


def test_rejects_changed_applied_migration(tmp_path: Path) -> None:
    (tmp_path / "0001_first.sql").write_text("SELECT 1;", encoding="utf-8")
    cursor = FakeCursor(applied=[("0001", "checksum-invalido")])
    with pytest.raises(RuntimeError, match="alterada após aplicação"):
        apply_migrations(cursor, tmp_path)

