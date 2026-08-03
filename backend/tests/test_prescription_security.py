import pytest
from app.prescription_security import InvalidPrescription, ensure_type_can_be_prepared, normalize_prescription_type, public_validity, validate_crmv, validate_items, verification_token_hash, verify_token

def test_common_prescription_can_be_prepared_but_controlled_types_are_blocked() -> None:
    ensure_type_can_be_prepared(" common ")
    for kind in ("antimicrobial", "special_control", "controlled_notification"):
        with pytest.raises(InvalidPrescription):
            ensure_type_can_be_prepared(kind)

def test_prescription_type_and_crmv_are_normalized() -> None:
    assert normalize_prescription_type(" Common ") == "common"
    assert validate_crmv("am", "1234-A") == ("AM", "1234-A")
    assert validate_crmv("", "CRMV-AM 1234") == ("AM", "1234")
    with pytest.raises(InvalidPrescription):
        validate_crmv("Amazonas", "1234")

def test_items_require_complete_directions() -> None:
    item = {"medication": "Medicamento teste", "concentration": "10 mg", "form": "Comprimido", "quantity": "10 unidades", "dose": "1 comprimido", "route": "Oral", "frequency": "A cada 12 horas", "duration": "5 dias", "notes": "Após alimentação"}
    assert validate_items([item])[0]["route"] == "Oral"
    item["dose"] = ""
    with pytest.raises(InvalidPrescription):
        validate_items([item])

def test_verification_token_and_public_validity() -> None:
    digest = verification_token_hash("segredo")
    assert verify_token("segredo", digest)
    assert not verify_token("outro", digest)
    assert public_validity("ready_for_signature", None) == (False, "not_signed")
    assert public_validity("signed", object()) == (True, "signed")
    assert public_validity("cancelled", object()) == (False, "cancelled")
