import pytest
from pydantic import ValidationError

from app.main import EntityBatch, SyncBatch, app


def test_sync_v2_requires_non_negative_base_revision() -> None:
    payload = {
        "contractVersion": "v2",
        "generatedAt": "2026-08-02T12:00:00Z",
        "baseRevision": -1,
        "snapshot": {"format": "aumiau-backup", "version": 1},
        "operations": [],
    }
    with pytest.raises(ValidationError):
        SyncBatch.model_validate(payload)


def test_sync_routes_offer_push_and_authenticated_restore() -> None:
    methods_by_path: dict[str, set[str]] = {}
    for route in app.routes:
        methods = getattr(route, "methods", None)
        if methods:
            methods_by_path.setdefault(route.path, set()).update(methods)
    assert "POST" in methods_by_path["/sync/batch"]
    assert "GET" in methods_by_path["/sync/snapshot"]
    assert "POST" in methods_by_path["/sync/entities"]
    assert "GET" in methods_by_path["/sync/entities"]


def test_entity_batch_rejects_unsupported_type() -> None:
    with pytest.raises(ValidationError):
        EntityBatch.model_validate(
            {
                "changes": [
                    {
                        "operationId": 1,
                        "entityType": "appointment",
                        "entityId": "2f1ca954-4734-42c6-aa2e-bd516992976d",
                        "baseVersion": 0,
                        "payload": {"name": "Nina"},
                        "changedAt": "2026-08-02T03:00:00Z",
                    }
                ]
            }
        )
