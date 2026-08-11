from app.account_deletion import anonymized_email, delete_account_data
from app.legal_pages import PRIVACY_CONTACT_EMAIL, account_deletion_html


class RecordingCursor:
    def __init__(self) -> None:
        self.calls: list[tuple[str, tuple | None]] = []
        self._rows: list[tuple] = []

    def execute(self, query: str, params: tuple | None = None) -> None:
        self.calls.append((" ".join(query.split()), params))
        if "SELECT id FROM partner_profiles" in query:
            self._rows = [(17,)]
        elif "SELECT storage_key FROM partner_documents" in query:
            self._rows = [("17/document.pdf",)]
        else:
            self._rows = []

    def fetchall(self) -> list[tuple]:
        return self._rows


def test_account_deletion_page_explains_both_request_channels() -> None:
    page = account_deletion_html()
    assert '<html lang="pt-BR">' in page
    assert "Excluir conta AuMiau" in page
    assert "Perfil → Privacidade e dados → Excluir minha conta" in page
    assert "Solicitar exclusão por e-mail" in page
    assert PRIVACY_CONTACT_EMAIL in page
    assert "A exclusão é permanente" in page


def test_anonymized_email_is_unique_and_non_deliverable() -> None:
    first = anonymized_email(42)
    second = anonymized_email(42)
    assert first != second
    assert first.startswith("deleted-42-")
    assert first.endswith("@deleted.invalid")


def test_delete_account_revokes_and_anonymizes_operational_data() -> None:
    cursor = RecordingCursor()
    storage_keys = delete_account_data(cursor, user_id=42, password_hash="random-hash")
    statements = "\n".join(query for query, _ in cursor.calls)
    assert storage_keys == ["17/document.pdf"]
    assert "UPDATE auth_sessions SET revoked_at" in statements
    assert "DELETE FROM user_entities" in statements
    assert "DELETE FROM user_addresses" in statements
    assert "DELETE FROM partner_documents" in statements
    assert "UPDATE partner_profiles" in statements
    assert "is_active = FALSE" in statements
    assert "deleted_at = now()" in statements
