from app.security import InMemoryRateLimiter, rate_limit_for


def test_rate_limiter_blocks_and_recovers_after_window() -> None:
    limiter = InMemoryRateLimiter()

    assert limiter.check("login:127.0.0.1", limit=2, window_seconds=60, now=100).allowed
    assert limiter.check("login:127.0.0.1", limit=2, window_seconds=60, now=101).allowed

    blocked = limiter.check("login:127.0.0.1", limit=2, window_seconds=60, now=102)
    assert not blocked.allowed
    assert blocked.retry_after_seconds > 0

    assert limiter.check("login:127.0.0.1", limit=2, window_seconds=60, now=161).allowed


def test_sensitive_routes_have_explicit_policy() -> None:
    assert rate_limit_for("/auth/login") == (10, 60)
    assert rate_limit_for("/auth/password-reset/request") == (5, 300)
    assert rate_limit_for("/auth/mfa/verify") == (10, 300)
    assert rate_limit_for("/partner/documents/42/content") == (60, 60)
    assert rate_limit_for("/admin/partner-documents/42/content") == (120, 60)
    assert rate_limit_for("/appointments/42/status") == (60, 60)
    assert rate_limit_for("/partner/appointments/42/status") == (60, 60)
    assert rate_limit_for("/health") is None
