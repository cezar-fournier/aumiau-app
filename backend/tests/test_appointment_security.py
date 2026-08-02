import pytest

from app.appointment_security import (
    InvalidAppointmentTransition,
    normalize_appointment_status,
    validate_appointment_transition,
)


def test_normalizes_legacy_check_in_alias() -> None:
    assert normalize_appointment_status(" check_in ") == "checked_in"


@pytest.mark.parametrize(
    ("current", "target"),
    [
        ("requested", "cancelled"),
        ("confirmed", "cancelled"),
        ("confirmed", "checked_in"),
        ("confirmed", "check_in"),
    ],
)
def test_client_allowed_transitions(current: str, target: str) -> None:
    assert validate_appointment_transition(current, target, "client") in {
        "cancelled",
        "checked_in",
    }


@pytest.mark.parametrize(
    ("current", "target"),
    [
        ("requested", "confirmed"),
        ("requested", "cancelled"),
        ("confirmed", "completed"),
        ("confirmed", "cancelled"),
        ("checked_in", "completed"),
    ],
)
def test_partner_allowed_transitions(current: str, target: str) -> None:
    assert validate_appointment_transition(current, target, "partner") == target


@pytest.mark.parametrize(
    ("current", "target", "role"),
    [
        ("requested", "confirmed", "client"),
        ("requested", "completed", "client"),
        ("requested", "completed", "partner"),
        ("completed", "requested", "partner"),
        ("cancelled", "confirmed", "partner"),
        ("checked_in", "cancelled", "client"),
    ],
)
def test_rejects_skips_reversals_and_wrong_actor(
    current: str,
    target: str,
    role: str,
) -> None:
    with pytest.raises(InvalidAppointmentTransition):
        validate_appointment_transition(current, target, role)


def test_same_state_is_idempotent() -> None:
    assert validate_appointment_transition("confirmed", "confirmed", "partner") == "confirmed"
