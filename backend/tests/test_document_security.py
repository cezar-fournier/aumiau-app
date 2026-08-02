import pytest

from app.document_security import (
    InvalidDocument,
    detect_document_mime,
    resolve_storage_path,
    safe_document_name,
    validate_document,
    validate_document_type,
)


def test_accepts_supported_documents_with_matching_extension() -> None:
    assert validate_document(b"%PDF-1.7\n", "registro.pdf", "application/pdf") == (
        "registro.pdf",
        "application/pdf",
    )
    assert detect_document_mime(b"\xff\xd8\xffrestante") == "image/jpeg"
    assert detect_document_mime(b"\x89PNG\r\n\x1a\nrestante") == "image/png"


@pytest.mark.parametrize(
    ("content", "name", "mime"),
    [
        (b"conteudo executavel", "registro.pdf", "application/pdf"),
        (b"%PDF-1.7\n", "registro.exe", "application/pdf"),
        (b"%PDF-1.7\n", "registro.pdf", "image/png"),
        (b"%PDF-1.7\n", "../registro.pdf", "application/pdf"),
    ],
)
def test_rejects_spoofed_or_unsafe_documents(content: bytes, name: str, mime: str) -> None:
    with pytest.raises(InvalidDocument):
        validate_document(content, name, mime)


def test_document_type_is_allowlisted() -> None:
    assert validate_document_type(" REGISTRO_CRMV ") == "registro_crmv"
    with pytest.raises(InvalidDocument):
        validate_document_type("arquivo_livre")


def test_storage_path_cannot_escape_document_root(tmp_path) -> None:
    assert resolve_storage_path(str(tmp_path), "1/documento.pdf").startswith(str(tmp_path))
    with pytest.raises(InvalidDocument):
        resolve_storage_path(str(tmp_path), "../segredo")


def test_file_name_is_reduced_to_a_safe_basename() -> None:
    assert safe_document_name("Meu documento (1).pdf") == "Meu documento (1).pdf"
