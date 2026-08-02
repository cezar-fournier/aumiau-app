from __future__ import annotations

import base64
import hashlib
import hmac
import secrets
import struct
import time
from urllib.parse import quote

from cryptography.fernet import Fernet


def generate_totp_secret() -> str:
    return base64.b32encode(secrets.token_bytes(20)).decode().rstrip("=")


def _decode_secret(secret: str) -> bytes:
    padding = "=" * ((8 - len(secret) % 8) % 8)
    return base64.b32decode(secret.upper() + padding)


def totp_code(secret: str, *, timestamp: int | None = None, step: int = 30) -> str:
    current = int(time.time() if timestamp is None else timestamp) // step
    digest = hmac.new(_decode_secret(secret), struct.pack(">Q", current), hashlib.sha1).digest()
    offset = digest[-1] & 0x0F
    value = struct.unpack(">I", digest[offset : offset + 4])[0] & 0x7FFFFFFF
    return f"{value % 1_000_000:06d}"


def verify_totp(secret: str, code: str, *, timestamp: int | None = None) -> bool:
    normalized = "".join(character for character in code if character.isdigit())
    if len(normalized) != 6:
        return False
    now = int(time.time() if timestamp is None else timestamp)
    return any(
        hmac.compare_digest(totp_code(secret, timestamp=now + offset), normalized)
        for offset in (-30, 0, 30)
    )


def provisioning_uri(secret: str, email: str, *, issuer: str = "AuMiau") -> str:
    label = quote(f"{issuer}:{email}")
    return f"otpauth://totp/{label}?secret={secret}&issuer={quote(issuer)}&algorithm=SHA1&digits=6&period=30"


def _fernet(master_secret: str) -> Fernet:
    key = base64.urlsafe_b64encode(hashlib.sha256(master_secret.encode()).digest())
    return Fernet(key)


def encrypt_secret(secret: str, master_secret: str) -> str:
    return _fernet(master_secret).encrypt(secret.encode()).decode()


def decrypt_secret(encrypted_secret: str, master_secret: str) -> str:
    return _fernet(master_secret).decrypt(encrypted_secret.encode()).decode()


def generate_recovery_codes(count: int = 10) -> list[str]:
    codes: list[str] = []
    for _ in range(count):
        raw = secrets.token_hex(8).upper()
        codes.append("-".join(raw[index : index + 4] for index in range(0, 16, 4)))
    return codes


def hash_recovery_code(code: str, master_secret: str) -> str:
    normalized = code.replace("-", "").strip().upper()
    return hmac.new(master_secret.encode(), normalized.encode(), hashlib.sha256).hexdigest()
