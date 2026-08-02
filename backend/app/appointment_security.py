from __future__ import annotations


class InvalidAppointmentTransition(ValueError):
    pass


_ALIASES = {"check_in": "checked_in"}

_TRANSITIONS = {
    "client": {
        "requested": {"cancelled"},
        "confirmed": {"cancelled", "checked_in"},
        "cancelled": set(),
        "checked_in": set(),
        "completed": set(),
    },
    "partner": {
        "requested": {"confirmed", "cancelled"},
        "confirmed": {"cancelled", "completed"},
        "cancelled": set(),
        "checked_in": {"completed"},
        "completed": set(),
    },
}


def normalize_appointment_status(value: str) -> str:
    normalized = value.strip().lower()
    return _ALIASES.get(normalized, normalized)


def validate_appointment_transition(current: str, requested: str, actor_role: str) -> str:
    current_status = normalize_appointment_status(current)
    target_status = normalize_appointment_status(requested)
    transitions = _TRANSITIONS.get(actor_role)
    if transitions is None or current_status not in transitions:
        raise InvalidAppointmentTransition("Estado atual ou perfil de acesso inválido.")
    if target_status == current_status:
        return target_status
    if target_status not in transitions[current_status]:
        raise InvalidAppointmentTransition(
            f"Transição de {current_status} para {target_status} não permitida para {actor_role}."
        )
    return target_status
