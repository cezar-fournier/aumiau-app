import os
from pathlib import Path

from scripts.monitor_operations import disk_usage_percent, latest_backup_age_hours


def test_latest_backup_age_uses_newest_directory(tmp_path: Path) -> None:
    older = tmp_path / "older"
    newer = tmp_path / "newer"
    older.mkdir()
    newer.mkdir()
    for directory in (older, newer):
        (directory / "aumiau-postgres.dump").write_bytes(b"dump")
        (directory / "partner-documents.tar.gz").write_bytes(b"docs")
        (directory / "SHA256SUMS").write_text("checksums")
    os.utime(older, (100, 100))
    os.utime(newer, (200, 200))
    assert latest_backup_age_hours(tmp_path, now=3800) == 1.0


def test_latest_backup_age_reports_missing_backup(tmp_path: Path) -> None:
    assert latest_backup_age_hours(tmp_path, now=1000) is None


def test_latest_backup_age_ignores_incomplete_directory(tmp_path: Path) -> None:
    incomplete = tmp_path / "incomplete"
    incomplete.mkdir()
    (incomplete / "aumiau-postgres.dump").write_bytes(b"dump")
    assert latest_backup_age_hours(tmp_path, now=1000) is None


def test_disk_usage_is_a_percentage(tmp_path: Path) -> None:
    value = disk_usage_percent(tmp_path)
    assert 0 <= value <= 100
