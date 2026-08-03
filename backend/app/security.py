from __future__ import annotations

import threading
import time
from collections import defaultdict, deque
from dataclasses import dataclass


@dataclass(frozen=True)
class RateLimitDecision:
    allowed: bool
    retry_after_seconds: int = 0


class InMemoryRateLimiter:
    """Limite simples por processo para proteger rotas sensíveis.

    O controle distribuído deverá usar Redis antes da escala horizontal. Esta
    implementação já fornece proteção previsível para a implantação atual de
    uma instância e mantém a política isolada para troca futura do backend.
    """

    def __init__(self) -> None:
        self._events: dict[str, deque[float]] = defaultdict(deque)
        self._lock = threading.Lock()

    def check(
        self,
        key: str,
        *,
        limit: int,
        window_seconds: int,
        now: float | None = None,
    ) -> RateLimitDecision:
        current = time.monotonic() if now is None else now
        cutoff = current - window_seconds
        with self._lock:
            events = self._events[key]
            while events and events[0] <= cutoff:
                events.popleft()
            if len(events) >= limit:
                retry_after = max(1, int(window_seconds - (current - events[0])))
                return RateLimitDecision(False, retry_after)
            events.append(current)
            return RateLimitDecision(True)


SENSITIVE_RATE_LIMITS: dict[str, tuple[int, int]] = {
    "/auth/login": (10, 60),
    "/auth/mfa/verify": (10, 300),
    "/auth/register": (5, 300),
    "/partner/auth/register": (5, 300),
    "/auth/password-reset/request": (5, 300),
    "/auth/password-reset/confirm": (5, 300),
    "/auth/verify-email": (10, 300),
    "/partner/documents": (20, 300),
    "/partner/prescriptions": (30, 300),
    "/billing/orders": (10, 300),
    "/billing/verify": (10, 300),
    "/admin/mfa/setup": (5, 300),
    "/admin/mfa/activate": (10, 300),
    "/webhooks/mercadopago": (120, 60),
}

SENSITIVE_RATE_LIMIT_PREFIXES: tuple[tuple[str, tuple[int, int]], ...] = (
    ("/partner/appointments/", (60, 60)),
    ("/appointments/", (60, 60)),
    ("/partner/documents/", (60, 60)),
    ("/partner/prescriptions/", (60, 60)),
    ("/prescriptions/", (120, 60)),
    ("/admin/partner-documents/", (120, 60)),
)


def rate_limit_for(path: str) -> tuple[int, int] | None:
    exact_policy = SENSITIVE_RATE_LIMITS.get(path)
    if exact_policy is not None:
        return exact_policy
    for prefix, policy in SENSITIVE_RATE_LIMIT_PREFIXES:
        if path.startswith(prefix):
            return policy
    return None
