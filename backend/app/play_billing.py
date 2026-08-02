from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import quote
from urllib.request import Request, urlopen


ACTIVE_SUBSCRIPTION_STATES = {
    "SUBSCRIPTION_STATE_ACTIVE",
    "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
    "SUBSCRIPTION_STATE_CANCELED",
}


class GooglePlayConfigurationError(RuntimeError):
    pass


class GooglePlayVerificationError(RuntimeError):
    pass


@dataclass(frozen=True)
class GooglePlaySubscription:
    product_id: str
    state: str
    order_id: str | None
    started_at: datetime | None
    expires_at: datetime | None
    auto_renew: bool
    acknowledged: bool
    linked_purchase_token: str | None

    @property
    def grants_entitlement(self) -> bool:
        return (
            self.state in ACTIVE_SUBSCRIPTION_STATES
            and self.expires_at is not None
            and self.expires_at > datetime.now(timezone.utc)
        )


def _parse_datetime(value: object) -> datetime | None:
    if not isinstance(value, str) or not value:
        return None
    parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    return parsed if parsed.tzinfo else parsed.replace(tzinfo=timezone.utc)


def parse_subscription(payload: dict[str, Any], expected_product_id: str) -> GooglePlaySubscription:
    line_items = payload.get("lineItems")
    if not isinstance(line_items, list) or not line_items:
        raise GooglePlayVerificationError("A assinatura não possui itens válidos.")
    matching = [item for item in line_items if isinstance(item, dict) and item.get("productId") == expected_product_id]
    if not matching:
        raise GooglePlayVerificationError("O token não pertence ao produto informado.")
    selected = max(matching, key=lambda item: str(item.get("expiryTime") or ""))
    auto_renewing = selected.get("autoRenewingPlan")
    return GooglePlaySubscription(
        product_id=expected_product_id,
        state=str(payload.get("subscriptionState") or "SUBSCRIPTION_STATE_UNSPECIFIED"),
        order_id=payload.get("latestOrderId") if isinstance(payload.get("latestOrderId"), str) else None,
        started_at=_parse_datetime(payload.get("startTime")),
        expires_at=_parse_datetime(selected.get("expiryTime")),
        auto_renew=isinstance(auto_renewing, dict) and bool(auto_renewing.get("autoRenewEnabled")),
        acknowledged=payload.get("acknowledgementState") == "ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED",
        linked_purchase_token=(
            payload.get("linkedPurchaseToken")
            if isinstance(payload.get("linkedPurchaseToken"), str)
            else None
        ),
    )


class GooglePlayClient:
    def __init__(self, *, package_name: str, service_account_file: str):
        if not package_name or not service_account_file:
            raise GooglePlayConfigurationError("Google Play Billing não configurado no servidor.")
        self.package_name = package_name
        self.service_account_file = service_account_file

    def _access_token(self) -> str:
        try:
            from google.auth.transport.requests import Request as GoogleAuthRequest
            from google.oauth2 import service_account
        except ImportError as error:
            raise GooglePlayConfigurationError("Dependência google-auth ausente.") from error
        credentials = service_account.Credentials.from_service_account_file(
            self.service_account_file,
            scopes=["https://www.googleapis.com/auth/androidpublisher"],
        )
        credentials.refresh(GoogleAuthRequest())
        if not credentials.token:
            raise GooglePlayConfigurationError("Não foi possível autenticar no Google Play.")
        return credentials.token

    def _request(self, method: str, url: str, *, body: dict[str, Any] | None = None) -> dict[str, Any]:
        encoded = None if body is None else json.dumps(body).encode()
        request = Request(
            url,
            data=encoded,
            method=method,
            headers={
                "Authorization": f"Bearer {self._access_token()}",
                "Content-Type": "application/json",
            },
        )
        try:
            with urlopen(request, timeout=20) as response:
                raw = response.read()
                return json.loads(raw) if raw else {}
        except HTTPError as error:
            detail = error.read().decode(errors="replace")[:500]
            raise GooglePlayVerificationError(f"Google Play retornou HTTP {error.code}: {detail}") from error
        except (URLError, OSError, ValueError, json.JSONDecodeError) as error:
            raise GooglePlayVerificationError("Falha ao consultar o Google Play.") from error

    def verify_subscription(self, *, product_id: str, purchase_token: str) -> GooglePlaySubscription:
        package = quote(self.package_name, safe="")
        token = quote(purchase_token, safe="")
        payload = self._request(
            "GET",
            f"https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{package}/purchases/subscriptionsv2/tokens/{token}",
        )
        return parse_subscription(payload, product_id)

    def acknowledge(self, *, product_id: str, purchase_token: str) -> None:
        package = quote(self.package_name, safe="")
        product = quote(product_id, safe="")
        token = quote(purchase_token, safe="")
        self._request(
            "POST",
            f"https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{package}/purchases/subscriptions/{product}/tokens/{token}:acknowledge",
            body={},
        )
