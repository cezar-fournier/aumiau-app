from __future__ import annotations

import json
import logging
import re
import sys
import threading
import time
import uuid
from collections import Counter
from datetime import datetime, timezone
from typing import Any


_SAFE_REQUEST_ID = re.compile(r"^[A-Za-z0-9._:-]{8,128}$")
_UUID_SEGMENT = re.compile(
    r"(?i)^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
)


def resolve_request_id(value: str | None) -> str:
    candidate = (value or "").strip()
    if _SAFE_REQUEST_ID.fullmatch(candidate):
        return candidate
    return uuid.uuid4().hex


def normalize_path(path: str) -> str:
    segments = []
    for segment in path.split("/"):
        if segment.isdigit() or _UUID_SEGMENT.fullmatch(segment):
            segments.append(":id")
        else:
            segments.append(segment)
    return "/".join(segments) or "/"


class JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        payload: dict[str, Any] = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
        }
        for key in (
            "request_id",
            "method",
            "path",
            "status_code",
            "duration_ms",
            "client_ip",
            "event",
        ):
            value = getattr(record, key, None)
            if value is not None:
                payload[key] = value
        if record.exc_info:
            payload["exception"] = self.formatException(record.exc_info)
        return json.dumps(payload, ensure_ascii=False, separators=(",", ":"))


def configure_json_logger(name: str) -> logging.Logger:
    configured_logger = logging.getLogger(name)
    if not any(getattr(handler, "_aumiau_json", False) for handler in configured_logger.handlers):
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(JsonFormatter())
        handler._aumiau_json = True  # type: ignore[attr-defined]
        configured_logger.addHandler(handler)
    configured_logger.setLevel(logging.INFO)
    configured_logger.propagate = False
    return configured_logger


class RequestMetrics:
    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._requests: Counter[tuple[str, str, int]] = Counter()
        self._duration_seconds: Counter[tuple[str, str]] = Counter()
        self._in_flight = 0

    def begin(self) -> None:
        with self._lock:
            self._in_flight += 1

    def finish(self, method: str, path: str, status_code: int, duration_seconds: float) -> None:
        normalized_path = normalize_path(path)
        with self._lock:
            self._in_flight = max(0, self._in_flight - 1)
            self._requests[(method, normalized_path, status_code)] += 1
            self._duration_seconds[(method, normalized_path)] += max(0.0, duration_seconds)

    def render_prometheus(self) -> str:
        with self._lock:
            requests = list(self._requests.items())
            durations = list(self._duration_seconds.items())
            in_flight = self._in_flight
        lines = [
            "# HELP aumiau_http_requests_total Total de requisicoes HTTP.",
            "# TYPE aumiau_http_requests_total counter",
        ]
        for (method, path, status_code), value in sorted(requests):
            lines.append(
                f'aumiau_http_requests_total{{method="{method}",path="{path}",status="{status_code}"}} {value}'
            )
        lines.extend(
            [
                "# HELP aumiau_http_request_duration_seconds Soma da duracao das requisicoes HTTP.",
                "# TYPE aumiau_http_request_duration_seconds counter",
            ]
        )
        for (method, path), value in sorted(durations):
            lines.append(
                f'aumiau_http_request_duration_seconds{{method="{method}",path="{path}"}} {value:.6f}'
            )
        lines.extend(
            [
                "# HELP aumiau_http_requests_in_flight Requisicoes HTTP em andamento.",
                "# TYPE aumiau_http_requests_in_flight gauge",
                f"aumiau_http_requests_in_flight {in_flight}",
            ]
        )
        return "\n".join(lines) + "\n"


def monotonic_seconds() -> float:
    return time.perf_counter()
