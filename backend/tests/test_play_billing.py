from datetime import datetime, timedelta, timezone

import pytest

from app.play_billing import GooglePlayVerificationError, parse_subscription


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
