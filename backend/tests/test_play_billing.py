from datetime import datetime, timedelta, timezone

import pytest

from app.play_billing import (
    GooglePlayConfigurationError,
    GooglePlayClient,
    GooglePlayVerificationError,
    parse_subscription,
)


def payload(*, state: str = "SUBSCRIPTION_STATE_ACTIVE", product: str = "family_monthly"):
    return {
        "subscriptionState": state,
        "acknowledgementState": "ACKNOWLEDGEMENT_STATE_PENDING",
        "latestOrderId": "GPA.1234-5678",
        "startTime": "2026-08-02T10:00:00Z",
        "lineItems": [
            {
                "productId": product,
                "expiryTime": (datetime.now(timezone.utc) + timedelta(days=30)).isoformat(),
                "autoRenewingPlan": {"autoRenewEnabled": True},
            }
        ],
    }


def test_active_subscription_grants_entitlement():
    subscription = parse_subscription(payload(), "family_monthly")

    assert subscription.grants_entitlement is True
    assert subscription.auto_renew is True
    assert subscription.acknowledged is False


@pytest.mark.parametrize(
    "state",
    [
        "SUBSCRIPTION_STATE_PENDING",
        "SUBSCRIPTION_STATE_PAUSED",
        "SUBSCRIPTION_STATE_ON_HOLD",
        "SUBSCRIPTION_STATE_EXPIRED",
    ],
)
def test_non_active_states_do_not_grant_entitlement(state):
    assert parse_subscription(payload(state=state), "family_monthly").grants_entitlement is False


def test_product_mismatch_is_rejected():
    with pytest.raises(GooglePlayVerificationError):
        parse_subscription(payload(product="another_product"), "family_monthly")


def test_canceled_subscription_remains_active_until_expiry():
    subscription = parse_subscription(
        payload(state="SUBSCRIPTION_STATE_CANCELED"),
        "family_monthly",
    )

    assert subscription.grants_entitlement is True
    assert subscription.auto_renew is True


def test_expired_subscription_never_grants_entitlement():
    expired = payload()
    expired["lineItems"][0]["expiryTime"] = (
        datetime.now(timezone.utc) - timedelta(seconds=1)
    ).isoformat()

    assert parse_subscription(expired, "family_monthly").grants_entitlement is False


def test_missing_line_items_are_rejected():
    with pytest.raises(GooglePlayVerificationError):
        parse_subscription({"lineItems": []}, "family_monthly")


def test_client_requires_package_and_service_account_file():
    with pytest.raises(GooglePlayConfigurationError):
        GooglePlayClient(package_name="", service_account_file="")


def test_google_auth_requests_transport_is_available():
    from google.auth.transport.requests import Request

    assert Request is not None
