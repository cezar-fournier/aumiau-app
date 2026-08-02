from app.mfa import (
    decrypt_secret,
    encrypt_secret,
    generate_recovery_codes,
    generate_totp_secret,
    hash_recovery_code,
    provisioning_uri,
    totp_code,
    verify_totp,
)


def test_totp_accepts_current_window_and_rejects_invalid_code() -> None:
    secret = "JBSWY3DPEHPK3PXP"
    code = totp_code(secret, timestamp=1_700_000_000)

    assert verify_totp(secret, code, timestamp=1_700_000_000)
    assert verify_totp(secret, code, timestamp=1_700_000_029)
    assert not verify_totp(secret, "000000", timestamp=1_700_000_000)


def test_secret_encryption_round_trip() -> None:
    secret = generate_totp_secret()
    encrypted = encrypt_secret(secret, "master-secret-for-tests")

    assert secret not in encrypted
    assert decrypt_secret(encrypted, "master-secret-for-tests") == secret


def test_recovery_codes_are_unique_and_hash_normalized() -> None:
    codes = generate_recovery_codes()

    assert len(codes) == 10
    assert len(set(codes)) == 10
    assert hash_recovery_code(codes[0], "master") == hash_recovery_code(
        codes[0].replace("-", "").lower(), "master"
    )


def test_provisioning_uri_contains_issuer_and_account() -> None:
    uri = provisioning_uri("JBSWY3DPEHPK3PXP", "admin@aumiau.app.br")

    assert uri.startswith("otpauth://totp/")
    assert "issuer=AuMiau" in uri
    assert "admin%40aumiau.app.br" in uri
