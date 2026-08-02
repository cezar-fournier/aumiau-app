import json
import logging

from app.observability import JsonFormatter, RequestMetrics, normalize_path, resolve_request_id


def test_request_id_preserves_safe_value_and_rejects_unsafe_value() -> None:
    assert resolve_request_id("mobile-12345678") == "mobile-12345678"
    generated = resolve_request_id("valor com espaço")
    assert len(generated) == 32
    assert generated.isalnum()


def test_path_normalization_limits_metric_cardinality() -> None:
    assert normalize_path("/appointments/42/status") == "/appointments/:id/status"
    assert (
        normalize_path("/sync/entities/7f67515c-b8e0-4b09-8b3c-fb777ca5f539")
        == "/sync/entities/:id"
    )


def test_json_formatter_emits_correlation_fields() -> None:
    record = logging.LogRecord("aumiau.api", logging.INFO, __file__, 1, "request_completed", (), None)
    record.request_id = "request-12345678"
    record.status_code = 200
    payload = json.loads(JsonFormatter().format(record))
    assert payload["message"] == "request_completed"
    assert payload["request_id"] == "request-12345678"
    assert payload["status_code"] == 200


def test_request_metrics_renders_prometheus_without_raw_ids() -> None:
    metrics = RequestMetrics()
    metrics.begin()
    metrics.finish("GET", "/appointments/42/status", 200, 0.125)
    rendered = metrics.render_prometheus()
    assert 'path="/appointments/:id/status"' in rendered
    assert "/appointments/42/status" not in rendered
    assert 'status="200"} 1' in rendered
    assert "aumiau_http_requests_in_flight 0" in rendered
