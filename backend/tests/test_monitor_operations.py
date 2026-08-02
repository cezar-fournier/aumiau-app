import os
from pathlib import Path

from scripts.monitor_operations import disk_usage_percent, latest_backup_age_hours


def test_latest_backup_age_uses_newest_directory(tmp_path: Path) -> None:
    older = tmp_path / "older"
    newer = tmp_path / "newer"
    older.mkdir()
    newer.mkdir()
    os.utime(older, (100, 100))
    os.utime(newer, (200, 200))
    assert latest_backup_age_hours(tmp_path, now=3800) == 1.0


def test_latest_backup_age_reports_missing_backup(tmp_path: Path) -> None:
    assert latest_backup_age_hours(tmp_path, now=1000) is None


def test_disk_usage_is_a_percentage(tmp_path: Path) -> None:
    value = disk_usage_percent(tmp_path)
    assert 0 <= value <= 100
