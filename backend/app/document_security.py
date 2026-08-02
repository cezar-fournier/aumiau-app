from __future__ import annotations

import os
import re
from pathlib import PurePath


MAX_DOCUMENT_BYTES = 8 * 1024 * 1024
ALLOWED_DOCUMENT_TYPES = {
    "documento_responsavel",
    "documento_fiscal",
    "registro_crmv",
}
ALLOWED_MIME_EXTENSIONS = {
    "application/pdf": {".pdf"},
    "image/jpeg": {".jpg", ".jpeg"},
    "image/png": {".png"},
}


class InvalidDocument(ValueError):
    pass


def validate_document_type(value: str) -> str:
    normalized = value.strip().lower()
    if normalized not in ALLOWED_DOCUMENT_TYPES:
        raise InvalidDocument("Tipo de documento não permitido.")
    return normalized


def safe_document_name(value: str) -> str:
    candidate = value.strip()
    if not candidate or "\x00" in candidate:
        raise InvalidDocument("Nome de arquivo inválido.")
    if PurePath(candidate).name != candidate or "/" in candidate or "\\" in candidate:
        raise InvalidDocument("Nome de arquivo inválido.")
    sanitized = re.sub(r"[^\w.() -]", "_", candidate, flags=re.UNICODE).strip(" .")
    if not sanitized:
        raise InvalidDocument("Nome de arquivo inválido.")
    return sanitized[:180]


def detect_document_mime(content: bytes) -> str:
    if content.startswith(b"%PDF-"):
        return "application/pdf"
    if content.startswith(b"\xff\xd8\xff"):
        return "image/jpeg"
    if content.startswith(b"\x89PNG\r\n\x1a\n"):
        return "image/png"
    raise InvalidDocument("Formato de arquivo não permitido. Envie PDF, JPEG ou PNG.")


def validate_document(content: bytes, file_name: str, declared_mime: str) -> tuple[str, str]:
    if not content:
        raise InvalidDocument("O documento está vazio.")
    if len(content) > MAX_DOCUMENT_BYTES:
        raise InvalidDocument("O documento deve ter até 8 MB.")
    safe_name = safe_document_name(file_name)
    detected_mime = detect_document_mime(content)
    normalized_declared = declared_mime.strip().lower()
    if normalized_declared not in {"", "application/octet-stream", detected_mime}:
        raise InvalidDocument("O tipo informado não corresponde ao conteúdo do arquivo.")
    extension = os.path.splitext(safe_name)[1].lower()
    if extension not in ALLOWED_MIME_EXTENSIONS[detected_mime]:
        raise InvalidDocument("A extensão do arquivo não corresponde ao conteúdo enviado.")
    return safe_name, detected_mime


def resolve_storage_path(base_directory: str, storage_key: str) -> str:
    base_path = os.path.abspath(base_directory)
    storage_path = os.path.abspath(os.path.join(base_path, storage_key))
    if os.path.commonpath((base_path, storage_path)) != base_path:
        raise InvalidDocument("Caminho de documento inválido.")
    return storage_path
