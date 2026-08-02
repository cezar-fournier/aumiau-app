from __future__ import annotations

import json
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path
from urllib.error import URLError
from urllib.request import Request, urlopen


def latest_backup_age_hours(root: Path, *, now: float | None = None) -> float | None:
    directories = [entry for entry in root.iterdir() if entry.is_dir()] if root.is_dir() else []
    if not directories:
        return None
    newest = max(entry.stat().st_mtime for entry in directories)
    return max(0.0, ((now or time.time()) - newest) / 3600)


def disk_usage_percent(path: Path) -> float:
    usage = shutil.disk_usage(path)
    return (usage.used / usage.total) * 100 if usage.total else 100.0


def check_http(url: str, timeout: float) -> tuple[bool, str]:
    try:
        with urlopen(url, timeout=timeout) as response:
            body = json.loads(response.read())
            healthy = response.status == 200 and body.get("status") in {"ok", "ready"}
            return healthy, f"HTTP {response.status} status={body.get('status')}"
    except (OSError, URLError, ValueError, json.JSONDecodeError) as error:
        return False, f"{type(error).__name__}: {error}"


def check_container(name: str) -> tuple[bool, str]:
    result = subprocess.run(
        ["docker", "inspect", "--format", "{{.State.Status}} {{if .State.Health}}{{.State.Health.Status}}{{end}}", name],
        capture_output=True,
        check=False,
        text=True,
        timeout=10,
    )
    state = result.stdout.strip()
    healthy = result.returncode == 0 and state in {"running", "running healthy"}
    return healthy, state or result.stderr.strip() or "container não encontrado"


def send_webhook(url: str, payload: dict[str, object]) -> None:
    request = Request(
        url,
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urlopen(request, timeout=10) as response:
        if response.status >= 300:
            raise RuntimeError(f"Webhook retornou HTTP {response.status}")


def main() -> int:
    base_url = os.getenv("AUMIAU_MONITOR_BASE_URL", "https://aumiau.app.br").rstrip("/")
    backup_root = Path(os.getenv("AUMIAU_BACKUP_ROOT", "/var/backups/aumiau"))
    timeout = float(os.getenv("AUMIAU_MONITOR_TIMEOUT_SECONDS", "10"))
    max_backup_age = float(os.getenv("AUMIAU_MAX_BACKUP_AGE_HOURS", "30"))
    max_disk_percent = float(os.getenv("AUMIAU_MAX_DISK_PERCENT", "85"))
    containers = os.getenv(
        "AUMIAU_MONITOR_CONTAINERS",
        "backend-api-1,backend-db-1,backend-caddy-1,aumiau-mailserver",
    ).split(",")

    checks: dict[str, dict[str, object]] = {}
    for endpoint in ("health", "ready"):
        ok, detail = check_http(f"{base_url}/{endpoint}", timeout)
        checks[f"http_{endpoint}"] = {"ok": ok, "detail": detail}

    disk_percent = disk_usage_percent(Path("/"))
    checks["disk"] = {
        "ok": disk_percent < max_disk_percent,
        "detail": f"{disk_percent:.2f}% usado",
    }

    backup_age = latest_backup_age_hours(backup_root)
    checks["backup"] = {
        "ok": backup_age is not None and backup_age <= max_backup_age,
        "detail": "ausente" if backup_age is None else f"{backup_age:.2f} horas",
    }

    for raw_name in containers:
        name = raw_name.strip()
        if not name:
            continue
        ok, detail = check_container(name)
        checks[f"container_{name}"] = {"ok": ok, "detail": detail}

    failures = [name for name, result in checks.items() if not result["ok"]]
    payload: dict[str, object] = {
        "service": "aumiau-operations",
        "status": "ok" if not failures else "alert",
        "failures": failures,
        "checks": checks,
    }
    print(json.dumps(payload, ensure_ascii=False, separators=(",", ":")))

    webhook = os.getenv("AUMIAU_ALERT_WEBHOOK_URL", "").strip()
    if failures and webhook:
        try:
            send_webhook(webhook, payload)
        except Exception as error:
            print(json.dumps({"event": "alert_delivery_failed", "error": str(error)}), file=sys.stderr)
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
