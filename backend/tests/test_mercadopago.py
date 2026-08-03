import hashlib
import hmac

import app.main as main


def test_notification_url_is_added_when_configured(monkeypatch) -> None:
    monkeypatch.setattr(
        main,
        "MERCADOPAGO_NOTIFICATION_URL",
        "https://aumiau.app.br/webhooks/mercadopago",
    )

    assert main._mercadopago_notification_fields() == {
        "notification_url": "https://aumiau.app.br/webhooks/mercadopago"
    }


def test_processed_order_and_payment_are_recognized_as_paid() -> None:
    assert main._is_mercadopago_order_paid({"status": "processed"})
    assert main._is_mercadopago_order_paid(
        {
            "status": "action_required",
            "transactions": {"payments": [{"status": "approved"}]},
        }
    )
    assert not main._is_mercadopago_order_paid(
        {
            "status": "action_required",
            "transactions": {"payments": [{"status": "waiting_transfer"}]},
        }
    )


def test_webhook_signature_validation() -> None:
    secret = "webhook-test-secret"
    data_id = "ORD-123"
    request_id = "request-456"
    timestamp = "1700000000"
    manifest = f"id:{data_id};request-id:{request_id};ts:{timestamp};"
    digest = hmac.new(secret.encode(), manifest.encode(), hashlib.sha256).hexdigest()

    original = main.MERCADOPAGO_WEBHOOK_SECRET
    main.MERCADOPAGO_WEBHOOK_SECRET = secret
    try:
        assert main.validate_mercadopago_signature(
            f"ts={timestamp},v1={digest}", request_id, data_id
        )
        assert not main.validate_mercadopago_signature(
            f"ts={timestamp},v1=invalid", request_id, data_id
        )
    finally:
        main.MERCADOPAGO_WEBHOOK_SECRET = original
