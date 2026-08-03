from __future__ import annotations

import hashlib
import hmac
import re
from typing import Any

ALLOWED_TYPES = {"common", "antimicrobial", "special_control", "controlled_notification"}
BLOCKED_ELECTRONIC_TYPES = {"antimicrobial", "special_control", "controlled_notification"}

class InvalidPrescription(ValueError):
    pass

def normalize_prescription_type(value: str) -> str:
    normalized = value.strip().lower()
    if normalized not in ALLOWED_TYPES:
        raise InvalidPrescription("Tipo de receituário não permitido.")
    return normalized

def validate_items(items: list[dict[str, Any]]) -> list[dict[str, str]]:
    if not items:
        raise InvalidPrescription("Inclua pelo menos um medicamento.")
    if len(items) > 20:
        raise InvalidPrescription("O receituário deve conter no máximo 20 medicamentos.")
    cleaned: list[dict[str, str]] = []
    required = ("medication", "concentration", "form", "quantity", "dose", "route", "frequency", "duration")
    for index, item in enumerate(items, start=1):
        normalized = {key: str(item.get(key, "")).strip() for key in required}
        normalized["notes"] = str(item.get("notes", "")).strip()
        if any(not normalized[key] for key in required):
            raise InvalidPrescription(f"O medicamento {index} possui campos obrigatórios não preenchidos.")
        if any(len(value) > 240 for value in normalized.values()):
            raise InvalidPrescription(f"O medicamento {index} possui um campo muito longo.")
        cleaned.append(normalized)
    return cleaned

def validate_crmv(uf: str, number: str) -> tuple[str, str]:
    normalized_uf = uf.strip().upper()
    normalized_number = number.strip().upper()
    if not re.fullmatch(r"[A-Z]{2}", normalized_uf):
        combined = re.fullmatch(
            r"(?:CRMV\s*[-/]?\s*)?([A-Z]{2})\s*[-/]?\s*([0-9][A-Z0-9./-]*)",
            normalized_number,
        )
        if combined:
            normalized_uf, normalized_number = combined.groups()
    if not re.fullmatch(r"[A-Z]{2}", normalized_uf):
        raise InvalidPrescription("Informe a UF válida do CRMV.")
    if not re.fullmatch(r"[A-Z0-9./-]{2,30}", normalized_number):
        raise InvalidPrescription("Informe um número de CRMV válido.")
    return normalized_uf, normalized_number

def ensure_type_can_be_prepared(prescription_type: str) -> None:
    normalized = normalize_prescription_type(prescription_type)
    if normalized in BLOCKED_ELECTRONIC_TYPES:
        raise InvalidPrescription("Este tipo de receituário permanece bloqueado até a integração regulatória e de assinatura digital.")

def verification_token_hash(token: str) -> str:
    return hashlib.sha256(token.encode("utf-8")).hexdigest()

def verify_token(token: str, expected_hash: str) -> bool:
    return hmac.compare_digest(verification_token_hash(token), expected_hash)

def public_validity(status: str, signed_at: object | None) -> tuple[bool, str]:
    if status == "cancelled":
        return False, "cancelled"
    if status == "signed" and signed_at is not None:
        return True, "signed"
    return False, "not_signed"
