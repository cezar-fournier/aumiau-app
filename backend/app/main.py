from __future__ import annotations

import base64
import os
import hashlib
import hmac
import html
import json
import math
import secrets
import smtplib
import time
import uuid
from datetime import datetime, timedelta, timezone
from email.message import EmailMessage
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.request import Request as UrlRequest, urlopen

import bcrypt
import jwt
import psycopg
from fastapi import Depends, FastAPI, Header, HTTPException, Query, Request, status
from fastapi.responses import FileResponse, HTMLResponse, JSONResponse, PlainTextResponse, Response
from pydantic import BaseModel, Field

from app.admin_panel import ADMIN_HTML
from app.appointment_security import (
    InvalidAppointmentTransition,
    validate_appointment_transition,
)
from app.document_security import (
    InvalidDocument,
    detect_document_mime,
    resolve_storage_path,
    safe_document_name,
    validate_document,
    validate_document_type,
)
from app.mfa import (
    decrypt_secret,
    encrypt_secret,
    generate_recovery_codes,
    generate_totp_secret,
    hash_recovery_code,
    provisioning_uri,
    verify_totp,
)
from app.migrations import apply_migrations
from app.account_deletion import delete_account_data
from app.legal_pages import account_deletion_html, privacy_policy_html
from app.observability import RequestMetrics, configure_json_logger, monotonic_seconds, resolve_request_id
from app.play_billing import (
    GooglePlayClient,
    GooglePlayConfigurationError,
    GooglePlayVerificationError,
)
from app.prescription_pdf import generate_prescription_pdf
from app.prescription_security import (
    InvalidPrescription,
    ensure_type_can_be_prepared,
    normalize_prescription_type,
    public_validity,
    validate_crmv,
    validate_items,
    verification_token_hash,
    verify_token,
)
from app.security import InMemoryRateLimiter, rate_limit_for


DATABASE_URL = os.environ["DATABASE_URL"]
JWT_SECRET = os.environ["JWT_SECRET"]
JWT_ALGORITHM = "HS256"
TOKEN_TTL_HOURS = int(os.getenv("TOKEN_TTL_HOURS", "24"))
REFRESH_TTL_DAYS = int(os.getenv("REFRESH_TTL_DAYS", "30"))
RESET_TOKEN_TTL_MINUTES = int(os.getenv("RESET_TOKEN_TTL_MINUTES", "30"))
EMAIL_VERIFICATION_TTL_HOURS = int(os.getenv("EMAIL_VERIFICATION_TTL_HOURS", "24"))
REQUIRE_EMAIL_VERIFICATION = os.getenv("REQUIRE_EMAIL_VERIFICATION", "true").lower() in {"1", "true", "yes"}
MERCADOPAGO_ACCESS_TOKEN = os.getenv("MERCADOPAGO_ACCESS_TOKEN", "").strip()
MERCADOPAGO_WEBHOOK_SECRET = os.getenv("MERCADOPAGO_WEBHOOK_SECRET", "").strip()
MERCADOPAGO_ENVIRONMENT = os.getenv("MERCADOPAGO_ENVIRONMENT", "test").strip().lower()
MERCADOPAGO_TEST_PAYER_EMAIL = os.getenv(
    "MERCADOPAGO_TEST_PAYER_EMAIL",
    "test_user_br@testuser.com",
).strip().lower()
MERCADOPAGO_API_BASE = os.getenv("MERCADOPAGO_API_BASE", "https://api.mercadopago.com").rstrip("/")
MERCADOPAGO_NOTIFICATION_URL = os.getenv(
    "MERCADOPAGO_NOTIFICATION_URL",
    "https://aumiau.app.br/webhooks/mercadopago",
).strip()
SMTP_HOST = os.getenv("SMTP_HOST", "").strip()
SMTP_PORT = int(os.getenv("SMTP_PORT", "587"))
SMTP_USERNAME = os.getenv("SMTP_USERNAME", "").strip()
SMTP_PASSWORD = os.getenv("SMTP_PASSWORD", "")
SMTP_FROM = os.getenv("SMTP_FROM", SMTP_USERNAME).strip()
AUMIAU_WEB_URL = os.getenv("AUMIAU_WEB_URL", "https://aumiau.app.br").rstrip("/")
PARTNER_DOCUMENTS_DIR = os.getenv("PARTNER_DOCUMENTS_DIR", "/data/partner-documents")
PRESCRIPTIONS_DIR = os.getenv(
    "PRESCRIPTIONS_DIR",
    os.path.join(PARTNER_DOCUMENTS_DIR, "prescriptions"),
)
METRICS_TOKEN = os.getenv("METRICS_TOKEN", "").strip()
GOOGLE_PLAY_PACKAGE_NAME = os.getenv("GOOGLE_PLAY_PACKAGE_NAME", "com.aumiau.aumiau_app").strip()
GOOGLE_PLAY_SERVICE_ACCOUNT_FILE = os.getenv("GOOGLE_PLAY_SERVICE_ACCOUNT_FILE", "").strip()
logger = configure_json_logger("aumiau.api")
STARTED_AT = time.monotonic()


class LoginRequest(BaseModel):
    email: str = Field(min_length=3, max_length=180)
    password: str = Field(min_length=8, max_length=128)


class MfaChallengeRequest(BaseModel):
    challengeToken: str = Field(min_length=20, max_length=2048)
    code: str = Field(min_length=6, max_length=32)


class MfaCodeRequest(BaseModel):
    code: str = Field(min_length=6, max_length=32)


class RegisterRequest(BaseModel):
    name: str = Field(min_length=2, max_length=120)
    phone: str = Field(min_length=8, max_length=30)
    email: str = Field(min_length=3, max_length=180)
    password: str = Field(min_length=8, max_length=128)
    birthDate: str | None = Field(default=None, max_length=30)
    termsAccepted: bool


class AddressRequest(BaseModel):
    country: str = Field(min_length=2, max_length=80)
    state: str = Field(min_length=1, max_length=80)
    city: str = Field(min_length=1, max_length=120)
    postalCode: str = Field(min_length=3, max_length=20)
    street: str = Field(min_length=1, max_length=180)
    number: str = Field(min_length=1, max_length=30)
    complement: str = Field(default="", max_length=120)
    neighborhood: str = Field(default="", max_length=120)
    reference: str = Field(default="", max_length=180)
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)
    accuracy: float | None = Field(default=None, ge=0)
    source: str = Field(default="manual", max_length=30)
    allowVetVisit: bool = False
    consentVersion: str = Field(min_length=1, max_length=40)


class FamilyInvitationRequest(BaseModel):
    inviteeEmail: str = Field(min_length=3, max_length=180)
    petId: str = Field(min_length=1, max_length=120)
    petName: str = Field(default="Pet", min_length=1, max_length=120)
    role: str = Field(default="caregiver", min_length=2, max_length=40)
    permissions: list[str] = Field(default_factory=list, max_length=30)
    expiresInDays: int = Field(default=7, ge=1, le=30)


class FamilyInvitationStatusRequest(BaseModel):
    status: str = Field(min_length=6, max_length=20)


class PartnerCreateRequest(BaseModel):
    name: str = Field(min_length=2, max_length=160)
    partnerType: str = Field(default="clinic", min_length=3, max_length=30)
    cnpj: str = Field(default="", max_length=18)
    documentType: str = Field(default="", max_length=4)
    phone: str = Field(default="", max_length=30)
    whatsapp: str = Field(default="", max_length=30)
    email: str = Field(default="", max_length=180)
    address: str = Field(default="", max_length=240)
    postalCode: str = Field(default="", max_length=20)
    city: str = Field(default="", max_length=120)
    state: str = Field(default="", max_length=80)
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)
    services: list[str] = Field(default_factory=list, max_length=50)
    acceptsUrgency: bool = False


class PartnerRegisterRequest(BaseModel):
    businessName: str = Field(min_length=2, max_length=160)
    partnerType: str = Field(default="clinic", min_length=3, max_length=30)
    cnpj: str = Field(min_length=11, max_length=18)
    documentType: str = Field(default="", max_length=4)
    responsibleName: str = Field(min_length=2, max_length=120)
    responsibleCpf: str = Field(default="", max_length=14)
    crmvUf: str = Field(default="", max_length=2)
    crmvNumber: str = Field(default="", max_length=30)
    artNumber: str = Field(default="", max_length=40)
    email: str = Field(min_length=3, max_length=180)
    password: str = Field(min_length=8, max_length=128)
    phone: str = Field(min_length=8, max_length=30)
    whatsapp: str = Field(default="", max_length=30)
    address: str = Field(default="", max_length=240)
    postalCode: str = Field(default="", max_length=20)
    city: str = Field(default="", max_length=120)
    state: str = Field(default="", max_length=80)
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)
    services: list[str] = Field(default_factory=list, max_length=50)
    acceptsUrgency: bool = False
    termsAccepted: bool


class PartnerProfileUpdateRequest(BaseModel):
    businessName: str = Field(min_length=2, max_length=160)
    partnerType: str = Field(default="clinic", min_length=3, max_length=30)
    cnpj: str = Field(min_length=11, max_length=18)
    documentType: str = Field(default="", max_length=4)
    responsibleName: str = Field(default="", max_length=120)
    responsibleCpf: str = Field(default="", max_length=14)
    crmvUf: str = Field(default="", max_length=2)
    crmvNumber: str = Field(default="", max_length=30)
    artNumber: str = Field(default="", max_length=40)
    phone: str = Field(default="", max_length=30)
    whatsapp: str = Field(default="", max_length=30)
    address: str = Field(default="", max_length=240)
    postalCode: str = Field(default="", max_length=20)
    city: str = Field(default="", max_length=120)
    state: str = Field(default="", max_length=80)
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)
    services: list[str] = Field(default_factory=list, max_length=50)
    acceptsUrgency: bool = False


class PartnerProfileRequest(PartnerProfileUpdateRequest):
    termsAccepted: bool


class PartnerDocumentRequest(BaseModel):
    documentType: str = Field(min_length=2, max_length=60)
    fileName: str = Field(min_length=1, max_length=180)
    mimeType: str = Field(default="application/octet-stream", max_length=120)
    contentBase64: str = Field(min_length=8, max_length=12_000_000)


class PartnerDocumentReviewRequest(BaseModel):
    status: str = Field(min_length=7, max_length=20)
    rejectionReason: str = Field(default="", max_length=500)


class PartnerStatusRequest(BaseModel):
    status: str = Field(min_length=6, max_length=20)


REQUIRED_PARTNER_DOCUMENTS = {
    "documento_responsavel": "Documento de identidade do responsável",
    "documento_fiscal": "CPF/CNPJ ou comprovante fiscal",
    "registro_crmv": "Registro profissional no CRMV",
}


class PrivateVeterinaryContactRequest(BaseModel):
    name: str = Field(min_length=2, max_length=160)
    kind: str = Field(default="Veterinário", min_length=3, max_length=40)
    specialty: str = Field(default="", max_length=120)
    phone: str = Field(default="", max_length=30)
    whatsapp: str = Field(default="", max_length=30)
    address: str = Field(default="", max_length=240)
    city: str = Field(default="", max_length=120)
    state: str = Field(default="", max_length=80)
    notes: str = Field(default="", max_length=1000)
    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)


class AppointmentRequest(BaseModel):
    partnerId: int = Field(gt=0)
    petId: str = Field(min_length=1, max_length=120)
    petName: str = Field(default="Pet", min_length=1, max_length=120)
    service: str = Field(min_length=2, max_length=160)
    scheduledAt: datetime
    notes: str = Field(default="", max_length=1000)


class AppointmentStatusRequest(BaseModel):
    status: str = Field(min_length=3, max_length=30)


class PrescriptionMedicationRequest(BaseModel):
    medication: str = Field(min_length=1, max_length=240)
    concentration: str = Field(min_length=1, max_length=120)
    form: str = Field(min_length=1, max_length=120)
    quantity: str = Field(min_length=1, max_length=120)
    dose: str = Field(min_length=1, max_length=160)
    route: str = Field(min_length=1, max_length=120)
    frequency: str = Field(min_length=1, max_length=160)
    duration: str = Field(min_length=1, max_length=160)
    notes: str = Field(default="", max_length=240)


class PrescriptionCreateRequest(BaseModel):
    appointmentId: int = Field(gt=0)
    prescriptionType: str = Field(default="common", max_length=40)
    patientSpecies: str = Field(min_length=2, max_length=80)
    patientBreed: str = Field(default="Não informada", max_length=120)
    patientSex: str = Field(default="Não informado", max_length=40)
    patientWeight: str = Field(default="Não informado", max_length=40)
    ownerAddress: str = Field(default="", max_length=300)
    items: list[PrescriptionMedicationRequest] = Field(min_length=1, max_length=20)
    instructions: str = Field(default="", max_length=3000)


class PrescriptionCancelRequest(BaseModel):
    reason: str = Field(min_length=8, max_length=500)


class BillingCatalogItem(BaseModel):
    productId: str
    billingPeriod: str
    referencePriceEur: str
    displayName: str


class BillingVerifyRequest(BaseModel):
    productId: str = Field(min_length=3, max_length=120)
    purchaseToken: str = Field(min_length=10, max_length=4096)
    provider: str = Field(default="google_play", max_length=40)


class BillingOrderRequest(BaseModel):
    productId: str = Field(min_length=3, max_length=120)


class EmailVerificationRequest(BaseModel):
    email: str = Field(min_length=3, max_length=180)
    token: str = Field(min_length=32, max_length=256)


class RefreshRequest(BaseModel):
    refreshToken: str = Field(min_length=32, max_length=256)


class AccountDeletionRequest(BaseModel):
    password: str = Field(min_length=1, max_length=200)
    confirmation: str = Field(min_length=1, max_length=20)


class PasswordResetRequest(BaseModel):
    email: str = Field(min_length=3, max_length=180)


class PasswordResetConfirm(BaseModel):
    token: str = Field(min_length=32, max_length=256)
    newPassword: str = Field(min_length=8, max_length=128)


class AdminCreateUserRequest(BaseModel):
    email: str = Field(min_length=3, max_length=180)
    password: str = Field(min_length=8, max_length=128)
    isAdmin: bool = False


class AdminStatusRequest(BaseModel):
    active: bool


class Operation(BaseModel):
    id: int
    entityType: str = Field(min_length=1, max_length=40)
    entityId: int | None = None
    operation: str = Field(min_length=1, max_length=20)
    occurredAt: datetime


class SyncBatch(BaseModel):
    contractVersion: str = Field(min_length=1, max_length=20)
    generatedAt: datetime
    baseRevision: int = Field(default=0, ge=0)
    snapshot: dict[str, Any]
    operations: list[Operation] = Field(max_length=1000)


class EntityChange(BaseModel):
    operationId: int
    entityType: str = Field(pattern="^(pet|vaccine|weight|medication)$")
    entityId: str = Field(min_length=16, max_length=64)
    baseVersion: int = Field(default=0, ge=0)
    deleted: bool = False
    payload: dict[str, Any] | None = None
    changedAt: datetime


class EntityBatch(BaseModel):
    changes: list[EntityChange] = Field(min_length=1, max_length=500)


app = FastAPI(title="AuMiau API", version="1.0.0")
rate_limiter = InMemoryRateLimiter()
request_metrics = RequestMetrics()

BILLING_PRODUCTS: dict[str, dict[str, Any]] = {
    "family_monthly": {
        "amountBrl": "2.99",
        "periodDays": 30,
        "billingPeriod": "P1M",
        "displayName": "AuMiau Family mensal",
        "entitlementKey": "family_access",
        "accountType": "client",
    },
    "family_yearly": {
        "amountBrl": "25.00",
        "periodDays": 365,
        "billingPeriod": "P1Y",
        "displayName": "AuMiau Family anual",
        "entitlementKey": "family_access",
        "accountType": "client",
    },
    "partner_monthly": {
        "amountBrl": "2.99",
        "periodDays": 30,
        "billingPeriod": "P1M",
        "displayName": "AuMiau Parceiro mensal",
        "entitlementKey": "partner_access",
        "accountType": "partner",
    },
    "partner_yearly": {
        "amountBrl": "25.00",
        "periodDays": 365,
        "billingPeriod": "P1Y",
        "displayName": "AuMiau Parceiro anual",
        "entitlementKey": "partner_access",
        "accountType": "partner",
    },
}

BRAZILIAN_STATE_CODES = {
    "acre": "AC",
    "alagoas": "AL",
    "amapa": "AP",
    "amazonas": "AM",
    "bahia": "BA",
    "ceara": "CE",
    "distrito federal": "DF",
    "espirito santo": "ES",
    "goias": "GO",
    "maranhao": "MA",
    "mato grosso": "MT",
    "mato grosso do sul": "MS",
    "minas gerais": "MG",
    "para": "PA",
    "paraiba": "PB",
    "parana": "PR",
    "pernambuco": "PE",
    "piaui": "PI",
    "rio de janeiro": "RJ",
    "rio grande do norte": "RN",
    "rio grande do sul": "RS",
    "rondonia": "RO",
    "roraima": "RR",
    "santa catarina": "SC",
    "sao paulo": "SP",
    "sergipe": "SE",
    "tocantins": "TO",
}


def normalize_state_code(state: str) -> str:
    normalized = " ".join(state.strip().lower().split())
    return BRAZILIAN_STATE_CODES.get(normalized, state.strip().upper()[:2])


def normalize_document(
    value: str,
    *,
    required: bool = True,
    document_type: str = "",
) -> str:
    digits = "".join(character for character in value if character.isdigit())
    if not digits and not required:
        return ""
    normalized_type = document_type.strip().lower()
    if normalized_type not in ("", "cpf", "cnpj"):
        raise HTTPException(status_code=400, detail="Tipo de documento inválido.")
    if len(digits) not in (11, 14) or len(set(digits)) == 1:
        raise HTTPException(status_code=400, detail="Informe um CPF ou CNPJ válido.")
    if normalized_type == "cpf" and len(digits) != 11:
        raise HTTPException(status_code=400, detail="Informe um CPF válido.")
    if normalized_type == "cnpj" and len(digits) != 14:
        raise HTTPException(status_code=400, detail="Informe um CNPJ válido.")

    if len(digits) == 11:
        first_sum = sum(int(digit) * (10 - index) for index, digit in enumerate(digits[:9]))
        first_check = (first_sum * 10) % 11
        first_check = 0 if first_check == 10 else first_check
        if first_check != int(digits[9]):
            raise HTTPException(status_code=400, detail="Informe um CPF válido.")
        second_sum = sum(int(digit) * (11 - index) for index, digit in enumerate(digits[:10]))
        second_check = (second_sum * 10) % 11
        second_check = 0 if second_check == 10 else second_check
        if second_check != int(digits[10]):
            raise HTTPException(status_code=400, detail="Informe um CPF válido.")
        return digits

    first_weights = (5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2)
    second_weights = (6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2)
    first_digit = sum(int(digit) * weight for digit, weight in zip(digits[:12], first_weights))
    first_digit = 0 if first_digit % 11 < 2 else 11 - first_digit % 11
    second_digit = sum(int(digit) * weight for digit, weight in zip(digits[:12] + str(first_digit), second_weights))
    second_digit = 0 if second_digit % 11 < 2 else 11 - second_digit % 11
    if digits[-2:] != f"{first_digit}{second_digit}":
        raise HTTPException(status_code=400, detail="Informe um CNPJ válido.")
    return digits


def normalize_cnpj(value: str, *, required: bool = True) -> str:
    """Mantém compatibilidade com chamadas antigas, aceitando CPF ou CNPJ."""
    return normalize_document(value, required=required)


@app.middleware("http")
async def request_logging(request, call_next):
    started = monotonic_seconds()
    request_id = resolve_request_id(request.headers.get("x-request-id"))
    request.state.request_id = request_id
    request_metrics.begin()
    policy = rate_limit_for(request.url.path)
    if policy is not None:
        limit, window_seconds = policy
        client_host = request.client.host if request.client else "unknown"
        decision = rate_limiter.check(
            f"{request.url.path}:{client_host}",
            limit=limit,
            window_seconds=window_seconds,
        )
        if not decision.allowed:
            elapsed = monotonic_seconds() - started
            request_metrics.finish(request.method, request.url.path, 429, elapsed)
            response = JSONResponse(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                content={"detail": "Muitas tentativas. Aguarde e tente novamente."},
                headers={
                    "Retry-After": str(decision.retry_after_seconds),
                    "X-Request-ID": request_id,
                },
            )
            logger.warning(
                "request_rate_limited",
                extra={
                    "event": "request_rate_limited",
                    "request_id": request_id,
                    "method": request.method,
                    "path": request.url.path,
                    "status_code": 429,
                    "duration_ms": round(elapsed * 1000, 3),
                    "client_ip": client_host,
                },
            )
            return response
    try:
        response = await call_next(request)
    except Exception:
        elapsed = monotonic_seconds() - started
        request_metrics.finish(request.method, request.url.path, 500, elapsed)
        logger.exception(
            "request_failed",
            extra={
                "event": "request_failed",
                "request_id": request_id,
                "method": request.method,
                "path": request.url.path,
                "status_code": 500,
                "duration_ms": round(elapsed * 1000, 3),
                "client_ip": request.client.host if request.client else "unknown",
            },
        )
        raise
    elapsed = monotonic_seconds() - started
    elapsed_ms = elapsed * 1000
    request_metrics.finish(request.method, request.url.path, response.status_code, elapsed)
    logger.info(
        "request_completed",
        extra={
            "event": "request_completed",
            "request_id": request_id,
            "method": request.method,
            "path": request.url.path,
            "status_code": response.status_code,
            "duration_ms": round(elapsed_ms, 3),
            "client_ip": request.client.host if request.client else "unknown",
        },
    )
    response.headers["X-Request-ID"] = request_id
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["Referrer-Policy"] = "no-referrer"
    response.headers["Permissions-Policy"] = "geolocation=(self), camera=(), microphone=()"
    if request.url.scheme == "https":
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
    return response


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def database_connection() -> psycopg.Connection:
    return psycopg.connect(DATABASE_URL)


def mercadopago_request(
    method: str,
    path: str,
    *,
    payload: dict[str, Any] | None = None,
    idempotency_key: str | None = None,
) -> dict[str, Any]:
    if not MERCADOPAGO_ACCESS_TOKEN:
        raise HTTPException(
            status_code=503,
            detail="Mercado Pago ainda não está configurado no backend.",
        )
    body = json.dumps(payload).encode() if payload is not None else None
    headers = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": f"Bearer {MERCADOPAGO_ACCESS_TOKEN}",
    }
    if idempotency_key:
        headers["X-Idempotency-Key"] = idempotency_key
    request = UrlRequest(
        f"{MERCADOPAGO_API_BASE}{path}",
        data=body,
        headers=headers,
        method=method,
    )
    try:
        with urlopen(request, timeout=15) as response:
            raw = response.read().decode("utf-8")
    except HTTPError as error:
        logger.error("mercadopago_http_error status=%s path=%s", error.code, path)
        raise HTTPException(
            status_code=502,
            detail="Mercado Pago recusou a solicitação de pagamento.",
        ) from error
    except (OSError, URLError, TimeoutError) as error:
        logger.error("mercadopago_network_error path=%s", path)
        raise HTTPException(
            status_code=502,
            detail="Não foi possível conectar ao Mercado Pago.",
        ) from error
    try:
        return json.loads(raw) if raw else {}
    except json.JSONDecodeError as error:
        raise HTTPException(
            status_code=502,
            detail="Mercado Pago retornou uma resposta inválida.",
        ) from error


def validate_mercadopago_signature(
    signature: str | None,
    request_id: str | None,
    data_id: str | None,
) -> bool:
    if not MERCADOPAGO_WEBHOOK_SECRET or not signature or not request_id or not data_id:
        return False
    values = {}
    for part in signature.split(","):
        key, separator, value = part.strip().partition("=")
        if separator:
            values[key] = value
    timestamp = values.get("ts")
    received = values.get("v1")
    if not timestamp or not received:
        return False
    manifest = f"id:{data_id};request-id:{request_id};ts:{timestamp};"
    expected = hmac.new(
        MERCADOPAGO_WEBHOOK_SECRET.encode(),
        manifest.encode(),
        hashlib.sha256,
    ).hexdigest()
    return hmac.compare_digest(expected, received)


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def check_password(password: str, password_hash: str) -> bool:
    return bcrypt.checkpw(password.encode(), password_hash.encode())


def issue_token(user_id: int, email: str, session_jti: str) -> str:
    now = utc_now()
    payload = {
        "sub": str(user_id),
        "email": email,
        "jti": session_jti,
        "iat": now,
        "exp": now + timedelta(hours=TOKEN_TTL_HOURS),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def issue_mfa_challenge(user_id: int) -> str:
    now = utc_now()
    challenge_jti = secrets.token_hex(24)
    expires_at = now + timedelta(minutes=5)
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO admin_mfa_challenges (jti, user_id, expires_at)
                VALUES (%s, %s, %s)
                """,
                (challenge_jti, user_id, expires_at),
            )
    return jwt.encode(
        {
            "sub": str(user_id),
            "jti": challenge_jti,
            "type": "admin_mfa_challenge",
            "iat": now,
            "exp": expires_at,
        },
        JWT_SECRET,
        algorithm=JWT_ALGORITHM,
    )


def hash_refresh_token(refresh_token: str) -> str:
    return hashlib.sha256(refresh_token.encode()).hexdigest()


def hash_password_reset_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


def hash_email_verification_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


def issue_email_verification_token(user_id: int) -> tuple[str, datetime]:
    token = secrets.token_urlsafe(48)
    expires_at = utc_now() + timedelta(hours=EMAIL_VERIFICATION_TTL_HOURS)
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE email_verification_tokens
                SET used_at = now()
                WHERE user_id = %s AND used_at IS NULL
                """,
                (user_id,),
            )
            cursor.execute(
                """
                INSERT INTO email_verification_tokens
                    (user_id, token_hash, expires_at)
                VALUES (%s, %s, %s)
                """,
                (user_id, hash_email_verification_token(token), expires_at),
            )
    return token, expires_at


def first_name_from_full_name(full_name: str | None) -> str:
    parts = " ".join((full_name or "").split()).split(" ", 1)
    return parts[0] if parts and parts[0] else "Cliente"


def send_email_verification(
    recipient: str,
    first_name: str,
    token: str,
    expires_at: datetime,
) -> None:
    if not SMTP_HOST or not SMTP_USERNAME or not SMTP_PASSWORD or not SMTP_FROM:
        raise RuntimeError("SMTP de verificação não configurado.")
    message = EmailMessage()
    message["Subject"] = "AuMiau — confirme seu e-mail"
    message["From"] = SMTP_FROM
    message["To"] = recipient
    message.set_content(
        f"Olá, {first_name}!\n\n"
        "Confirme o seu e-mail para ativar a conta AuMiau.\n\n"
        f"Token de verificação: {token}\n"
        f"Validade: até {expires_at.astimezone(timezone.utc).isoformat()}\n\n"
        "Se você não criou esta conta, ignore esta mensagem.\n"
    )
    with smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=15) as smtp:
        smtp.ehlo()
        smtp.starttls()
        smtp.ehlo()
        smtp.login(SMTP_USERNAME, SMTP_PASSWORD)
        smtp.send_message(message)


def issue_password_reset_token(user_id: int) -> tuple[str, datetime]:
    token = secrets.token_urlsafe(48)
    expires_at = utc_now() + timedelta(minutes=RESET_TOKEN_TTL_MINUTES)
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE password_reset_tokens
                SET used_at = now()
                WHERE user_id = %s AND used_at IS NULL
                """,
                (user_id,),
            )
            cursor.execute(
                """
                INSERT INTO password_reset_tokens
                    (user_id, token_hash, expires_at)
                VALUES (%s, %s, %s)
                """,
                (user_id, hash_password_reset_token(token), expires_at),
            )
    return token, expires_at


def send_password_reset_email(
    recipient: str,
    first_name: str,
    token: str,
    expires_at: datetime,
) -> None:
    if not SMTP_HOST or not SMTP_USERNAME or not SMTP_PASSWORD or not SMTP_FROM:
        raise RuntimeError("SMTP de recuperação não configurado.")
    message = EmailMessage()
    message["Subject"] = "AuMiau — recuperação de senha"
    message["From"] = SMTP_FROM
    message["To"] = recipient
    message.set_content(
        f"Olá, {first_name}!\n\n"
        "Recebemos uma solicitação para alterar a senha da sua conta AuMiau.\n\n"
        f"Token de recuperação: {token}\n"
        f"Validade: até {expires_at.astimezone(timezone.utc).isoformat()}\n\n"
        "Se você não solicitou esta alteração, ignore esta mensagem.\n"
    )
    with smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=15) as smtp:
        smtp.ehlo()
        smtp.starttls()
        smtp.ehlo()
        smtp.login(SMTP_USERNAME, SMTP_PASSWORD)
        smtp.send_message(message)


def send_family_invitation_email(
    recipient: str,
    owner_name: str,
    pet_name: str,
    invitation_id: int,
    expires_at: datetime,
) -> None:
    if not SMTP_HOST or not SMTP_USERNAME or not SMTP_PASSWORD or not SMTP_FROM:
        raise RuntimeError("SMTP de convite não configurado.")
    message = EmailMessage()
    message["Subject"] = "AuMiau — convite para cuidar de um pet"
    message["From"] = SMTP_FROM
    message["To"] = recipient
    message.set_content(
        f"Olá!\n\n{owner_name or 'Uma pessoa de confiança'} convidou você "
        f"para acompanhar o pet {pet_name} no AuMiau Family.\n\n"
        f"Abra o aplicativo e entre com este e-mail para aceitar o convite: {recipient}\n"
        f"Convite: {AUMIAU_WEB_URL}/family/invitations/{invitation_id}\n"
        f"Validade: até {expires_at.astimezone(timezone.utc).isoformat()}\n\n"
        "Se você não esperava este convite, ignore esta mensagem.\n"
    )
    with smtplib.SMTP(SMTP_HOST, SMTP_PORT, timeout=15) as smtp:
        smtp.ehlo()
        smtp.starttls()
        smtp.ehlo()
        smtp.login(SMTP_USERNAME, SMTP_PASSWORD)
        smtp.send_message(message)


def create_auth_session(user_id: int, email: str, *, mfa_verified: bool = False) -> dict[str, Any]:
    now = utc_now()
    access_expires_at = now + timedelta(hours=TOKEN_TTL_HOURS)
    refresh_expires_at = now + timedelta(days=REFRESH_TTL_DAYS)
    session_jti = secrets.token_hex(24)
    refresh_token = secrets.token_urlsafe(48)
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO auth_sessions
                    (jti, user_id, refresh_token_hash, refresh_expires_at, mfa_verified)
                VALUES (%s, %s, %s, %s, %s)
                """,
                (session_jti, user_id, hash_refresh_token(refresh_token), refresh_expires_at, mfa_verified),
            )
    return {
        "accessToken": issue_token(user_id, email, session_jti),
        "refreshToken": refresh_token,
        "expiresAt": access_expires_at.isoformat(),
    }


def current_user(authorization: str | None = Header(default=None)) -> dict[str, Any]:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de acesso ausente.",
        )
    token = authorization.removeprefix("Bearer ").strip()
    try:
        claims = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
    except jwt.PyJWTError as error:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token de acesso inválido ou expirado.",
        ) from error
    session_jti = claims.get("jti")
    subject = claims.get("sub")
    if not isinstance(session_jti, str) or not isinstance(subject, str):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Sessão inválida.",
        )
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT sessions.user_id
                FROM auth_sessions AS sessions
                JOIN users ON users.id = sessions.user_id
                WHERE sessions.jti = %s
                  AND sessions.revoked_at IS NULL
                  AND sessions.refresh_expires_at > now()
                  AND users.is_active IS TRUE
                """,
                (session_jti,),
            )
            session = cursor.fetchone()
    if session is None or session[0] != int(subject):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Sessão encerrada ou expirada.",
        )
    return claims


def require_family(user: dict[str, Any] = Depends(current_user)) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT status, valid_until
                FROM entitlements
                WHERE user_id = %s AND entitlement_key = 'family_access'
                """,
                (int(user["sub"]),),
            )
            entitlement = cursor.fetchone()
    if (
        entitlement is None
        or entitlement[0] != "active"
        or (entitlement[1] is not None and entitlement[1] <= utc_now())
    ):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Este recurso está disponível somente para o plano Family ativo.",
        )
    return user


def current_admin_account(user: dict[str, Any] = Depends(current_user)) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT is_admin, is_active, mfa_enabled FROM users WHERE id = %s",
                (int(user["sub"]),),
            )
            account = cursor.fetchone()
    if account is None or not account[0] or not account[1]:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Acesso administrativo necessário.")
    return {**user, "mfa_enabled": bool(account[2])}


def current_admin(user: dict[str, Any] = Depends(current_admin_account)) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT mfa_verified FROM auth_sessions WHERE jti = %s AND user_id = %s",
                (str(user["jti"]), int(user["sub"])),
            )
            session = cursor.fetchone()
    if not user["mfa_enabled"] or session is None or not session[0]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Ative e valide o MFA para acessar recursos administrativos.",
        )
    return user


def current_partner(user: dict[str, Any] = Depends(current_user)) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT EXISTS(
                           SELECT 1
                           FROM user_roles
                           WHERE user_roles.user_id = users.id
                             AND user_roles.role = 'partner'
                       ),
                       users.account_type,
                       partner_profiles.id
                FROM users
                LEFT JOIN partner_profiles ON partner_profiles.owner_user_id = users.id
                WHERE users.id = %s
                """,
                (int(user["sub"]),),
            )
            account = cursor.fetchone()
    if account is None or not (account[0] or account[1] == "partner") or account[2] is None:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Conta de parceiro necessária.")
    return {**user, "partner_id": account[2]}


def require_partner_access(user: dict[str, Any] = Depends(current_partner)) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT status, valid_until
                FROM entitlements
                WHERE user_id = %s AND entitlement_key = 'partner_access'
                """,
                (int(user["sub"]),),
            )
            entitlement = cursor.fetchone()
    if (
        entitlement is None
        or entitlement[0] != "active"
        or (entitlement[1] is not None and entitlement[1] <= utc_now())
    ):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Ative a assinatura do AuMiau Parceiro.")
    return user


def initialize_database() -> None:
    statements = [
        """
        CREATE TABLE IF NOT EXISTS users (
            id BIGSERIAL PRIMARY KEY,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            full_name TEXT NOT NULL DEFAULT '',
            phone TEXT NOT NULL DEFAULT '',
            birth_date TEXT,
            terms_accepted_at TIMESTAMPTZ,
            edition TEXT NOT NULL DEFAULT 'family',
            plan_code TEXT NOT NULL DEFAULT 'family',
            account_type TEXT NOT NULL DEFAULT 'client',
            is_admin BOOLEAN NOT NULL DEFAULT FALSE,
            is_active BOOLEAN NOT NULL DEFAULT TRUE,
            email_verified BOOLEAN NOT NULL DEFAULT TRUE,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """,
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT FALSE",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS full_name TEXT NOT NULL DEFAULT ''",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS phone TEXT NOT NULL DEFAULT ''",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS birth_date TEXT",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS terms_accepted_at TIMESTAMPTZ",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified BOOLEAN NOT NULL DEFAULT TRUE",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS edition TEXT NOT NULL DEFAULT 'family'",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS plan_code TEXT NOT NULL DEFAULT 'family'",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS account_type TEXT NOT NULL DEFAULT 'client'",
        """
        CREATE TABLE IF NOT EXISTS user_roles (
            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            role TEXT NOT NULL,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            PRIMARY KEY (user_id, role),
            CHECK (role IN ('client', 'partner', 'admin'))
        )
        """,
        """
        INSERT INTO user_roles (user_id, role)
        SELECT id, account_type
        FROM users
        WHERE account_type IN ('client', 'partner', 'admin')
        ON CONFLICT (user_id, role) DO NOTHING
        """,
        """
        CREATE TABLE IF NOT EXISTS sync_batches (
            id BIGSERIAL PRIMARY KEY,
            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            contract_version TEXT NOT NULL,
            generated_at TIMESTAMPTZ NOT NULL,
            received_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            snapshot JSONB NOT NULL
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS sync_operations (
            id BIGSERIAL PRIMARY KEY,
            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            operation_id BIGINT NOT NULL,
            entity_type TEXT NOT NULL,
            entity_id BIGINT,
            operation TEXT NOT NULL,
            occurred_at TIMESTAMPTZ NOT NULL,
            batch_id BIGINT NOT NULL REFERENCES sync_batches(id) ON DELETE CASCADE,
            UNIQUE (user_id, operation_id)
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS user_snapshots (
            user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
            snapshot JSONB NOT NULL,
            updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS auth_sessions (
            id BIGSERIAL PRIMARY KEY,
            jti TEXT NOT NULL UNIQUE,
            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            refresh_token_hash TEXT NOT NULL UNIQUE,
            refresh_expires_at TIMESTAMPTZ NOT NULL,
            revoked_at TIMESTAMPTZ,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS password_reset_tokens (
            id BIGSERIAL PRIMARY KEY,
            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            token_hash TEXT NOT NULL UNIQUE,
            expires_at TIMESTAMPTZ NOT NULL,
            used_at TIMESTAMPTZ,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS email_verification_tokens (
            id BIGSERIAL PRIMARY KEY,
            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            token_hash TEXT NOT NULL UNIQUE,
            expires_at TIMESTAMPTZ NOT NULL,
            used_at TIMESTAMPTZ,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS subscriptions (
            id BIGSERIAL PRIMARY KEY,
            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            provider TEXT NOT NULL,
            product_id TEXT NOT NULL,
            purchase_token_hash TEXT NOT NULL UNIQUE,
            order_id TEXT,
            status TEXT NOT NULL DEFAULT 'pending',
            environment TEXT NOT NULL DEFAULT 'production',
            auto_renew BOOLEAN,
            started_at TIMESTAMPTZ,
            expires_at TIMESTAMPTZ,
            verified_at TIMESTAMPTZ,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS billing_orders (
            id BIGSERIAL PRIMARY KEY,
            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            provider TEXT NOT NULL,
            product_id TEXT NOT NULL,
            external_reference TEXT NOT NULL UNIQUE,
            provider_order_id TEXT NOT NULL UNIQUE,
            provider_payment_id TEXT,
            amount_brl NUMERIC(12, 2) NOT NULL,
            status TEXT NOT NULL DEFAULT 'pending',
            status_detail TEXT,
            environment TEXT NOT NULL DEFAULT 'test',
            qr_code TEXT NOT NULL,
            ticket_url TEXT,
            expires_at TIMESTAMPTZ,
            paid_at TIMESTAMPTZ,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """,
        "ALTER TABLE billing_orders ADD COLUMN IF NOT EXISTS qr_code_base64 TEXT",
        """
        CREATE TABLE IF NOT EXISTS entitlements (
            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            entitlement_key TEXT NOT NULL,
            source TEXT NOT NULL,
            status TEXT NOT NULL,
            valid_from TIMESTAMPTZ NOT NULL DEFAULT now(),
            valid_until TIMESTAMPTZ,
            updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            PRIMARY KEY (user_id, entitlement_key)
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS user_addresses (
            user_id BIGINT PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
            country TEXT NOT NULL,
            state TEXT NOT NULL,
            city TEXT NOT NULL,
            postal_code TEXT NOT NULL,
            street TEXT NOT NULL,
            number TEXT NOT NULL,
            complement TEXT NOT NULL DEFAULT '',
            neighborhood TEXT NOT NULL DEFAULT '',
            reference TEXT NOT NULL DEFAULT '',
            latitude DOUBLE PRECISION,
            longitude DOUBLE PRECISION,
            accuracy DOUBLE PRECISION,
            source TEXT NOT NULL DEFAULT 'manual',
            allow_vet_visit BOOLEAN NOT NULL DEFAULT FALSE,
            consent_version TEXT NOT NULL,
            consent_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            CHECK ((latitude IS NULL AND longitude IS NULL) OR (latitude IS NOT NULL AND longitude IS NOT NULL))
        )
        """,
        """
        CREATE TABLE IF NOT EXISTS family_invitations (
            id BIGSERIAL PRIMARY KEY,
            owner_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            invitee_email TEXT NOT NULL,
            pet_ref TEXT NOT NULL,
            pet_name TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT 'caregiver',
            permissions JSONB NOT NULL DEFAULT '[]'::jsonb,
            status TEXT NOT NULL DEFAULT 'pending',
            expires_at TIMESTAMPTZ NOT NULL,
            accepted_by_user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
            invited_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            accepted_at TIMESTAMPTZ,
            updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """,
        "CREATE INDEX IF NOT EXISTS family_invitations_invitee_idx ON family_invitations (invitee_email, status)",
        """
        CREATE TABLE IF NOT EXISTS family_access_grants (
            id BIGSERIAL PRIMARY KEY,
            owner_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            member_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            pet_ref TEXT NOT NULL,
            pet_name TEXT NOT NULL,
            role TEXT NOT NULL,
            permissions JSONB NOT NULL DEFAULT '[]'::jsonb,
            status TEXT NOT NULL DEFAULT 'active',
            expires_at TIMESTAMPTZ,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            UNIQUE (owner_user_id, member_user_id, pet_ref)
        )
        """,
        "CREATE INDEX IF NOT EXISTS family_access_member_idx ON family_access_grants (member_user_id, status)",
        """
        CREATE TABLE IF NOT EXISTS partner_profiles (
            id BIGSERIAL PRIMARY KEY,
            owner_user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
            name TEXT NOT NULL,
            partner_type TEXT NOT NULL DEFAULT 'clinic',
            cnpj TEXT NOT NULL DEFAULT '',
            phone TEXT NOT NULL DEFAULT '',
            whatsapp TEXT NOT NULL DEFAULT '',
            email TEXT NOT NULL DEFAULT '',
            address TEXT NOT NULL DEFAULT '',
            postal_code TEXT NOT NULL DEFAULT '',
            city TEXT NOT NULL DEFAULT '',
            state TEXT NOT NULL DEFAULT '',
            latitude DOUBLE PRECISION,
            longitude DOUBLE PRECISION,
            services JSONB NOT NULL DEFAULT '[]'::jsonb,
            accepts_urgency BOOLEAN NOT NULL DEFAULT FALSE,
            status TEXT NOT NULL DEFAULT 'active',
            created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            CHECK ((latitude IS NULL AND longitude IS NULL) OR (latitude IS NOT NULL AND longitude IS NOT NULL))
        )
        """,
        "CREATE INDEX IF NOT EXISTS partner_profiles_location_idx ON partner_profiles (status, city, state)",
        "ALTER TABLE partner_profiles ADD COLUMN IF NOT EXISTS owner_user_id BIGINT REFERENCES users(id) ON DELETE CASCADE",
        "ALTER TABLE partner_profiles ADD COLUMN IF NOT EXISTS postal_code TEXT NOT NULL DEFAULT ''",
        "ALTER TABLE partner_profiles ADD COLUMN IF NOT EXISTS cnpj TEXT NOT NULL DEFAULT ''",
        "ALTER TABLE partner_profiles ADD COLUMN IF NOT EXISTS verification_status TEXT NOT NULL DEFAULT 'pending'",
        "ALTER TABLE partner_profiles ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ",
        "ALTER TABLE partner_profiles ADD COLUMN IF NOT EXISTS verified_by BIGINT REFERENCES users(id) ON DELETE SET NULL",
        "UPDATE partner_profiles SET verification_status = 'approved' WHERE status = 'active' AND verification_status = 'pending'",
        "CREATE UNIQUE INDEX IF NOT EXISTS partner_profiles_owner_idx ON partner_profiles (owner_user_id) WHERE owner_user_id IS NOT NULL",
        "CREATE UNIQUE INDEX IF NOT EXISTS partner_profiles_cnpj_idx ON partner_profiles (cnpj) WHERE cnpj <> ''",
        """
        CREATE TABLE IF NOT EXISTS partner_professionals (
            id BIGSERIAL PRIMARY KEY,
            partner_id BIGINT NOT NULL REFERENCES partner_profiles(id) ON DELETE CASCADE,
            full_name TEXT NOT NULL,
            cpf TEXT NOT NULL DEFAULT '',
            crmv_uf TEXT NOT NULL DEFAULT '',
            crmv_number TEXT NOT NULL DEFAULT '',
            art_number TEXT NOT NULL DEFAULT '',
            is_responsible_technical BOOLEAN NOT NULL DEFAULT FALSE,
            verification_status TEXT NOT NULL DEFAULT 'pending',
            verified_at TIMESTAMPTZ,
            verified_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """,
        "CREATE INDEX IF NOT EXISTS partner_professionals_partner_idx ON partner_professionals (partner_id)",
        "CREATE UNIQUE INDEX IF NOT EXISTS partner_professionals_rt_idx ON partner_professionals (partner_id) WHERE is_responsible_technical IS TRUE",
        """
        CREATE TABLE IF NOT EXISTS partner_documents (
            id BIGSERIAL PRIMARY KEY,
            partner_id BIGINT NOT NULL REFERENCES partner_profiles(id) ON DELETE CASCADE,
            professional_id BIGINT REFERENCES partner_professionals(id) ON DELETE CASCADE,
            document_type TEXT NOT NULL,
            storage_key TEXT NOT NULL,
            document_hash TEXT NOT NULL,
            verification_status TEXT NOT NULL DEFAULT 'pending',
            reviewed_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
            reviewed_at TIMESTAMPTZ,
            rejection_reason TEXT NOT NULL DEFAULT '',
            created_at TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """,
        "CREATE INDEX IF NOT EXISTS partner_documents_partner_idx ON partner_documents (partner_id, verification_status)",
        "ALTER TABLE partner_documents ADD COLUMN IF NOT EXISTS file_name TEXT NOT NULL DEFAULT ''",
        "ALTER TABLE partner_documents ADD COLUMN IF NOT EXISTS mime_type TEXT NOT NULL DEFAULT 'application/octet-stream'",
        """
        CREATE TABLE IF NOT EXISTS partner_document_audits (
            id BIGSERIAL PRIMARY KEY,
            document_id BIGINT NOT NULL REFERENCES partner_documents(id) ON DELETE CASCADE,
            partner_id BIGINT NOT NULL REFERENCES partner_profiles(id) ON DELETE CASCADE,
            admin_user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
            previous_status TEXT NOT NULL,
            new_status TEXT NOT NULL,
            rejection_reason TEXT NOT NULL DEFAULT '',
            created_at TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """,
        "CREATE INDEX IF NOT EXISTS partner_document_audits_document_idx ON partner_document_audits (document_id, created_at DESC)",
        """
        CREATE TABLE IF NOT EXISTS private_veterinary_contacts (
            id BIGSERIAL PRIMARY KEY,
            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            name TEXT NOT NULL,
            kind TEXT NOT NULL DEFAULT 'Veterinário',
            specialty TEXT NOT NULL DEFAULT '',
            phone TEXT NOT NULL DEFAULT '',
            whatsapp TEXT NOT NULL DEFAULT '',
            address TEXT NOT NULL DEFAULT '',
            city TEXT NOT NULL DEFAULT '',
            state TEXT NOT NULL DEFAULT '',
            notes TEXT NOT NULL DEFAULT '',
            latitude DOUBLE PRECISION,
            longitude DOUBLE PRECISION,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            CHECK ((latitude IS NULL AND longitude IS NULL) OR (latitude IS NOT NULL AND longitude IS NOT NULL))
        )
        """,
        "CREATE INDEX IF NOT EXISTS private_vet_contacts_user_idx ON private_veterinary_contacts (user_id, name)",
        """
        CREATE TABLE IF NOT EXISTS appointments (
            id BIGSERIAL PRIMARY KEY,
            user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            partner_id BIGINT NOT NULL REFERENCES partner_profiles(id) ON DELETE RESTRICT,
            pet_ref TEXT NOT NULL,
            pet_name TEXT NOT NULL,
            service TEXT NOT NULL,
            scheduled_at TIMESTAMPTZ NOT NULL,
            status TEXT NOT NULL DEFAULT 'requested',
            notes TEXT NOT NULL DEFAULT '',
            check_in_at TIMESTAMPTZ,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
            updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """,
        "CREATE INDEX IF NOT EXISTS appointments_user_idx ON appointments (user_id, scheduled_at DESC)",
    ]
    with database_connection() as connection:
        with connection.cursor() as cursor:
            for statement in statements:
                cursor.execute(statement)
            applied_migrations = apply_migrations(cursor)
            if applied_migrations:
                logger.info("database_migrations_applied versions=%s", ",".join(applied_migrations))
            cursor.execute(
                """
                INSERT INTO entitlements (user_id, entitlement_key, source, status)
                SELECT id, 'family_access', 'legacy_account', 'active'
                FROM users
                WHERE edition = 'family'
                ON CONFLICT (user_id, entitlement_key) DO NOTHING
                """
            )
            cursor.execute("DELETE FROM auth_sessions WHERE refresh_expires_at <= now()")
            cursor.execute("DELETE FROM admin_mfa_challenges WHERE expires_at <= now() OR used_at IS NOT NULL")
            cursor.execute("DELETE FROM password_reset_tokens WHERE expires_at <= now() OR used_at IS NOT NULL")
            cursor.execute("DELETE FROM email_verification_tokens WHERE expires_at <= now() OR used_at IS NOT NULL")


def initialize_bootstrap_user() -> None:
    email = os.getenv("AUMIAU_BOOTSTRAP_EMAIL", "").strip().lower()
    password = os.getenv("AUMIAU_BOOTSTRAP_PASSWORD", "")
    if not email or not password:
        return
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
            user = cursor.fetchone()
            if user is None:
                cursor.execute(
                    "INSERT INTO users (email, password_hash, is_admin) VALUES (%s, %s, TRUE)",
                    (email, hash_password(password)),
                )


def initialize_with_retry() -> None:
    last_error: Exception | None = None
    for _ in range(30):
        try:
            initialize_database()
            initialize_bootstrap_user()
            return
        except psycopg.OperationalError as error:
            last_error = error
            time.sleep(2)
    raise RuntimeError("Não foi possível inicializar o PostgreSQL.") from last_error


@app.on_event("startup")
def startup() -> None:
    initialize_with_retry()


@app.get("/privacidade", response_class=HTMLResponse, include_in_schema=False)
@app.get("/privacy", response_class=HTMLResponse, include_in_schema=False)
def privacy_policy() -> HTMLResponse:
    return HTMLResponse(
        content=privacy_policy_html(),
        headers={"Cache-Control": "public, max-age=3600"},
    )


@app.get("/excluir-conta", response_class=HTMLResponse, include_in_schema=False)
@app.get("/delete-account", response_class=HTMLResponse, include_in_schema=False)
def account_deletion_page() -> HTMLResponse:
    return HTMLResponse(
        content=account_deletion_html(),
        headers={"Cache-Control": "public, max-age=3600"},
    )


@app.get("/health")
def health() -> dict[str, str]:
    try:
        with database_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
                cursor.fetchone()
        return {"status": "ok", "service": "aumiau-api"}
    except psycopg.Error as error:
        raise HTTPException(status_code=503, detail="Banco indisponível.") from error


@app.get("/ready")
def ready() -> dict[str, str]:
    health()
    return {"status": "ready", "service": "aumiau-api"}


@app.get("/metrics", response_class=PlainTextResponse)
def metrics(authorization: str | None = Header(default=None)) -> str:
    if not METRICS_TOKEN:
        raise HTTPException(status_code=404, detail="Recurso não encontrado.")
    supplied_token = ""
    if authorization and authorization.lower().startswith("bearer "):
        supplied_token = authorization[7:].strip()
    if not hmac.compare_digest(supplied_token, METRICS_TOKEN):
        raise HTTPException(status_code=401, detail="Credencial de métricas inválida.")
    try:
        with database_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT COUNT(*) FROM users")
                users_total = cursor.fetchone()[0]
                cursor.execute("SELECT COUNT(*) FROM users WHERE is_active IS TRUE")
                users_active = cursor.fetchone()[0]
                cursor.execute("SELECT COUNT(*) FROM auth_sessions WHERE revoked_at IS NULL AND refresh_expires_at > now()")
                sessions_active = cursor.fetchone()[0]
                cursor.execute("SELECT COUNT(*) FROM sync_batches")
                sync_batches_total = cursor.fetchone()[0]
                cursor.execute("SELECT COUNT(*) FROM password_reset_tokens WHERE used_at IS NULL AND expires_at > now()")
                resets_pending = cursor.fetchone()[0]
    except psycopg.Error as error:
        raise HTTPException(status_code=503, detail="Banco indisponível.") from error
    uptime = max(0.0, time.monotonic() - STARTED_AT)
    business_metrics = "\n".join(
        [
            "# HELP aumiau_api_info Informacoes da API AuMiau.",
            "# TYPE aumiau_api_info gauge",
            'aumiau_api_info{version="1.0.0"} 1',
            "# TYPE aumiau_api_uptime_seconds gauge",
            f"aumiau_api_uptime_seconds {uptime:.3f}",
            "# TYPE aumiau_users_total gauge",
            f"aumiau_users_total {users_total}",
            "# TYPE aumiau_users_active gauge",
            f"aumiau_users_active {users_active}",
            "# TYPE aumiau_sessions_active gauge",
            f"aumiau_sessions_active {sessions_active}",
            "# TYPE aumiau_sync_batches_total counter",
            f"aumiau_sync_batches_total {sync_batches_total}",
            "# TYPE aumiau_password_reset_tokens_pending gauge",
            f"aumiau_password_reset_tokens_pending {resets_pending}",
            "",
        ]
    )
    return request_metrics.render_prometheus() + business_metrics


@app.get("/admin", response_class=HTMLResponse)
def admin_panel() -> str:
    return ADMIN_HTML


@app.post("/auth/login")
def login(request: LoginRequest) -> dict[str, Any]:
    email = request.email.strip().lower()
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, email, password_hash, is_active, email_verified, is_admin, mfa_enabled
                FROM users
                WHERE email = %s
                """,
                (email,),
            )
            user = cursor.fetchone()
    if user is None or not user[3] or not check_password(request.password, user[2]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="E-mail ou senha inválidos.",
        )
    if not user[4]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Confirme o seu e-mail antes de entrar.",
        )
    if user[5] and user[6]:
        return {
            "mfaRequired": True,
            "challengeToken": issue_mfa_challenge(user[0]),
            "expiresInSeconds": 300,
        }
    session = create_auth_session(user[0], user[1])
    if user[5]:
        session["mfaSetupRequired"] = True
    return session


@app.post("/auth/mfa/verify")
def verify_mfa_challenge(request: MfaChallengeRequest) -> dict[str, str]:
    try:
        claims = jwt.decode(request.challengeToken, JWT_SECRET, algorithms=[JWT_ALGORITHM])
    except jwt.PyJWTError as error:
        raise HTTPException(status_code=401, detail="Desafio MFA inválido ou expirado.") from error
    if claims.get("type") != "admin_mfa_challenge":
        raise HTTPException(status_code=401, detail="Desafio MFA inválido ou expirado.")
    user_id = int(claims["sub"])
    challenge_jti = str(claims["jti"])
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT challenges.used_at, challenges.expires_at,
                       users.email, users.mfa_secret_encrypted, users.mfa_enabled
                FROM admin_mfa_challenges AS challenges
                JOIN users ON users.id = challenges.user_id
                WHERE challenges.jti = %s AND challenges.user_id = %s
                FOR UPDATE
                """,
                (challenge_jti, user_id),
            )
            challenge = cursor.fetchone()
            if challenge is None or challenge[0] is not None or challenge[1] <= utc_now() or not challenge[4]:
                raise HTTPException(status_code=401, detail="Desafio MFA inválido ou expirado.")
            secret = decrypt_secret(challenge[3], JWT_SECRET)
            valid = verify_totp(secret, request.code)
            if not valid:
                recovery_hash = hash_recovery_code(request.code, JWT_SECRET)
                cursor.execute(
                    """
                    UPDATE admin_mfa_recovery_codes
                    SET used_at = now()
                    WHERE user_id = %s AND code_hash = %s AND used_at IS NULL
                    RETURNING id
                    """,
                    (user_id, recovery_hash),
                )
                valid = cursor.fetchone() is not None
            if not valid:
                raise HTTPException(status_code=401, detail="Código MFA inválido.")
            cursor.execute(
                "UPDATE admin_mfa_challenges SET used_at = now() WHERE jti = %s",
                (challenge_jti,),
            )
    return create_auth_session(user_id, challenge[2], mfa_verified=True)


@app.post("/admin/mfa/setup")
def setup_admin_mfa(admin: dict[str, Any] = Depends(current_admin_account)) -> dict[str, str]:
    if admin["mfa_enabled"]:
        raise HTTPException(status_code=409, detail="O MFA administrativo já está ativo.")
    secret = generate_totp_secret()
    encrypted = encrypt_secret(secret, JWT_SECRET)
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "UPDATE users SET mfa_pending_secret_encrypted = %s WHERE id = %s",
                (encrypted, int(admin["sub"])),
            )
    return {
        "secret": secret,
        "provisioningUri": provisioning_uri(secret, str(admin["email"])),
    }


@app.post("/admin/mfa/activate")
def activate_admin_mfa(
    request: MfaCodeRequest,
    admin: dict[str, Any] = Depends(current_admin_account),
) -> dict[str, Any]:
    if admin["mfa_enabled"]:
        raise HTTPException(status_code=409, detail="O MFA administrativo já está ativo.")
    user_id = int(admin["sub"])
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT mfa_pending_secret_encrypted FROM users WHERE id = %s FOR UPDATE",
                (user_id,),
            )
            row = cursor.fetchone()
            if row is None or not row[0]:
                raise HTTPException(status_code=409, detail="Inicie a configuração do MFA novamente.")
            secret = decrypt_secret(row[0], JWT_SECRET)
            if not verify_totp(secret, request.code):
                raise HTTPException(status_code=400, detail="Código MFA inválido.")
            recovery_codes = generate_recovery_codes()
            cursor.execute(
                """
                UPDATE users
                SET mfa_enabled = TRUE,
                    mfa_secret_encrypted = mfa_pending_secret_encrypted,
                    mfa_pending_secret_encrypted = NULL
                WHERE id = %s
                """,
                (user_id,),
            )
            cursor.execute("DELETE FROM admin_mfa_recovery_codes WHERE user_id = %s", (user_id,))
            cursor.executemany(
                "INSERT INTO admin_mfa_recovery_codes (user_id, code_hash) VALUES (%s, %s)",
                [(user_id, hash_recovery_code(code, JWT_SECRET)) for code in recovery_codes],
            )
            cursor.execute(
                "UPDATE auth_sessions SET mfa_verified = TRUE WHERE jti = %s AND user_id = %s",
                (str(admin["jti"]), user_id),
            )
    return {"status": "enabled", "recoveryCodes": recovery_codes}


@app.post("/auth/register")
def register(request: RegisterRequest) -> dict[str, Any]:
    if not request.termsAccepted:
        raise HTTPException(status_code=400, detail="Aceite os Termos de Uso e a Política de Privacidade.")
    email = request.email.strip().lower()
    if "@" not in email or "." not in email.rsplit("@", 1)[-1]:
        raise HTTPException(status_code=400, detail="Informe um e-mail válido.")
    verified = not REQUIRE_EMAIL_VERIFICATION
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1 FROM users WHERE email = %s", (email,))
            if cursor.fetchone() is not None:
                raise HTTPException(status_code=409, detail="E-mail já cadastrado.")
            cursor.execute(
                """
                INSERT INTO users
                    (email, password_hash, full_name, phone, birth_date,
                     terms_accepted_at, edition, plan_code, email_verified)
                VALUES (%s, %s, %s, %s, %s, now(), 'family', 'family', %s)
                RETURNING id
                """,
                (email, hash_password(request.password), request.name.strip(),
                 request.phone.strip(), request.birthDate, verified),
            )
            user_id = cursor.fetchone()[0]
            cursor.execute(
                "INSERT INTO user_roles (user_id, role) VALUES (%s, 'client') ON CONFLICT DO NOTHING",
                (user_id,),
            )
            cursor.execute(
                """
                INSERT INTO entitlements (user_id, entitlement_key, source, status)
                VALUES (%s, 'family_access', 'account_registration', 'pending')
                ON CONFLICT (user_id, entitlement_key) DO NOTHING
                """,
                (user_id,),
            )
    if not verified:
        try:
            token, expires_at = issue_email_verification_token(user_id)
            send_email_verification(
                email,
                first_name_from_full_name(request.name),
                token,
                expires_at,
            )
        except (OSError, smtplib.SMTPException, RuntimeError) as error:
            logger.exception("email_verification_requested user_id=%s email_sent=false", user_id)
            raise HTTPException(
                status_code=503,
                detail="Não foi possível enviar o e-mail de confirmação agora.",
            ) from error
        return {
            "status": "verification_required",
            "email": email,
            "message": "Conta criada. Enviamos um token de confirmação para o seu e-mail.",
        }
    session = create_auth_session(user_id, email)
    session.update({"status": "authenticated", "email": email})
    return session


@app.post("/partner/auth/register")
def register_partner(request: PartnerRegisterRequest) -> dict[str, Any]:
    if not request.termsAccepted:
        raise HTTPException(status_code=400, detail="Aceite os Termos de Uso e a Política de Privacidade.")
    if (request.latitude is None) != (request.longitude is None):
        raise HTTPException(status_code=400, detail="Latitude e longitude devem ser informadas juntas.")
    normalized_cnpj = normalize_document(
        request.cnpj,
        document_type=request.documentType,
    )
    email = request.email.strip().lower()
    if "@" not in email or "." not in email.rsplit("@", 1)[-1]:
        raise HTTPException(status_code=400, detail="Informe um e-mail válido.")
    responsible_cpf = normalize_document(
        request.responsibleCpf,
        required=False,
        document_type="cpf",
    )
    partner_type = request.partnerType.strip().lower()
    existing_account = False
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT id, password_hash, is_active, email_verified FROM users WHERE email = %s",
                (email,),
            )
            account = cursor.fetchone()
            if account is not None:
                if not check_password(request.password, account[1]):
                    raise HTTPException(status_code=401, detail="Credenciais inválidas para ativar o perfil parceiro.")
                if not account[2]:
                    raise HTTPException(status_code=403, detail="Esta conta está desativada.")
                if not account[3]:
                    raise HTTPException(status_code=403, detail="Confirme o e-mail da conta antes de ativar o perfil parceiro.")
                user_id = account[0]
                existing_account = True
                cursor.execute(
                    "SELECT 1 FROM partner_profiles WHERE owner_user_id = %s",
                    (user_id,),
                )
                if cursor.fetchone() is not None:
                    raise HTTPException(status_code=409, detail="O perfil parceiro desta conta já foi cadastrado.")
            else:
                verified = not REQUIRE_EMAIL_VERIFICATION
                cursor.execute(
                    """
                    INSERT INTO users
                        (email, password_hash, full_name, phone, terms_accepted_at,
                         edition, plan_code, account_type, email_verified)
                    VALUES (%s, %s, %s, %s, now(), 'partner', 'partner', 'partner', %s)
                    RETURNING id
                    """,
                    (email, hash_password(request.password), request.responsibleName.strip(), request.phone.strip(), verified),
                )
                user_id = cursor.fetchone()[0]
            cursor.execute(
                "INSERT INTO user_roles (user_id, role) VALUES (%s, 'partner') ON CONFLICT DO NOTHING",
                (user_id,),
            )
            cursor.execute("SELECT 1 FROM partner_profiles WHERE cnpj = %s", (normalized_cnpj,))
            if cursor.fetchone() is not None:
                raise HTTPException(status_code=409, detail="CPF/CNPJ já cadastrado.")
            cursor.execute(
                """
                INSERT INTO partner_profiles
                    (owner_user_id, name, partner_type, cnpj, phone, whatsapp, email, address,
                     postal_code, city, state, latitude, longitude, services, accepts_urgency,
                     status, verification_status)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'pending', 'pending')
                RETURNING id
                """,
                (
                    user_id, request.businessName.strip(), partner_type, normalized_cnpj,
                    request.phone.strip(), request.whatsapp.strip(), email, request.address.strip(), request.postalCode.strip(),
                    request.city.strip(), request.state.strip(), request.latitude, request.longitude,
                    psycopg.types.json.Jsonb([value.strip() for value in request.services if value.strip()]),
                    request.acceptsUrgency,
                ),
            )
            partner_id = cursor.fetchone()[0]
            cursor.execute(
                """
                INSERT INTO partner_professionals
                    (partner_id, full_name, cpf, crmv_uf, crmv_number, art_number,
                     is_responsible_technical, verification_status)
                VALUES (%s, %s, %s, %s, %s, %s, TRUE, 'pending')
                """,
                (
                    partner_id, request.responsibleName.strip(), responsible_cpf,
                    request.crmvUf.strip().upper(), request.crmvNumber.strip(), request.artNumber.strip(),
                ),
            )
            cursor.execute(
                """
                INSERT INTO entitlements (user_id, entitlement_key, source, status)
                VALUES (%s, 'partner_access', 'account_registration', 'pending')
                ON CONFLICT (user_id, entitlement_key) DO NOTHING
                """,
                (user_id,),
            )
    verified = existing_account or not REQUIRE_EMAIL_VERIFICATION
    if not verified:
        try:
            token, expires_at = issue_email_verification_token(user_id)
            send_email_verification(email, first_name_from_full_name(request.responsibleName), token, expires_at)
        except (OSError, smtplib.SMTPException, RuntimeError) as error:
            logger.exception("partner_email_verification_requested user_id=%s email_sent=false", user_id)
            raise HTTPException(status_code=503, detail="Não foi possível enviar o e-mail de confirmação agora.") from error
        return {
            "status": "verification_required",
            "email": email,
            "partnerId": partner_id,
            "message": "Cadastro de parceiro criado. Confirme o e-mail e contrate a assinatura para publicar o perfil.",
        }
    session = create_auth_session(user_id, email)
    session.update(
        {
            "status": "authenticated",
            "email": email,
            "partnerId": partner_id,
            "profileLinked": "true" if existing_account else "false",
        }
    )
    return session


@app.post("/partner/profile/request")
def request_partner_profile(
    request: PartnerProfileRequest,
    user: dict[str, Any] = Depends(current_user),
) -> dict[str, Any]:
    """Creates the partner profile for an already authenticated client account."""
    if not request.termsAccepted:
        raise HTTPException(status_code=400, detail="Aceite os Termos de Uso e a Política de Privacidade.")
    if (request.latitude is None) != (request.longitude is None):
        raise HTTPException(status_code=400, detail="Latitude e longitude devem ser informadas juntas.")
    normalized_document = normalize_document(request.cnpj, document_type=request.documentType)
    responsible_cpf = normalize_document(
        request.responsibleCpf,
        required=False,
        document_type="cpf",
    )
    user_id = int(user["sub"])
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT email, is_active, email_verified FROM users WHERE id = %s",
                (user_id,),
            )
            account = cursor.fetchone()
            if account is None or not account[1]:
                raise HTTPException(status_code=403, detail="Esta conta está desativada.")
            if REQUIRE_EMAIL_VERIFICATION and not account[2]:
                raise HTTPException(status_code=403, detail="Confirme o e-mail da conta antes de cadastrar o perfil parceiro.")
            cursor.execute(
                "SELECT id FROM partner_profiles WHERE owner_user_id = %s",
                (user_id,),
            )
            if cursor.fetchone() is not None:
                raise HTTPException(status_code=409, detail="O perfil parceiro desta conta já foi cadastrado.")
            cursor.execute(
                "SELECT id FROM partner_profiles WHERE cnpj = %s",
                (normalized_document,),
            )
            if cursor.fetchone() is not None:
                raise HTTPException(status_code=409, detail="CPF/CNPJ já cadastrado.")
            cursor.execute(
                "INSERT INTO user_roles (user_id, role) VALUES (%s, 'partner') ON CONFLICT DO NOTHING",
                (user_id,),
            )
            cursor.execute(
                """
                INSERT INTO partner_profiles
                    (owner_user_id, name, partner_type, cnpj, phone, whatsapp, email, address,
                     postal_code, city, state, latitude, longitude, services, accepts_urgency,
                     status, verification_status)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                        'pending', 'pending')
                RETURNING id
                """,
                (
                    user_id,
                    request.businessName.strip(),
                    request.partnerType.strip().lower(),
                    normalized_document,
                    request.phone.strip(),
                    request.whatsapp.strip(),
                    account[0],
                    request.address.strip(),
                    request.postalCode.strip(),
                    request.city.strip(),
                    request.state.strip().upper(),
                    request.latitude,
                    request.longitude,
                    psycopg.types.json.Jsonb([value.strip() for value in request.services if value.strip()]),
                    request.acceptsUrgency,
                ),
            )
            partner_id = cursor.fetchone()[0]
            cursor.execute(
                """
                INSERT INTO partner_professionals
                    (partner_id, full_name, cpf, crmv_uf, crmv_number, art_number,
                     is_responsible_technical, verification_status)
                VALUES (%s, %s, %s, %s, %s, %s, TRUE, 'pending')
                """,
                (
                    partner_id,
                    request.responsibleName.strip(),
                    responsible_cpf,
                    request.crmvUf.strip().upper(),
                    request.crmvNumber.strip(),
                    request.artNumber.strip(),
                ),
            )
            cursor.execute(
                """
                INSERT INTO entitlements (user_id, entitlement_key, source, status)
                VALUES (%s, 'partner_access', 'account_registration', 'pending')
                ON CONFLICT (user_id, entitlement_key) DO NOTHING
                """,
                (user_id,),
            )
    return {
        "partnerId": partner_id,
        "status": "pending",
        "verificationStatus": "pending",
        "message": "Cadastro enviado para análise. O perfil ficará oculto até a aprovação.",
    }


@app.post("/auth/verify-email")
def verify_email(request: EmailVerificationRequest) -> dict[str, Any]:
    email = request.email.strip().lower()
    token_hash = hash_email_verification_token(request.token.strip())
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT tokens.id, users.id, users.email
                FROM email_verification_tokens AS tokens
                JOIN users ON users.id = tokens.user_id
                WHERE users.email = %s
                  AND tokens.token_hash = %s
                  AND tokens.used_at IS NULL
                  AND tokens.expires_at > now()
                """,
                (email, token_hash),
            )
            verification = cursor.fetchone()
            if verification is None:
                raise HTTPException(status_code=400, detail="Token de confirmação inválido ou expirado.")
            cursor.execute("UPDATE users SET email_verified = TRUE WHERE id = %s", (verification[1],))
            cursor.execute("UPDATE email_verification_tokens SET used_at = now() WHERE id = %s", (verification[0],))
    session = create_auth_session(verification[1], verification[2])
    session.update({"status": "authenticated", "email": verification[2]})
    return session


@app.post("/auth/password-reset/request")
def request_password_reset(request: PasswordResetRequest) -> dict[str, str]:
    email = request.email.strip().lower()
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT id, is_active, full_name FROM users WHERE email = %s",
                (email,),
            )
            user = cursor.fetchone()
    if user is not None and user[1]:
        token, expires_at = issue_password_reset_token(user[0])
        try:
            send_password_reset_email(
                email,
                first_name_from_full_name(user[2]),
                token,
                expires_at,
            )
            logger.info("password_reset_requested user_id=%s email_sent=true", user[0])
        except (OSError, smtplib.SMTPException, RuntimeError):
            logger.exception("password_reset_requested user_id=%s email_sent=false", user[0])
    return {"message": "Se o e-mail estiver cadastrado, as instruções serão enviadas."}


@app.post("/auth/password-reset/confirm")
def confirm_password_reset(request: PasswordResetConfirm) -> dict[str, str]:
    token_hash = hash_password_reset_token(request.token)
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, user_id
                FROM password_reset_tokens
                WHERE token_hash = %s AND used_at IS NULL AND expires_at > now()
                """,
                (token_hash,),
            )
            reset = cursor.fetchone()
            if reset is None:
                raise HTTPException(status_code=400, detail="Token de recuperação inválido ou expirado.")
            cursor.execute(
                "UPDATE users SET password_hash = %s, is_active = TRUE WHERE id = %s",
                (hash_password(request.newPassword), reset[1]),
            )
            cursor.execute("UPDATE password_reset_tokens SET used_at = now() WHERE id = %s", (reset[0],))
            cursor.execute("UPDATE auth_sessions SET revoked_at = now() WHERE user_id = %s AND revoked_at IS NULL", (reset[1],))
    return {"status": "ok", "message": "Senha atualizada. Faça login novamente."}


@app.post("/auth/refresh")
def refresh(request: RefreshRequest) -> dict[str, str]:
    refresh_hash = hash_refresh_token(request.refreshToken)
    now = utc_now()
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT sessions.id, sessions.user_id, users.email, sessions.mfa_verified
                FROM auth_sessions AS sessions
                JOIN users ON users.id = sessions.user_id
                WHERE sessions.refresh_token_hash = %s
                  AND sessions.revoked_at IS NULL
                  AND sessions.refresh_expires_at > %s
                """,
                (refresh_hash, now),
            )
            session = cursor.fetchone()
            if session is None:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Refresh token inválido ou expirado.",
                )
            cursor.execute(
                "UPDATE auth_sessions SET revoked_at = %s WHERE id = %s",
                (now, session[0]),
            )
    return create_auth_session(session[1], session[2], mfa_verified=bool(session[3]))


@app.post("/auth/logout")
def logout(user: dict[str, Any] = Depends(current_user)) -> dict[str, str]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "UPDATE auth_sessions SET revoked_at = now() WHERE jti = %s",
                (user["jti"],),
            )
    return {"status": "ok"}


@app.post("/account/delete")
def delete_account(
    request: AccountDeletionRequest,
    user: dict[str, Any] = Depends(current_user),
) -> dict[str, str]:
    if request.confirmation.strip().upper() != "EXCLUIR":
        raise HTTPException(status_code=400, detail="Digite EXCLUIR para confirmar.")
    user_id = int(user["sub"])
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT password_hash, is_admin, deleted_at FROM users WHERE id = %s FOR UPDATE",
                (user_id,),
            )
            account = cursor.fetchone()
            if account is None or account[2] is not None:
                raise HTTPException(status_code=404, detail="Conta não encontrada.")
            if account[1]:
                raise HTTPException(
                    status_code=403,
                    detail="Contas administrativas não podem ser excluídas por este fluxo.",
                )
            if not check_password(request.password, account[0]):
                raise HTTPException(status_code=401, detail="Senha incorreta.")
            document_storage_keys = delete_account_data(
                cursor,
                user_id=user_id,
                password_hash=hash_password(secrets.token_urlsafe(48)),
            )
    for storage_key in document_storage_keys:
        try:
            resolve_storage_path(PARTNER_DOCUMENTS_DIR, storage_key).unlink(missing_ok=True)
        except (InvalidDocument, OSError) as error:
            logger.warning(
                "account_deletion_document_cleanup_failed user_id=%s key=%s error=%s",
                user_id,
                storage_key,
                error,
            )
    return {"status": "deleted"}


@app.get("/account/status")
def account_status(user: dict[str, Any] = Depends(current_user)) -> dict[str, Any]:
    user_id = int(user["sub"])
    reconciled_orders = _reconcile_mercadopago_orders(user_id)
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT users.edition, users.plan_code,
                       entitlements.status, entitlements.valid_until,
                       subscriptions.status, subscriptions.expires_at,
                       users.full_name
                FROM users
                LEFT JOIN entitlements
                  ON entitlements.user_id = users.id
                 AND entitlements.entitlement_key = 'family_access'
                LEFT JOIN LATERAL (
                    SELECT status, expires_at
                    FROM subscriptions
                    WHERE user_id = users.id
                    ORDER BY updated_at DESC
                    LIMIT 1
                ) AS subscriptions ON TRUE
                WHERE users.id = %s
                """,
                (user_id,),
            )
            account = cursor.fetchone()
    if account is None:
        raise HTTPException(status_code=404, detail="Conta não encontrada.")
    entitlement_status = account[2] or "none"
    if account[3] and account[3] <= utc_now():
        entitlement_status = "expired"
    return {
        "registeredName": account[6],
        "edition": account[0],
        "plan": account[1],
        "entitlement": {
            "key": "family_access",
            "status": entitlement_status,
            "validUntil": account[3].isoformat() if account[3] else None,
        },
        "subscription": {
            "status": account[4],
            "expiresAt": account[5].isoformat() if account[5] else None,
        },
        "reconciledPayments": reconciled_orders,
    }


@app.get("/account/address")
def get_account_address(user: dict[str, Any] = Depends(current_user)) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT country, state, city, postal_code, street, number,
                       complement, neighborhood, reference, latitude, longitude,
                       accuracy, source, allow_vet_visit, consent_version,
                       consent_at, updated_at
                FROM user_addresses
                WHERE user_id = %s
                """,
                (int(user["sub"]),),
            )
            address = cursor.fetchone()
    if address is None:
        return {"address": None}
    return {
        "address": {
            "country": address[0],
            "state": address[1],
            "city": address[2],
            "postalCode": address[3],
            "street": address[4],
            "number": address[5],
            "complement": address[6],
            "neighborhood": address[7],
            "reference": address[8],
            "latitude": address[9],
            "longitude": address[10],
            "accuracy": address[11],
            "source": address[12],
            "allowVetVisit": address[13],
            "consentVersion": address[14],
            "consentAt": address[15].isoformat(),
            "updatedAt": address[16].isoformat(),
        }
    }


@app.put("/account/address")
def save_account_address(
    request: AddressRequest,
    user: dict[str, Any] = Depends(current_user),
) -> dict[str, Any]:
    if (request.latitude is None) != (request.longitude is None):
        raise HTTPException(
            status_code=400,
            detail="Latitude e longitude devem ser informadas juntas.",
        )
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO user_addresses
                    (user_id, country, state, city, postal_code, street, number,
                     complement, neighborhood, reference, latitude, longitude,
                     accuracy, source, allow_vet_visit, consent_version,
                     consent_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                        %s, %s, %s, %s, now(), now())
                ON CONFLICT (user_id) DO UPDATE SET
                    country = EXCLUDED.country,
                    state = EXCLUDED.state,
                    city = EXCLUDED.city,
                    postal_code = EXCLUDED.postal_code,
                    street = EXCLUDED.street,
                    number = EXCLUDED.number,
                    complement = EXCLUDED.complement,
                    neighborhood = EXCLUDED.neighborhood,
                    reference = EXCLUDED.reference,
                    latitude = EXCLUDED.latitude,
                    longitude = EXCLUDED.longitude,
                    accuracy = EXCLUDED.accuracy,
                    source = EXCLUDED.source,
                    allow_vet_visit = EXCLUDED.allow_vet_visit,
                    consent_version = EXCLUDED.consent_version,
                    consent_at = now(),
                    updated_at = now()
                RETURNING updated_at
                """,
                (
                    int(user["sub"]), request.country.strip(), request.state.strip(),
                    request.city.strip(), request.postalCode.strip(),
                    request.street.strip(), request.number.strip(),
                    request.complement.strip(), request.neighborhood.strip(),
                    request.reference.strip(), request.latitude, request.longitude,
                    request.accuracy, request.source.strip(), request.allowVetVisit,
                    request.consentVersion.strip(),
                ),
            )
            updated_at = cursor.fetchone()[0]
    return {"status": "ok", "updatedAt": updated_at.isoformat()}


@app.get("/family/invitations")
def list_family_invitations(user: dict[str, Any] = Depends(require_family)) -> dict[str, Any]:
    user_id = int(user["sub"])
    email = str(user.get("email", "")).strip().lower()
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT invitations.id, invitations.owner_user_id,
                       owner.full_name, invitations.invitee_email,
                       invitations.pet_ref, invitations.pet_name,
                       invitations.role, invitations.permissions,
                       invitations.status, invitations.expires_at,
                       invitations.invited_at, invitations.accepted_at
                FROM family_invitations AS invitations
                JOIN users AS owner ON owner.id = invitations.owner_user_id
                WHERE invitations.owner_user_id = %s
                   OR invitations.invitee_email = %s
                ORDER BY invitations.invited_at DESC
                """,
                (user_id, email),
            )
            invitations = cursor.fetchall()
    return {
        "invitations": [
            {
                "id": item[0],
                "ownerUserId": item[1],
                "ownerName": item[2],
                "inviteeEmail": item[3],
                "petId": item[4],
                "petName": item[5],
                "role": item[6],
                "permissions": item[7] or [],
                "status": item[8],
                "expiresAt": item[9].isoformat(),
                "invitedAt": item[10].isoformat(),
                "acceptedAt": item[11].isoformat() if item[11] else None,
            }
            for item in invitations
        ]
    }


@app.post("/family/invitations")
def create_family_invitation(
    request: FamilyInvitationRequest,
    user: dict[str, Any] = Depends(require_family),
) -> dict[str, Any]:
    user_id = int(user["sub"])
    invitee_email = request.inviteeEmail.strip().lower()
    current_email = str(user.get("email", "")).strip().lower()
    if invitee_email == current_email:
        raise HTTPException(status_code=400, detail="Não é possível convidar a própria conta.")
    permissions = list(dict.fromkeys(permission.strip() for permission in request.permissions if permission.strip()))
    expires_at = utc_now() + timedelta(days=request.expiresInDays)
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT full_name
                FROM users
                WHERE id = %s
                """,
                (user_id,),
            )
            owner = cursor.fetchone()
            cursor.execute(
                """
                INSERT INTO family_invitations
                    (owner_user_id, invitee_email, pet_ref, pet_name,
                     role, permissions, expires_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                RETURNING id, invited_at
                """,
                (
                    user_id,
                    invitee_email,
                    request.petId.strip(),
                    request.petName.strip(),
                    request.role.strip().lower(),
                    psycopg.types.json.Jsonb(permissions),
                    expires_at,
                ),
            )
            invitation_id, invited_at = cursor.fetchone()
    email_sent = False
    try:
        send_family_invitation_email(
            recipient=invitee_email,
            owner_name=owner[0] if owner else "",
            pet_name=request.petName.strip(),
            invitation_id=invitation_id,
            expires_at=expires_at,
        )
        email_sent = True
    except (OSError, smtplib.SMTPException, RuntimeError) as error:
        logger.warning("family_invitation_email_failed invitation_id=%s error=%s", invitation_id, error)
    return {
        "id": invitation_id,
        "status": "pending",
        "emailSent": email_sent,
        "expiresAt": expires_at.isoformat(),
        "invitedAt": invited_at.isoformat(),
    }


@app.post("/family/invitations/{invitation_id}/accept")
def accept_family_invitation(
    invitation_id: int,
    user: dict[str, Any] = Depends(require_family),
) -> dict[str, Any]:
    user_id = int(user["sub"])
    email = str(user.get("email", "")).strip().lower()
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT owner_user_id, invitee_email, pet_ref, pet_name,
                       role, permissions, status, expires_at
                FROM family_invitations
                WHERE id = %s
                FOR UPDATE
                """,
                (invitation_id,),
            )
            invitation = cursor.fetchone()
            if invitation is None:
                raise HTTPException(status_code=404, detail="Convite não encontrado.")
            if invitation[1] != email:
                raise HTTPException(status_code=403, detail="Este convite não pertence ao e-mail da sessão.")
            if invitation[6] != "pending":
                raise HTTPException(status_code=409, detail="Este convite não está pendente.")
            if invitation[7] <= utc_now():
                cursor.execute(
                    "UPDATE family_invitations SET status = 'expired', updated_at = now() WHERE id = %s",
                    (invitation_id,),
                )
                raise HTTPException(status_code=410, detail="Este convite expirou.")
            cursor.execute(
                """
                INSERT INTO family_access_grants
                    (owner_user_id, member_user_id, pet_ref, pet_name,
                     role, permissions, status, expires_at)
                VALUES (%s, %s, %s, %s, %s, %s, 'active', %s)
                ON CONFLICT (owner_user_id, member_user_id, pet_ref) DO UPDATE SET
                    pet_name = EXCLUDED.pet_name,
                    role = EXCLUDED.role,
                    permissions = EXCLUDED.permissions,
                    status = 'active',
                    expires_at = EXCLUDED.expires_at,
                    updated_at = now()
                RETURNING id
                """,
                (
                    invitation[0],
                    user_id,
                    invitation[2],
                    invitation[3],
                    invitation[4],
                    invitation[5],
                    invitation[7] if invitation[4] == "clinic" else None,
                ),
            )
            grant_id = cursor.fetchone()[0]
            cursor.execute(
                """
                UPDATE family_invitations
                SET status = 'accepted', accepted_by_user_id = %s,
                    accepted_at = now(), updated_at = now()
                WHERE id = %s
                """,
                (user_id, invitation_id),
            )
    return {"status": "accepted", "grantId": grant_id, "invitationId": invitation_id}


@app.delete("/family/invitations/{invitation_id}")
def cancel_family_invitation(
    invitation_id: int,
    user: dict[str, Any] = Depends(require_family),
) -> dict[str, str]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE family_invitations
                SET status = 'cancelled', updated_at = now()
                WHERE id = %s AND owner_user_id = %s AND status = 'pending'
                """,
                (invitation_id, int(user["sub"])),
            )
            if cursor.rowcount == 0:
                raise HTTPException(status_code=404, detail="Convite pendente não encontrado.")
    return {"status": "cancelled"}


@app.get("/family/access")
def list_family_access(user: dict[str, Any] = Depends(require_family)) -> dict[str, Any]:
    user_id = int(user["sub"])
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT grants.id, grants.owner_user_id, owner.full_name,
                       grants.member_user_id, member.full_name,
                       grants.pet_ref, grants.pet_name, grants.role,
                       grants.permissions, grants.status, grants.expires_at,
                       grants.created_at
                FROM family_access_grants AS grants
                JOIN users AS owner ON owner.id = grants.owner_user_id
                JOIN users AS member ON member.id = grants.member_user_id
                WHERE (grants.owner_user_id = %s OR grants.member_user_id = %s)
                  AND grants.status = 'active'
                  AND (grants.expires_at IS NULL OR grants.expires_at > now())
                ORDER BY grants.created_at DESC
                """,
                (user_id, user_id),
            )
            grants = cursor.fetchall()
    return {
        "access": [
            {
                "id": item[0],
                "ownerUserId": item[1],
                "ownerName": item[2],
                "memberUserId": item[3],
                "memberName": item[4],
                "petId": item[5],
                "petName": item[6],
                "role": item[7],
                "permissions": item[8] or [],
                "status": item[9],
                "expiresAt": item[10].isoformat() if item[10] else None,
                "createdAt": item[11].isoformat(),
            }
            for item in grants
        ]
    }


def _partner_response(item: tuple[Any, ...], distance_km: float | None = None) -> dict[str, Any]:
    return {
        "id": item[0],
        "name": item[1],
        "partnerType": item[2],
        "phone": item[3],
        "whatsapp": item[4],
        "email": item[5],
        "address": item[6],
        "city": item[7],
        "state": item[8],
        "latitude": item[9],
        "longitude": item[10],
        "services": item[11] or [],
        "acceptsUrgency": item[12],
        "distanceKm": round(distance_km, 2) if distance_km is not None else None,
    }


@app.get("/partner/profile")
def get_partner_profile(user: dict[str, Any] = Depends(current_partner)) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, name, partner_type, phone, whatsapp, email, address,
                       city, state, latitude, longitude, services, accepts_urgency, status, postal_code, cnpj,
                       verification_status, verified_at
                FROM partner_profiles
                WHERE id = %s AND owner_user_id = %s
                """,
                (user["partner_id"], int(user["sub"])),
            )
            profile = cursor.fetchone()
            cursor.execute(
                """
                SELECT full_name, cpf, crmv_uf, crmv_number, art_number,
                       is_responsible_technical, verification_status
                FROM partner_professionals
                WHERE partner_id = %s AND is_responsible_technical IS TRUE
                ORDER BY id
                LIMIT 1
                """,
                (user["partner_id"],),
            )
            professional = cursor.fetchone()
            cursor.execute(
                """
                SELECT status, valid_until
                FROM entitlements
                WHERE user_id = %s AND entitlement_key = 'partner_access'
                """,
                (int(user["sub"]),),
            )
            entitlement = cursor.fetchone()
    if profile is None:
        raise HTTPException(status_code=404, detail="Perfil de parceiro não encontrado.")
    return {
        "profile": _partner_response(profile[0:13]),
        "status": profile[13],
        "postalCode": profile[14],
        "cnpj": profile[15],
        "verificationStatus": profile[16],
        "verifiedAt": profile[17].isoformat() if profile[17] else None,
        "responsibleProfessional": {
            "name": professional[0],
            "cpf": professional[1],
            "crmvUf": professional[2],
            "crmvNumber": professional[3],
            "artNumber": professional[4],
            "isResponsibleTechnical": professional[5],
            "verificationStatus": professional[6],
        } if professional else None,
        "subscription": {
            "status": entitlement[0] if entitlement else "pending",
            "validUntil": entitlement[1].isoformat() if entitlement and entitlement[1] else None,
        },
    }


@app.get("/partner/documents")
def list_partner_documents(user: dict[str, Any] = Depends(current_partner)) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, professional_id, document_type, file_name, mime_type,
                       document_hash, verification_status, rejection_reason,
                       created_at, reviewed_at
                FROM partner_documents
                WHERE partner_id = %s
                ORDER BY created_at DESC
                """,
                (user["partner_id"],),
            )
            documents = cursor.fetchall()
    return {
        "documents": [
            {
                "id": item[0],
                "professionalId": item[1],
                "documentType": item[2],
                "fileName": item[3],
                "mimeType": item[4],
                "documentHash": item[5],
                "verificationStatus": item[6],
                "rejectionReason": item[7] or "",
                "createdAt": item[8].isoformat(),
                "reviewedAt": item[9].isoformat() if item[9] else None,
                "contentUrl": f"/partner/documents/{item[0]}/content",
            }
            for item in documents
        ]
    }


def _document_requirements(documents: list[tuple[Any, ...]]) -> dict[str, Any]:
    approved_types = {
        item[1]
        for item in documents
        if item[2] == "approved"
    }
    pending_types = {
        item[1]
        for item in documents
        if item[2] == "pending"
    }
    rejected_types = {
        item[1]
        for item in documents
        if item[2] == "rejected"
    }
    missing = [
        {"type": document_type, "label": label}
        for document_type, label in REQUIRED_PARTNER_DOCUMENTS.items()
        if document_type not in approved_types
    ]
    return {
        "required": [
            {"type": document_type, "label": label}
            for document_type, label in REQUIRED_PARTNER_DOCUMENTS.items()
        ],
        "missing": missing,
        "pendingTypes": sorted(pending_types),
        "rejectedTypes": sorted(rejected_types),
        "readyForApproval": not missing,
    }


@app.get("/admin/partners/{partner_id}/documents")
def list_admin_partner_documents(
    partner_id: int,
    _: dict[str, Any] = Depends(current_admin),
) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT p.id, p.name, p.partner_type, p.cnpj, p.email, p.status,
                       p.verification_status
                FROM partner_profiles AS p
                WHERE p.id = %s
                """,
                (partner_id,),
            )
            partner = cursor.fetchone()
            if partner is None:
                raise HTTPException(status_code=404, detail="Parceiro não encontrado.")
            cursor.execute(
                """
                SELECT d.id, d.document_type, d.file_name, d.mime_type,
                       d.document_hash, d.verification_status, d.rejection_reason,
                       d.created_at, d.reviewed_at, d.reviewed_by, u.email
                FROM partner_documents AS d
                LEFT JOIN users AS u ON u.id = d.reviewed_by
                WHERE d.partner_id = %s
                ORDER BY d.created_at DESC
                """,
                (partner_id,),
            )
            documents = cursor.fetchall()
    return {
        "partner": {
            "id": partner[0],
            "name": partner[1],
            "partnerType": partner[2],
            "document": partner[3],
            "email": partner[4],
            "status": partner[5],
            "verificationStatus": partner[6],
        },
        "requirements": _document_requirements(documents),
        "documents": [
            {
                "id": item[0],
                "documentType": item[1],
                "fileName": item[2],
                "mimeType": item[3],
                "documentHash": item[4],
                "verificationStatus": item[5],
                "rejectionReason": item[6] or "",
                "createdAt": item[7].isoformat(),
                "reviewedAt": item[8].isoformat() if item[8] else None,
                "reviewedBy": item[10] or "",
                "contentUrl": f"/admin/partner-documents/{item[0]}/content",
            }
            for item in documents
        ],
    }


@app.get("/admin/partner-documents/{document_id}/content")
def download_admin_partner_document(
    document_id: int,
    admin: dict[str, Any] = Depends(current_admin),
) -> FileResponse:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT storage_key, file_name, mime_type, partner_id
                FROM partner_documents
                WHERE id = %s
                """,
                (document_id,),
            )
            document = cursor.fetchone()
            if document is not None:
                cursor.execute(
                    """
                    INSERT INTO partner_document_access_audits
                        (document_id, partner_id, actor_user_id, action)
                    VALUES (%s, %s, %s, 'admin_download')
                    """,
                    (document_id, document[3], int(admin["sub"])),
                )
    return _protected_document_response(document)


def _protected_document_response(document: tuple[Any, ...] | None) -> FileResponse:
    if document is None:
        raise HTTPException(status_code=404, detail="Documento não encontrado.")
    try:
        storage_path = resolve_storage_path(PARTNER_DOCUMENTS_DIR, document[0])
    except InvalidDocument as error:
        logger.error("document_storage_path_rejected storage_key=%r", document[0])
        raise HTTPException(status_code=404, detail="Documento não encontrado.") from error
    if not os.path.isfile(storage_path):
        raise HTTPException(status_code=404, detail="Arquivo do documento não encontrado.")
    with open(storage_path, "rb") as document_file:
        header = document_file.read(16)
    try:
        detected_mime = detect_document_mime(header)
        download_name = safe_document_name(document[1] or "documento")
    except InvalidDocument as error:
        logger.error("document_content_rejected storage_key=%r", document[0])
        raise HTTPException(status_code=415, detail="Formato de documento não permitido.") from error
    return FileResponse(
        storage_path,
        media_type=detected_mime,
        filename=download_name,
        content_disposition_type="attachment",
        headers={
            "Cache-Control": "private, no-store, max-age=0",
            "Pragma": "no-cache",
            "X-Content-Type-Options": "nosniff",
        },
    )


@app.get("/partner/documents/{document_id}/content")
def download_own_partner_document(
    document_id: int,
    user: dict[str, Any] = Depends(current_partner),
) -> FileResponse:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT storage_key, file_name, mime_type, partner_id
                FROM partner_documents
                WHERE id = %s AND partner_id = %s
                """,
                (document_id, user["partner_id"]),
            )
            document = cursor.fetchone()
            if document is not None:
                cursor.execute(
                    """
                    INSERT INTO partner_document_access_audits
                        (document_id, partner_id, actor_user_id, action)
                    VALUES (%s, %s, %s, 'partner_download')
                    """,
                    (document_id, user["partner_id"], int(user["sub"])),
                )
    return _protected_document_response(document)


@app.post("/partner/documents")
def upload_partner_document(
    request: PartnerDocumentRequest,
    user: dict[str, Any] = Depends(current_partner),
) -> dict[str, Any]:
    try:
        content = base64.b64decode(request.contentBase64, validate=True)
    except (ValueError, base64.binascii.Error) as error:
        raise HTTPException(status_code=400, detail="Arquivo profissional inválido.") from error
    if not content or len(content) > 8 * 1024 * 1024:
        raise HTTPException(status_code=413, detail="O documento deve ter até 8 MB.")
    try:
        document_type = validate_document_type(request.documentType)
        safe_name, detected_mime = validate_document(
            content,
            request.fileName,
            request.mimeType,
        )
    except InvalidDocument as error:
        raise HTTPException(status_code=422, detail=str(error)) from error
    document_hash = hashlib.sha256(content).hexdigest()
    storage_key = f"{user['partner_id']}/{uuid.uuid4().hex}-{safe_name}"
    storage_path = resolve_storage_path(PARTNER_DOCUMENTS_DIR, storage_key)
    partner_directory = os.path.dirname(storage_path)
    os.makedirs(partner_directory, mode=0o700, exist_ok=True)
    file_descriptor = os.open(storage_path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    try:
        with os.fdopen(file_descriptor, "wb") as document_file:
            document_file.write(content)
            document_file.flush()
            os.fsync(document_file.fileno())
        with database_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO partner_documents
                        (partner_id, document_type, storage_key, document_hash,
                         file_name, mime_type, verification_status)
                    VALUES (%s, %s, %s, %s, %s, %s, 'pending')
                    RETURNING id, created_at
                    """,
                    (
                        user["partner_id"], document_type, storage_key,
                        document_hash, safe_name, detected_mime,
                    ),
                )
                document_id, created_at = cursor.fetchone()
                cursor.execute(
                    """
                    INSERT INTO partner_document_access_audits
                        (document_id, partner_id, actor_user_id, action)
                    VALUES (%s, %s, %s, 'upload')
                    """,
                    (document_id, user["partner_id"], int(user["sub"])),
                )
    except Exception:
        try:
            os.unlink(storage_path)
        except FileNotFoundError:
            pass
        raise
    return {
        "id": document_id,
        "documentType": document_type,
        "documentHash": document_hash,
        "verificationStatus": "pending",
        "createdAt": created_at.isoformat(),
    }


@app.put("/partner/profile")
def update_partner_profile(
    request: PartnerProfileUpdateRequest,
    user: dict[str, Any] = Depends(current_partner),
) -> dict[str, Any]:
    if (request.latitude is None) != (request.longitude is None):
        raise HTTPException(status_code=400, detail="Latitude e longitude devem ser informadas juntas.")
    normalized_cnpj = normalize_document(
        request.cnpj,
        document_type=request.documentType,
    )
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE partner_profiles
                SET name = %s, partner_type = %s, cnpj = %s, phone = %s, whatsapp = %s,
                    address = %s, postal_code = %s, city = %s, state = %s, latitude = %s, longitude = %s,
                    services = %s, accepts_urgency = %s, updated_at = now()
                WHERE id = %s AND owner_user_id = %s
                RETURNING id, name, partner_type, phone, whatsapp, email, address,
                          city, state, latitude, longitude, services, accepts_urgency, status, postal_code, cnpj
                """,
                (
                    request.businessName.strip(), request.partnerType.strip().lower(), normalized_cnpj, request.phone.strip(),
                    request.whatsapp.strip(), request.address.strip(), request.postalCode.strip(), request.city.strip(), request.state.strip(),
                    request.latitude, request.longitude,
                    psycopg.types.json.Jsonb([value.strip() for value in request.services if value.strip()]),
                    request.acceptsUrgency, user["partner_id"], int(user["sub"]),
                ),
            )
            profile = cursor.fetchone()
            cursor.execute(
                """
                UPDATE partner_professionals
                SET full_name = %s, cpf = %s, crmv_uf = %s, crmv_number = %s,
                    art_number = %s, updated_at = now()
                WHERE partner_id = %s AND is_responsible_technical IS TRUE
                """,
                (
                    (request.responsibleName.strip() or request.businessName.strip()),
                    normalize_document(request.responsibleCpf, required=False, document_type="cpf"),
                    request.crmvUf.strip().upper(), request.crmvNumber.strip(), request.artNumber.strip(),
                    user["partner_id"],
                ),
            )
            if cursor.rowcount == 0:
                cursor.execute(
                    """
                    INSERT INTO partner_professionals
                        (partner_id, full_name, cpf, crmv_uf, crmv_number, art_number,
                         is_responsible_technical, verification_status)
                    VALUES (%s, %s, %s, %s, %s, %s, TRUE, 'pending')
                    """,
                    (
                        user["partner_id"], (request.responsibleName.strip() or request.businessName.strip()),
                        normalize_document(request.responsibleCpf, required=False, document_type="cpf"),
                        request.crmvUf.strip().upper(), request.crmvNumber.strip(), request.artNumber.strip(),
                    ),
                )
    if profile is None:
        raise HTTPException(status_code=404, detail="Perfil de parceiro não encontrado.")
    return {"profile": _partner_response(profile[0:13]), "status": profile[13], "postalCode": profile[14], "cnpj": profile[15]}


@app.get("/partner/dashboard")
def partner_dashboard(user: dict[str, Any] = Depends(require_partner_access)) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT COUNT(*) FILTER (WHERE status = 'requested'),
                       COUNT(*) FILTER (WHERE status = 'confirmed'),
                       COUNT(*) FILTER (WHERE scheduled_at::date = CURRENT_DATE)
                FROM appointments
                WHERE partner_id = %s
                """,
                (user["partner_id"],),
            )
            counters = cursor.fetchone()
            cursor.execute(
                """
                SELECT appointments.id, appointments.pet_name, appointments.service,
                       appointments.scheduled_at, appointments.status
                FROM appointments
                WHERE partner_id = %s
                ORDER BY scheduled_at DESC
                LIMIT 50
                """,
                (user["partner_id"],),
            )
            appointments = cursor.fetchall()
    return {
        "counters": {"requested": counters[0], "confirmed": counters[1], "today": counters[2]},
        "appointments": [
            {
                "id": item[0], "petName": item[1], "service": item[2],
                "scheduledAt": item[3].isoformat(), "status": item[4],
            }
            for item in appointments
        ],
    }


@app.get("/partners")
def list_partners(
    latitude: float | None = Query(default=None, ge=-90, le=90),
    longitude: float | None = Query(default=None, ge=-180, le=180),
    urgency: bool = Query(default=False),
    service: str | None = Query(default=None, max_length=120),
    radiusKm: float = Query(default=100.0, gt=0, le=500),
) -> dict[str, Any]:
    if (latitude is None) != (longitude is None):
        raise HTTPException(status_code=400, detail="Latitude e longitude devem ser informadas juntas.")
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, name, partner_type, phone, whatsapp, email,
                       address, city, state, latitude, longitude, services,
                       accepts_urgency
                FROM partner_profiles
                WHERE status = 'active' AND verification_status = 'approved'
                ORDER BY name
                """
            )
            partners = cursor.fetchall()
    results: list[tuple[float, dict[str, Any]]] = []
    normalized_service = service.strip().lower() if service else None
    for item in partners:
        if urgency and not item[12]:
            continue
        services = [str(value) for value in (item[11] or [])]
        if normalized_service and not any(normalized_service in value.lower() for value in services):
            continue
        distance_km = None
        if latitude is not None and item[9] is not None and item[10] is not None:
            phi1, phi2 = math.radians(latitude), math.radians(item[9])
            delta_phi = math.radians(item[9] - latitude)
            delta_lambda = math.radians(item[10] - longitude)
            haversine = math.sin(delta_phi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2) ** 2
            distance_km = 6371 * 2 * math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine))
            if distance_km > radiusKm:
                continue
        results.append((distance_km if distance_km is not None else float("inf"), _partner_response(item, distance_km)))
    results.sort(key=lambda value: value[0])
    return {"partners": [item[1] for item in results]}


@app.post("/admin/partners")
def create_partner(
    request: PartnerCreateRequest,
    _: dict[str, Any] = Depends(current_admin),
) -> dict[str, Any]:
    if (request.latitude is None) != (request.longitude is None):
        raise HTTPException(status_code=400, detail="Latitude e longitude devem ser informadas juntas.")
    normalized_cnpj = normalize_document(
        request.cnpj,
        required=False,
        document_type=request.documentType,
    )
    with database_connection() as connection:
        with connection.cursor() as cursor:
            if normalized_cnpj:
                cursor.execute("SELECT 1 FROM partner_profiles WHERE cnpj = %s", (normalized_cnpj,))
                if cursor.fetchone() is not None:
                    raise HTTPException(status_code=409, detail="CNPJ já cadastrado.")
            cursor.execute(
                """
                INSERT INTO partner_profiles
                    (name, partner_type, cnpj, phone, whatsapp, email, address,
                     postal_code, city, state, latitude, longitude, services, accepts_urgency,
                     status, verification_status, verified_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
                        'active', 'approved', now())
                RETURNING id, created_at
                """,
                (
                    request.name.strip(), request.partnerType.strip().lower(), normalized_cnpj,
                    request.phone.strip(), request.whatsapp.strip(), request.email.strip().lower(),
                    request.address.strip(), request.postalCode.strip(), request.city.strip(), request.state.strip(),
                    request.latitude, request.longitude,
                    psycopg.types.json.Jsonb([value.strip() for value in request.services if value.strip()]),
                    request.acceptsUrgency,
                ),
            )
            partner_id, created_at = cursor.fetchone()
    return {"id": partner_id, "status": "active", "createdAt": created_at.isoformat()}


@app.get("/admin/partners")
def list_admin_partners(_: dict[str, Any] = Depends(current_admin)) -> list[dict[str, Any]]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT p.id, p.name, p.partner_type, p.cnpj, p.email, p.phone,
                       p.city, p.state, p.status, p.verification_status, p.created_at,
                       u.email, COUNT(d.id)
                FROM partner_profiles AS p
                LEFT JOIN users AS u ON u.id = p.owner_user_id
                LEFT JOIN partner_documents AS d ON d.partner_id = p.id
                GROUP BY p.id, u.email
                ORDER BY CASE WHEN p.verification_status = 'pending' THEN 0 ELSE 1 END,
                         p.created_at DESC
                """
            )
            partners = cursor.fetchall()
    return [
        {
            "id": item[0],
            "name": item[1],
            "partnerType": item[2],
            "document": item[3],
            "email": item[4] or item[11] or "",
            "phone": item[5],
            "city": item[6],
            "state": item[7],
            "status": item[8],
            "verificationStatus": item[9],
            "createdAt": item[10].isoformat(),
            "documentCount": item[12],
        }
        for item in partners
    ]


@app.patch("/admin/partners/{partner_id}/status")
def update_partner_status(
    partner_id: int,
    request: PartnerStatusRequest,
    admin_user: dict[str, Any] = Depends(current_admin),
) -> dict[str, str]:
    if request.status not in {"active", "suspended"}:
        raise HTTPException(status_code=422, detail="Status de parceiro inválido.")
    with database_connection() as connection:
        with connection.cursor() as cursor:
            if request.status == "active":
                cursor.execute(
                    """
                    SELECT id, document_type, verification_status
                    FROM partner_documents
                    WHERE partner_id = %s
                    """,
                    (partner_id,),
                )
                documents = cursor.fetchall()
                requirements = _document_requirements(documents)
                if not requirements["readyForApproval"]:
                    missing = ", ".join(item["label"] for item in requirements["missing"])
                    raise HTTPException(
                        status_code=409,
                        detail=f"Aprovação bloqueada. Documentos obrigatórios pendentes: {missing}.",
                    )
            cursor.execute(
                """
                UPDATE partner_profiles
                SET status = %s,
                    verification_status = CASE WHEN %s = 'active' THEN 'approved' ELSE verification_status END,
                    verified_at = CASE WHEN %s = 'active' THEN COALESCE(verified_at, now()) ELSE verified_at END,
                    verified_by = CASE WHEN %s = 'active' THEN %s ELSE verified_by END,
                    updated_at = now()
                WHERE id = %s
                """,
                (
                    request.status, request.status, request.status, request.status,
                    int(admin_user["sub"]), partner_id,
                ),
            )
            if cursor.rowcount == 0:
                raise HTTPException(status_code=404, detail="Parceiro não encontrado.")
            if request.status == "active":
                cursor.execute(
                    """
                    UPDATE partner_professionals
                    SET verification_status = 'approved', verified_at = COALESCE(verified_at, now()),
                        verified_by = %s, updated_at = now()
                    WHERE partner_id = %s
                    """,
                    (int(admin_user["sub"]), partner_id),
                )
    return {"status": request.status}


@app.patch("/admin/partner-documents/{document_id}")
def review_partner_document(
    document_id: int,
    request: PartnerDocumentReviewRequest,
    admin_user: dict[str, Any] = Depends(current_admin),
) -> dict[str, str]:
    if request.status not in {"pending", "approved", "rejected"}:
        raise HTTPException(status_code=422, detail="Status de documento inválido.")
    if request.status == "rejected" and not request.rejectionReason.strip():
        raise HTTPException(
            status_code=422,
            detail="Informe a justificativa para rejeitar o documento.",
        )
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT partner_id, verification_status
                FROM partner_documents
                WHERE id = %s
                """,
                (document_id,),
            )
            document = cursor.fetchone()
            if document is None:
                raise HTTPException(status_code=404, detail="Documento não encontrado.")
            cursor.execute(
                """
                UPDATE partner_documents
                SET verification_status = %s, rejection_reason = %s,
                    reviewed_by = %s, reviewed_at = now()
                WHERE id = %s
                """,
                (request.status, request.rejectionReason.strip(), int(admin_user["sub"]), document_id),
            )
            cursor.execute(
                """
                INSERT INTO partner_document_audits
                    (document_id, partner_id, admin_user_id, previous_status,
                     new_status, rejection_reason)
                VALUES (%s, %s, %s, %s, %s, %s)
                """,
                (
                    document_id, document[0], int(admin_user["sub"]), document[1],
                    request.status, request.rejectionReason.strip(),
                ),
            )
    return {"status": request.status}


def _private_veterinary_contact_response(item: tuple[Any, ...]) -> dict[str, Any]:
    return {
        "id": item[0],
        "name": item[1],
        "kind": item[2],
        "specialty": item[3],
        "phone": item[4],
        "whatsapp": item[5],
        "address": item[6],
        "city": item[7],
        "state": item[8],
        "notes": item[9],
        "latitude": item[10],
        "longitude": item[11],
        "createdAt": item[12].isoformat(),
        "updatedAt": item[13].isoformat(),
    }


@app.get("/account/veterinary-contacts")
def list_private_veterinary_contacts(
    user: dict[str, Any] = Depends(require_family),
) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, name, kind, specialty, phone, whatsapp, address,
                       city, state, notes, latitude, longitude, created_at, updated_at
                FROM private_veterinary_contacts
                WHERE user_id = %s
                ORDER BY name
                """,
                (int(user["sub"]),),
            )
            contacts = cursor.fetchall()
    return {"contacts": [_private_veterinary_contact_response(item) for item in contacts]}


@app.post("/account/veterinary-contacts")
def create_private_veterinary_contact(
    request: PrivateVeterinaryContactRequest,
    user: dict[str, Any] = Depends(require_family),
) -> dict[str, Any]:
    if (request.latitude is None) != (request.longitude is None):
        raise HTTPException(status_code=400, detail="Latitude e longitude devem ser informadas juntas.")
    with database_connection() as connection:
        with connection.cursor() as cursor:
            identity = (
                int(user["sub"]), request.name.strip(), request.phone.strip(),
                request.whatsapp.strip(),
            )
            cursor.execute(
                """
                SELECT id
                FROM private_veterinary_contacts
                WHERE user_id = %s AND name = %s AND phone = %s AND whatsapp = %s
                LIMIT 1
                """,
                identity,
            )
            existing = cursor.fetchone()
            values = (
                request.name.strip(), request.kind.strip(), request.specialty.strip(),
                request.phone.strip(), request.whatsapp.strip(), request.address.strip(),
                request.city.strip(), request.state.strip(), request.notes.strip(),
                request.latitude, request.longitude,
            )
            if existing is not None:
                cursor.execute(
                    """
                    UPDATE private_veterinary_contacts
                    SET name = %s, kind = %s, specialty = %s, phone = %s,
                        whatsapp = %s, address = %s, city = %s, state = %s,
                        notes = %s, latitude = %s, longitude = %s, updated_at = now()
                    WHERE id = %s AND user_id = %s
                    RETURNING id, name, kind, specialty, phone, whatsapp, address,
                              city, state, notes, latitude, longitude, created_at, updated_at
                    """,
                    (*values, existing[0], int(user["sub"])),
                )
            else:
                cursor.execute(
                    """
                    INSERT INTO private_veterinary_contacts
                        (user_id, name, kind, specialty, phone, whatsapp, address,
                         city, state, notes, latitude, longitude)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    RETURNING id, name, kind, specialty, phone, whatsapp, address,
                              city, state, notes, latitude, longitude, created_at, updated_at
                    """,
                    (int(user["sub"]), *values),
                )
            contact = cursor.fetchone()
    return {"contact": _private_veterinary_contact_response(contact)}


@app.delete("/account/veterinary-contacts/{contact_id}")
def delete_private_veterinary_contact(
    contact_id: int,
    user: dict[str, Any] = Depends(require_family),
) -> dict[str, str]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "DELETE FROM private_veterinary_contacts WHERE id = %s AND user_id = %s",
                (contact_id, int(user["sub"])),
            )
            if cursor.rowcount == 0:
                raise HTTPException(status_code=404, detail="Contato privado não encontrado.")
    return {"status": "deleted"}


@app.get("/appointments")
def list_appointments(user: dict[str, Any] = Depends(require_family)) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT appointments.id, appointments.partner_id,
                       partners.name, appointments.pet_ref, appointments.pet_name,
                       appointments.service, appointments.scheduled_at,
                       appointments.status, appointments.notes,
                       appointments.check_in_at, appointments.created_at
                FROM appointments
                JOIN partner_profiles AS partners ON partners.id = appointments.partner_id
                WHERE appointments.user_id = %s
                ORDER BY appointments.scheduled_at DESC
                """,
                (int(user["sub"]),),
            )
            appointments = cursor.fetchall()
    return {
        "appointments": [
            {
                "id": item[0],
                "partnerId": item[1],
                "partnerName": item[2],
                "petId": item[3],
                "petName": item[4],
                "service": item[5],
                "scheduledAt": item[6].isoformat(),
                "status": item[7],
                "notes": item[8],
                "checkInAt": item[9].isoformat() if item[9] else None,
                "createdAt": item[10].isoformat(),
            }
            for item in appointments
        ]
    }


@app.post("/appointments")
def create_appointment(
    request: AppointmentRequest,
    user: dict[str, Any] = Depends(require_family),
) -> dict[str, Any]:
    scheduled_at = request.scheduledAt
    if scheduled_at.tzinfo is None:
        scheduled_at = scheduled_at.replace(tzinfo=timezone.utc)
    else:
        scheduled_at = scheduled_at.astimezone(timezone.utc)
    if scheduled_at < utc_now() - timedelta(minutes=5):
        raise HTTPException(status_code=422, detail="O horário do atendimento já passou.")
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT id, name, status FROM partner_profiles WHERE id = %s",
                (request.partnerId,),
            )
            partner = cursor.fetchone()
            if partner is None or partner[2] != "active":
                raise HTTPException(status_code=404, detail="Parceiro não encontrado ou indisponível.")
            cursor.execute(
                """
                INSERT INTO appointments
                    (user_id, partner_id, pet_ref, pet_name, service,
                     scheduled_at, notes)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                RETURNING id, created_at
                """,
                (
                    int(user["sub"]), request.partnerId, request.petId.strip(),
                    request.petName.strip(), request.service.strip(),
                    scheduled_at, request.notes.strip(),
                ),
            )
            appointment_id, created_at = cursor.fetchone()
            cursor.execute(
                """
                INSERT INTO appointment_status_audits
                    (appointment_id, actor_user_id, actor_role,
                     previous_status, new_status)
                VALUES (%s, %s, 'client', NULL, 'requested')
                """,
                (appointment_id, int(user["sub"])),
            )
    return {
        "id": appointment_id,
        "partnerId": request.partnerId,
        "partnerName": partner[1],
        "status": "requested",
        "scheduledAt": scheduled_at.isoformat(),
        "createdAt": created_at.isoformat(),
    }


@app.patch("/appointments/{appointment_id}/status")
def update_appointment_status(
    appointment_id: int,
    request: AppointmentStatusRequest,
    user: dict[str, Any] = Depends(require_family),
) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, status, check_in_at, updated_at
                FROM appointments
                WHERE id = %s AND user_id = %s
                FOR UPDATE
                """,
                (appointment_id, int(user["sub"])),
            )
            appointment = cursor.fetchone()
            if appointment is None:
                raise HTTPException(status_code=404, detail="Atendimento não encontrado.")
            try:
                target_status = validate_appointment_transition(
                    appointment[1],
                    request.status,
                    "client",
                )
            except InvalidAppointmentTransition as error:
                raise HTTPException(status_code=409, detail=str(error)) from error
            if target_status != appointment[1]:
                check_in_at = utc_now() if target_status == "checked_in" else appointment[2]
                cursor.execute(
                    """
                    UPDATE appointments
                    SET status = %s, check_in_at = %s, updated_at = now()
                    WHERE id = %s
                    RETURNING id, status, check_in_at, updated_at
                    """,
                    (target_status, check_in_at, appointment_id),
                )
                updated = cursor.fetchone()
                cursor.execute(
                    """
                    INSERT INTO appointment_status_audits
                        (appointment_id, actor_user_id, actor_role,
                         previous_status, new_status)
                    VALUES (%s, %s, 'client', %s, %s)
                    """,
                    (
                        appointment_id,
                        int(user["sub"]),
                        appointment[1],
                        target_status,
                    ),
                )
                appointment = updated
    return {
        "id": appointment[0],
        "status": appointment[1],
        "checkInAt": appointment[2].isoformat() if appointment[2] else None,
        "updatedAt": appointment[3].isoformat(),
    }


@app.patch("/partner/appointments/{appointment_id}/status")
def update_partner_appointment_status(
    appointment_id: int,
    request: AppointmentStatusRequest,
    user: dict[str, Any] = Depends(require_partner_access),
) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, status, updated_at
                FROM appointments
                WHERE id = %s AND partner_id = %s
                FOR UPDATE
                """,
                (appointment_id, user["partner_id"]),
            )
            appointment = cursor.fetchone()
            if appointment is None:
                raise HTTPException(status_code=404, detail="Atendimento não encontrado.")
            try:
                target_status = validate_appointment_transition(
                    appointment[1],
                    request.status,
                    "partner",
                )
            except InvalidAppointmentTransition as error:
                raise HTTPException(status_code=409, detail=str(error)) from error
            if target_status != appointment[1]:
                cursor.execute(
                    """
                    UPDATE appointments
                    SET status = %s, updated_at = now()
                    WHERE id = %s
                    RETURNING id, status, updated_at
                    """,
                    (target_status, appointment_id),
                )
                updated = cursor.fetchone()
                cursor.execute(
                    """
                    INSERT INTO appointment_status_audits
                        (appointment_id, actor_user_id, actor_role,
                         previous_status, new_status)
                    VALUES (%s, %s, 'partner', %s, %s)
                    """,
                    (
                        appointment_id,
                        int(user["sub"]),
                        appointment[1],
                        target_status,
                    ),
                )
                appointment = updated
    return {"id": appointment[0], "status": appointment[1], "updatedAt": appointment[2].isoformat()}


@app.get("/partner/appointments")
def list_partner_appointments(
    user: dict[str, Any] = Depends(require_partner_access),
) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT appointments.id, appointments.user_id,
                       clients.full_name, clients.email,
                       appointments.pet_ref, appointments.pet_name,
                       appointments.service, appointments.scheduled_at,
                       appointments.status, appointments.notes,
                       appointments.check_in_at, appointments.created_at,
                       appointments.updated_at
                FROM appointments
                JOIN users AS clients ON clients.id = appointments.user_id
                WHERE appointments.partner_id = %s
                ORDER BY appointments.scheduled_at ASC, appointments.id ASC
                """,
                (user["partner_id"],),
            )
            appointments = cursor.fetchall()
    return {
        "appointments": [
            {
                "id": item[0],
                "clientId": item[1],
                "clientName": item[2] or item[3],
                "clientEmail": item[3],
                "petId": item[4],
                "petName": item[5],
                "service": item[6],
                "scheduledAt": item[7].isoformat(),
                "status": item[8],
                "notes": item[9],
                "checkInAt": item[10].isoformat() if item[10] else None,
                "createdAt": item[11].isoformat(),
                "updatedAt": item[12].isoformat(),
            }
            for item in appointments
        ]
    }


def _prescription_token(public_id: str) -> str:
    return hmac.new(
        JWT_SECRET.encode("utf-8"),
        f"prescription:{public_id}".encode("utf-8"),
        hashlib.sha256,
    ).hexdigest()


def _prescription_response(item: tuple[Any, ...]) -> dict[str, Any]:
    return {
        "id": item[0],
        "appointmentId": item[1],
        "publicId": str(item[2]),
        "prescriptionType": item[3],
        "status": item[4],
        "version": item[5],
        "patient": item[6],
        "owner": item[7],
        "prescriber": item[8],
        "items": item[9],
        "instructions": item[10],
        "preparedAt": item[11].isoformat() if item[11] else None,
        "signedAt": item[12].isoformat() if item[12] else None,
        "cancelledAt": item[13].isoformat() if item[13] else None,
        "cancellationReason": item[14] or "",
        "createdAt": item[15].isoformat(),
        "updatedAt": item[16].isoformat(),
        "isValidForDispensing": item[4] == "signed" and item[12] is not None,
        "warning": None if item[4] == "signed" and item[12] is not None else "Documento sem assinatura eletrônica válida. Não utilizar para dispensação.",
    }


PRESCRIPTION_SELECT = """
    SELECT id, appointment_id, public_id, prescription_type, status, version,
           patient_snapshot, owner_snapshot, prescriber_snapshot, items,
           instructions, prepared_at, signed_at, cancelled_at,
           cancellation_reason, created_at, updated_at
    FROM veterinary_prescriptions
"""


@app.post("/partner/prescriptions")
def create_partner_prescription(
    request: PrescriptionCreateRequest,
    user: dict[str, Any] = Depends(require_partner_access),
) -> dict[str, Any]:
    try:
        prescription_type = normalize_prescription_type(request.prescriptionType)
        items = validate_items([item.model_dump() for item in request.items])
    except InvalidPrescription as error:
        raise HTTPException(status_code=422, detail=str(error)) from error
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT a.id, a.user_id, a.pet_ref, a.pet_name, a.status,
                       u.full_name, u.email,
                       p.name, p.phone, p.address, p.city, p.state,
                       pr.id, pr.full_name, pr.crmv_uf, pr.crmv_number,
                       pr.verification_status
                FROM appointments AS a
                JOIN users AS u ON u.id = a.user_id
                JOIN partner_profiles AS p ON p.id = a.partner_id
                LEFT JOIN partner_professionals AS pr
                  ON pr.partner_id = p.id AND pr.is_responsible_technical IS TRUE
                WHERE a.id = %s AND a.partner_id = %s
                FOR UPDATE OF a
                """,
                (request.appointmentId, user["partner_id"]),
            )
            context = cursor.fetchone()
            if context is None:
                raise HTTPException(status_code=404, detail="Atendimento não encontrado.")
            if context[4] != "completed":
                raise HTTPException(status_code=409, detail="Conclua o atendimento antes de criar o receituário.")
            if context[12] is None or context[16] != "approved":
                raise HTTPException(status_code=409, detail="O responsável técnico aprovado não foi encontrado.")
            try:
                crmv_uf, crmv_number = validate_crmv(context[14], context[15])
            except InvalidPrescription as error:
                raise HTTPException(status_code=409, detail=str(error)) from error
            patient = {
                "reference": context[2], "name": context[3],
                "species": request.patientSpecies.strip(), "breed": request.patientBreed.strip(),
                "sex": request.patientSex.strip(), "weight": request.patientWeight.strip(),
            }
            owner = {"name": context[5] or context[6], "email": context[6], "address": request.ownerAddress.strip()}
            prescriber = {
                "professionalId": context[12], "name": context[13],
                "crmvUf": crmv_uf, "crmvNumber": crmv_number,
                "establishment": context[7], "phone": context[8],
                "address": ", ".join(value for value in (context[9], context[10], context[11]) if value),
            }
            public_id = str(uuid.uuid4())
            token = _prescription_token(public_id)
            try:
                cursor.execute(
                    """
                    INSERT INTO veterinary_prescriptions
                        (appointment_id, user_id, partner_id, professional_id,
                         public_id, verification_token_hash, prescription_type,
                         patient_snapshot, owner_snapshot, prescriber_snapshot,
                         items, instructions)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    RETURNING id
                    """,
                    (
                        context[0], context[1], user["partner_id"], context[12],
                        public_id, verification_token_hash(token), prescription_type,
                        psycopg.types.json.Jsonb(patient), psycopg.types.json.Jsonb(owner),
                        psycopg.types.json.Jsonb(prescriber), psycopg.types.json.Jsonb(items),
                        request.instructions.strip(),
                    ),
                )
            except psycopg.errors.UniqueViolation as error:
                raise HTTPException(status_code=409, detail="Este atendimento já possui um receituário ativo.") from error
            prescription_id = cursor.fetchone()[0]
            cursor.execute(
                """
                INSERT INTO veterinary_prescription_versions
                    (prescription_id, version, patient_snapshot, owner_snapshot,
                     prescriber_snapshot, items, instructions, created_by)
                VALUES (%s, 1, %s, %s, %s, %s, %s, %s)
                """,
                (prescription_id, psycopg.types.json.Jsonb(patient), psycopg.types.json.Jsonb(owner), psycopg.types.json.Jsonb(prescriber), psycopg.types.json.Jsonb(items), request.instructions.strip(), int(user["sub"])),
            )
            cursor.execute(
                """INSERT INTO veterinary_prescription_audits
                       (prescription_id, actor_user_id, action, new_status)
                   VALUES (%s, %s, 'created', 'draft')""",
                (prescription_id, int(user["sub"])),
            )
            cursor.execute(PRESCRIPTION_SELECT + " WHERE id = %s", (prescription_id,))
            created = cursor.fetchone()
    return _prescription_response(created)


@app.get("/partner/prescriptions")
def list_partner_prescriptions(user: dict[str, Any] = Depends(require_partner_access)) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(PRESCRIPTION_SELECT + " WHERE partner_id = %s ORDER BY created_at DESC", (user["partner_id"],))
            items = cursor.fetchall()
    return {"prescriptions": [_prescription_response(item) for item in items]}


@app.post("/partner/prescriptions/{prescription_id}/prepare")
def prepare_partner_prescription(
    prescription_id: int,
    user: dict[str, Any] = Depends(require_partner_access),
) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(PRESCRIPTION_SELECT + " WHERE id = %s AND partner_id = %s FOR UPDATE", (prescription_id, user["partner_id"]))
            item = cursor.fetchone()
            if item is None:
                raise HTTPException(status_code=404, detail="Receituário não encontrado.")
            if item[4] != "draft":
                raise HTTPException(status_code=409, detail="Somente um rascunho pode ser preparado.")
            try:
                ensure_type_can_be_prepared(item[3])
            except InvalidPrescription as error:
                raise HTTPException(status_code=409, detail=str(error)) from error
            public_id = str(item[2]); token = _prescription_token(public_id)
            prepared_at = utc_now()
            verification_url = f"{AUMIAU_WEB_URL}/prescriptions/verify/{public_id}?token={token}"
            content = generate_prescription_pdf({
                "publicId": public_id, "version": item[5],
                "patient": item[6], "owner": item[7], "prescriber": item[8],
                "items": item[9], "instructions": item[10],
                "preparedAt": prepared_at.astimezone(timezone.utc).strftime("%d/%m/%Y %H:%M UTC"),
            }, verification_url)
            directory = os.path.join(PRESCRIPTIONS_DIR, str(user["partner_id"]))
            os.makedirs(directory, mode=0o700, exist_ok=True)
            os.chmod(directory, 0o700)
            storage_key = f"{user['partner_id']}/{public_id}-v{item[5]}.pdf"
            path = os.path.join(PRESCRIPTIONS_DIR, storage_key)
            with open(path, "wb") as prescription_file:
                prescription_file.write(content)
                prescription_file.flush(); os.fsync(prescription_file.fileno())
            os.chmod(path, 0o600)
            digest = hashlib.sha256(content).hexdigest()
            cursor.execute(
                """
                UPDATE veterinary_prescriptions
                SET status = 'ready_for_signature', pdf_storage_key = %s,
                    pdf_sha256 = %s, prepared_at = %s, updated_at = now()
                WHERE id = %s
                """,
                (storage_key, digest, prepared_at, prescription_id),
            )
            cursor.execute(
                """INSERT INTO veterinary_prescription_audits
                       (prescription_id, actor_user_id, action, previous_status, new_status,
                        metadata)
                   VALUES (%s, %s, 'prepared', 'draft', 'ready_for_signature', %s)""",
                (prescription_id, int(user["sub"]), psycopg.types.json.Jsonb({"pdfSha256": digest})),
            )
            cursor.execute(PRESCRIPTION_SELECT + " WHERE id = %s", (prescription_id,))
            prepared = cursor.fetchone()
    return _prescription_response(prepared)


@app.post("/partner/prescriptions/{prescription_id}/cancel")
def cancel_partner_prescription(
    prescription_id: int,
    request: PrescriptionCancelRequest,
    user: dict[str, Any] = Depends(require_partner_access),
) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT status FROM veterinary_prescriptions WHERE id = %s AND partner_id = %s FOR UPDATE", (prescription_id, user["partner_id"]))
            item = cursor.fetchone()
            if item is None: raise HTTPException(status_code=404, detail="Receituário não encontrado.")
            if item[0] == "cancelled": raise HTTPException(status_code=409, detail="O receituário já está cancelado.")
            cursor.execute("UPDATE veterinary_prescriptions SET status='cancelled', cancelled_at=now(), cancellation_reason=%s, updated_at=now() WHERE id=%s", (request.reason.strip(), prescription_id))
            cursor.execute("INSERT INTO veterinary_prescription_audits (prescription_id, actor_user_id, action, previous_status, new_status, metadata) VALUES (%s,%s,'cancelled',%s,'cancelled',%s)", (prescription_id, int(user["sub"]), item[0], psycopg.types.json.Jsonb({"reason": request.reason.strip()})))
            cursor.execute(PRESCRIPTION_SELECT + " WHERE id = %s", (prescription_id,)); cancelled = cursor.fetchone()
    return _prescription_response(cancelled)


@app.get("/prescriptions")
def list_client_prescriptions(user: dict[str, Any] = Depends(current_user)) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(PRESCRIPTION_SELECT + " WHERE user_id = %s AND status <> 'draft' ORDER BY created_at DESC", (int(user["sub"]),))
            items = cursor.fetchall()
    return {"prescriptions": [_prescription_response(item) for item in items]}


def _prescription_pdf_response(prescription_id: int, actor: dict[str, Any], partner: bool) -> Response:
    ownership = "partner_id = %s" if partner else "user_id = %s"
    owner_id = actor["partner_id"] if partner else int(actor["sub"])
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(f"SELECT pdf_storage_key, public_id, version FROM veterinary_prescriptions WHERE id = %s AND {ownership} AND status <> 'draft'", (prescription_id, owner_id))
            item = cursor.fetchone()
            if item is None: raise HTTPException(status_code=404, detail="Receituário não encontrado.")
            path = os.path.abspath(os.path.join(PRESCRIPTIONS_DIR, item[0] or ""))
            root = os.path.abspath(PRESCRIPTIONS_DIR)
            if not path.startswith(root + os.sep) or not os.path.isfile(path): raise HTTPException(status_code=404, detail="Arquivo do receituário não encontrado.")
            cursor.execute("INSERT INTO veterinary_prescription_audits (prescription_id, actor_user_id, action, metadata) VALUES (%s,%s,%s,%s)", (prescription_id, int(actor["sub"]), "partner_download" if partner else "owner_download", psycopg.types.json.Jsonb({})))
    with open(path, "rb") as file: content = file.read()
    return Response(content=content, media_type="application/pdf", headers={"Content-Disposition": f'attachment; filename="receituario-{item[1]}-v{item[2]}.pdf"', "Cache-Control": "no-store, private", "X-Content-Type-Options": "nosniff"})


@app.get("/partner/prescriptions/{prescription_id}/content")
def download_partner_prescription(prescription_id: int, user: dict[str, Any] = Depends(require_partner_access)) -> Response:
    return _prescription_pdf_response(prescription_id, user, True)


@app.get("/prescriptions/{prescription_id}/content")
def download_client_prescription(prescription_id: int, user: dict[str, Any] = Depends(current_user)) -> Response:
    return _prescription_pdf_response(prescription_id, user, False)


@app.get("/prescriptions/verify/{public_id}", response_class=HTMLResponse)
def verify_public_prescription(public_id: str, token: str = Query(min_length=32, max_length=128)) -> HTMLResponse:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT verification_token_hash, status, signed_at, prescription_type, prescriber_snapshot, patient_snapshot, prepared_at, cancelled_at FROM veterinary_prescriptions WHERE public_id = %s", (public_id,))
            item = cursor.fetchone()
    if item is None or not verify_token(token, item[0]): raise HTTPException(status_code=404, detail="Documento não encontrado.")
    valid, reason = public_validity(item[1], item[2])
    color = "#287A4B" if valid else "#B42318"
    heading = "Documento assinado e válido" if valid else ("Documento cancelado" if reason == "cancelled" else "Rascunho sem assinatura válida")
    explanation = "A verificação criptográfica e a assinatura eletrônica foram confirmadas." if valid else "Este documento não possui assinatura eletrônica válida e não deve ser utilizado para dispensação de medicamentos."
    prescriber, patient = item[4], item[5]
    return HTMLResponse(
        content=f'''<!doctype html><html lang="pt-BR"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Verificação de receituário AuMiau</title><style>body{{font-family:Arial,sans-serif;background:#fbf9f4;color:#26332e;margin:0;padding:24px}}main{{max-width:680px;margin:40px auto;background:white;border-radius:20px;padding:28px;box-shadow:0 12px 35px #17372f18}}h1{{color:#1e4d40}}.status{{border-left:6px solid {color};background:#f7f7f5;padding:16px;border-radius:8px}}.status h2{{color:{color};margin-top:0}}dt{{font-weight:700;color:#1e4d40;margin-top:14px}}dd{{margin:4px 0}}small{{color:#6b7a73}}</style></head><body><main><h1>AuMiau — Verificação de receituário</h1><section class="status"><h2>{html.escape(heading)}</h2><p>{html.escape(explanation)}</p></section><dl><dt>Documento</dt><dd>{html.escape(public_id)}</dd><dt>Profissional</dt><dd>{html.escape(str(prescriber.get('name') or ''))} — CRMV-{html.escape(str(prescriber.get('crmvUf') or ''))} {html.escape(str(prescriber.get('crmvNumber') or ''))}</dd><dt>Paciente</dt><dd>{html.escape(str(patient.get('name') or ''))}</dd><dt>Estado</dt><dd>{html.escape(str(item[1]))}</dd></dl><p><small>A consulta pública mostra apenas os dados mínimos necessários para verificar o documento.</small></p></main></body></html>''',
        headers={"Cache-Control": "no-store", "X-Robots-Tag": "noindex, nofollow"},
    )


@app.get("/billing/catalog")
def billing_catalog() -> dict[str, Any]:
    return {
        "currencyPolicy": "brl",
        "referenceCurrency": "BRL",
        "products": [
            {
                "productId": "family_monthly",
                "billingPeriod": "P1M",
                "priceBrl": "2.99",
                "displayName": "AuMiau Family mensal",
            },
            {
                "productId": "family_yearly",
                "billingPeriod": "P1Y",
                "priceBrl": "25.00",
                "displayName": "AuMiau Family anual",
            },
            {
                "productId": "partner_monthly",
                "billingPeriod": "P1M",
                "priceBrl": "2.99",
                "displayName": "AuMiau Parceiro mensal",
            },
            {
                "productId": "partner_yearly",
                "billingPeriod": "P1Y",
                "priceBrl": "25.00",
                "displayName": "AuMiau Parceiro anual",
            },
        ],
    }


def _order_payment(order: dict[str, Any]) -> dict[str, Any]:
    transactions = order.get("transactions") or {}
    payments = transactions.get("payments") or []
    payment = payments[0] if payments and isinstance(payments[0], dict) else {}
    payment_method = payment.get("payment_method") or {}
    return {
        "paymentId": payment.get("id"),
        "status": payment.get("status") or order.get("status") or "pending",
        "statusDetail": payment.get("status_detail") or order.get("status_detail"),
        "qrCode": payment_method.get("qr_code"),
        "qrCodeBase64": payment_method.get("qr_code_base64"),
        "ticketUrl": payment_method.get("ticket_url"),
    }


def _mercadopago_notification_fields() -> dict[str, str]:
    if not MERCADOPAGO_NOTIFICATION_URL:
        return {}
    return {"notification_url": MERCADOPAGO_NOTIFICATION_URL}


def _is_mercadopago_order_paid(order: dict[str, Any]) -> bool:
    payment = _order_payment(order)
    payment_status = str(payment["status"]).lower()
    order_status = str(order.get("status") or "").lower()
    return order_status == "processed" or payment_status in {"approved", "processed"}


def _apply_mercadopago_order(order: dict[str, Any]) -> dict[str, Any] | None:
    provider_order_id = order.get("id")
    if not isinstance(provider_order_id, str) or not provider_order_id:
        return None
    payment = _order_payment(order)
    payment_status = str(payment["status"]).lower()
    order_status = str(order.get("status") or "").lower()
    paid = _is_mercadopago_order_paid(order)
    status_value = "active" if paid else order_status or payment_status or "pending"
    now = utc_now()

    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, user_id, product_id, amount_brl, status, paid_at
                FROM billing_orders
                WHERE provider_order_id = %s
                FOR UPDATE
                """,
                (provider_order_id,),
            )
            local_order = cursor.fetchone()
            if local_order is None:
                return None
            already_paid = local_order[5] is not None
            valid_until = None
            if paid and not already_paid:
                product = BILLING_PRODUCTS.get(local_order[2])
                if product is None:
                    raise HTTPException(status_code=422, detail="Produto de cobrança inválido.")
                entitlement_key = str(product.get("entitlementKey", "family_access"))
                cursor.execute(
                    """
                    SELECT valid_until
                    FROM entitlements
                    WHERE user_id = %s AND entitlement_key = %s
                    """,
                    (local_order[1], entitlement_key),
                )
                entitlement = cursor.fetchone()
                previous_until = entitlement[0] if entitlement else None
                start_from = previous_until if previous_until and previous_until > now else now
                valid_until = start_from + timedelta(days=int(product["periodDays"]))
                purchase_token_hash = hashlib.sha256(
                    f"mercadopago:{provider_order_id}".encode()
                ).hexdigest()
                cursor.execute(
                    """
                    INSERT INTO subscriptions
                        (user_id, provider, product_id, purchase_token_hash,
                         order_id, status, environment, auto_renew,
                         started_at, expires_at, verified_at, updated_at)
                    VALUES (%s, 'mercadopago', %s, %s, %s, 'active', %s,
                            FALSE, %s, %s, %s, now())
                    ON CONFLICT (purchase_token_hash) DO UPDATE SET
                        status = 'active',
                        expires_at = EXCLUDED.expires_at,
                        verified_at = EXCLUDED.verified_at,
                        updated_at = now()
                    """,
                    (
                        local_order[1], local_order[2], purchase_token_hash,
                        provider_order_id, MERCADOPAGO_ENVIRONMENT, now,
                        valid_until, now,
                    ),
                )
                cursor.execute(
                    """
                    INSERT INTO entitlements
                        (user_id, entitlement_key, source, status,
                         valid_from, valid_until, updated_at)
                    VALUES (%s, %s, 'mercadopago', 'active',
                            %s, %s, now())
                    ON CONFLICT (user_id, entitlement_key) DO UPDATE SET
                        source = 'mercadopago',
                        status = 'active',
                        valid_from = EXCLUDED.valid_from,
                        valid_until = EXCLUDED.valid_until,
                        updated_at = now()
                    """,
                    (local_order[1], entitlement_key, now, valid_until),
                )
                if entitlement_key == "partner_access":
                    cursor.execute(
                        """
                        UPDATE partner_profiles
                        SET status = CASE WHEN verification_status = 'approved' THEN 'active' ELSE 'pending' END,
                            updated_at = now()
                        WHERE owner_user_id = %s
                        """,
                        (local_order[1],),
                    )
                else:
                    cursor.execute(
                        """
                        UPDATE users
                        SET edition = 'family', plan_code = 'family'
                        WHERE id = %s
                        """,
                        (local_order[1],),
                    )
            cursor.execute(
                """
                UPDATE billing_orders
                SET provider_payment_id = %s,
                    status = %s,
                     status_detail = %s,
                     qr_code = COALESCE(%s, qr_code),
                     qr_code_base64 = COALESCE(%s, qr_code_base64),
                     ticket_url = COALESCE(%s, ticket_url),
                    paid_at = CASE WHEN %s AND paid_at IS NULL THEN now() ELSE paid_at END,
                    updated_at = now()
                WHERE provider_order_id = %s
                """,
                (
                    payment["paymentId"], status_value, payment["statusDetail"],
                    payment["qrCode"], payment["qrCodeBase64"], payment["ticketUrl"], paid,
                    provider_order_id,
                ),
            )
    return {
        "orderId": provider_order_id,
        "status": "active" if paid else status_value,
        "paid": paid or already_paid,
        "validUntil": valid_until.isoformat() if valid_until else None,
    }


def _reconcile_mercadopago_orders(user_id: int, *, limit: int = 5) -> int:
    if not MERCADOPAGO_ACCESS_TOKEN:
        return 0
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT provider_order_id
                FROM billing_orders
                WHERE user_id = %s
                  AND provider = 'mercadopago'
                  AND paid_at IS NULL
                  AND created_at >= now() - interval '2 days'
                  AND updated_at <= now() - interval '10 seconds'
                ORDER BY created_at DESC
                LIMIT %s
                """,
                (user_id, limit),
            )
            order_ids = [str(item[0]) for item in cursor.fetchall()]
    reconciled = 0
    for order_id in order_ids:
        try:
            result = _apply_mercadopago_order(
                mercadopago_request("GET", f"/v1/orders/{order_id}")
            )
            if result and result.get("paid"):
                reconciled += 1
        except HTTPException:
            logger.warning(
                "mercadopago_order_reconciliation_failed user_id=%s order_id=%s",
                user_id,
                order_id,
            )
    return reconciled


@app.post("/billing/orders")
def create_billing_order(
    request: BillingOrderRequest,
    user: dict[str, Any] = Depends(current_user),
) -> dict[str, Any]:
    product = BILLING_PRODUCTS.get(request.productId)
    if product is None:
        raise HTTPException(status_code=400, detail="Plano Family inválido.")
    requested_account_type = str(product.get("accountType") or "client")
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT u.email, u.full_name, a.country, a.state, a.city,
                       a.postal_code, a.street, a.number, u.account_type,
                       p.address, p.postal_code, p.city, p.state
                FROM users AS u
                LEFT JOIN user_addresses AS a ON a.user_id = u.id
                LEFT JOIN partner_profiles AS p ON p.owner_user_id = u.id
                WHERE u.id = %s
                """,
                (int(user["sub"]),),
            )
            account = cursor.fetchone()
            cursor.execute(
                """
                SELECT
                    EXISTS(SELECT 1 FROM user_roles WHERE user_id = %s AND role = 'client'),
                    EXISTS(SELECT 1 FROM user_roles WHERE user_id = %s AND role = 'partner')
                """,
                (int(user["sub"]), int(user["sub"])),
            )
            roles = cursor.fetchone()
    if account is None:
        raise HTTPException(status_code=404, detail="Conta não encontrada.")
    has_client_role = bool(roles[0]) if roles else account[8] == "client"
    has_partner_role = bool(roles[1]) if roles else account[8] == "partner"
    if requested_account_type == "partner" and not has_partner_role:
        raise HTTPException(status_code=403, detail="Ative o perfil parceiro antes de contratar este plano.")
    if requested_account_type == "client" and not has_client_role:
        raise HTTPException(status_code=403, detail="Este produto não pertence ao tipo desta conta.")

    if account[2] is None and requested_account_type == "client":
        raise HTTPException(
            status_code=409,
            detail="Cadastre seu endereço completo antes de contratar o plano Family.",
        )
    if requested_account_type == "partner" and not all(account[index] for index in (9, 10, 11, 12)):
        raise HTTPException(
            status_code=409,
            detail="Cadastre endereço, CEP, cidade e estado do perfil profissional antes de contratar.",
        )

    payer_country = account[2] or "BR"
    payer_state = account[3] or ""
    payer_city = account[4] or ""
    payer_postal_code = account[5] or ""
    payer_street = account[6] or ""
    payer_number = account[7] or ""
    if requested_account_type == "partner":
        payer_country = "BR"
        payer_street = account[9]
        payer_postal_code = account[10]
        payer_city = account[11]
        payer_state = account[12]
        payer_number = "S/N"

    payer_email = account[0]
    name_parts = [part for part in account[1].strip().split() if part]
    first_name = name_parts[0] if name_parts else "Cliente"
    last_name = " ".join(name_parts[1:]) if len(name_parts) > 1 else "AuMiau"
    if MERCADOPAGO_ENVIRONMENT == "test" and not payer_email.endswith("@testuser.com"):
        payer_email = MERCADOPAGO_TEST_PAYER_EMAIL
    external_reference = f"aumiau-{user['sub']}-{request.productId}-{secrets.token_hex(6)}"
    amount = str(product["amountBrl"])
    response = mercadopago_request(
        "POST",
        "/v1/orders",
        payload={
            "type": "online",
            "total_amount": amount,
            "external_reference": external_reference,
            "processing_mode": "automatic",
            **_mercadopago_notification_fields(),
            "items": [
                {
                    "title": product["displayName"],
                    "quantity": 1,
                    "unit_price": amount,
                    "category_id": "services",
                    "external_code": request.productId,
                }
            ],
            "transactions": {
                "payments": [
                    {
                        "amount": amount,
                        "payment_method": {"id": "pix", "type": "bank_transfer"},
                        "expiration_time": "P1D",
                    }
                ]
            },
            "payer": {
                "email": payer_email,
                "first_name": first_name,
                "last_name": last_name,
                "address": {
                    "street_name": payer_street,
                    "street_number": payer_number,
                    "zip_code": payer_postal_code,
                    "city": payer_city,
                    "state": normalize_state_code(payer_state),
                },
            },
        },
        idempotency_key=str(uuid.uuid4()),
    )
    provider_order_id = response.get("id")
    if not isinstance(provider_order_id, str) or not provider_order_id:
        raise HTTPException(status_code=502, detail="Mercado Pago não retornou o pedido.")
    payment = _order_payment(response)
    qr_code = payment["qrCode"]
    if not isinstance(qr_code, str) or not qr_code:
        raise HTTPException(status_code=502, detail="Mercado Pago não retornou o QR Code Pix.")
    expires_at = utc_now() + timedelta(days=1)
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                INSERT INTO billing_orders
                    (user_id, provider, product_id, external_reference,
                     provider_order_id, provider_payment_id, amount_brl,
                      status, status_detail, environment, qr_code, qr_code_base64, ticket_url,
                     expires_at, updated_at)
                VALUES (%s, 'mercadopago', %s, %s, %s, %s, %s, %s, %s,
                         %s, %s, %s, %s, %s, now())
                ON CONFLICT (provider_order_id) DO UPDATE SET
                    qr_code = EXCLUDED.qr_code,
                    qr_code_base64 = EXCLUDED.qr_code_base64,
                    ticket_url = EXCLUDED.ticket_url,
                    status = EXCLUDED.status,
                    status_detail = EXCLUDED.status_detail,
                    updated_at = now()
                """,
                (
                    int(user["sub"]), request.productId, external_reference,
                    provider_order_id, payment["paymentId"], amount,
                    response.get("status") or payment["status"],
                    payment["statusDetail"], MERCADOPAGO_ENVIRONMENT,
                    qr_code, payment["qrCodeBase64"], payment["ticketUrl"], expires_at,
                ),
            )
    return {
        "provider": "mercadopago",
        "orderId": provider_order_id,
        "productId": request.productId,
        "amountBrl": float(amount),
        "status": response.get("status") or payment["status"],
        "qrCode": qr_code,
        "qrCodeBase64": payment["qrCodeBase64"],
        "ticketUrl": payment["ticketUrl"],
        "environment": MERCADOPAGO_ENVIRONMENT,
        "externalReference": external_reference,
        "expiresAt": expires_at.isoformat(),
    }


@app.get("/billing/orders/{order_id}")
def get_billing_order(
    order_id: str,
    user: dict[str, Any] = Depends(current_user),
) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                 SELECT product_id, amount_brl, status, status_detail, qr_code,
                        qr_code_base64, ticket_url, expires_at, paid_at
                FROM billing_orders
                WHERE provider_order_id = %s AND user_id = %s
                """,
                (order_id, int(user["sub"])),
            )
            local_order = cursor.fetchone()
    if local_order is None:
        raise HTTPException(status_code=404, detail="Pedido não encontrado.")
    if MERCADOPAGO_ACCESS_TOKEN and not local_order[8]:
        try:
            _apply_mercadopago_order(mercadopago_request("GET", f"/v1/orders/{order_id}"))
        except HTTPException:
            logger.warning("mercadopago_order_refresh_failed order_id=%s", order_id)
        with database_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                     SELECT product_id, amount_brl, status, status_detail, qr_code,
                            qr_code_base64, ticket_url, expires_at, paid_at
                    FROM billing_orders
                    WHERE provider_order_id = %s AND user_id = %s
                    """,
                    (order_id, int(user["sub"])),
                )
                local_order = cursor.fetchone()
    return {
        "provider": "mercadopago",
        "orderId": order_id,
        "productId": local_order[0],
        "amountBrl": float(local_order[1]),
        "status": local_order[2],
        "statusDetail": local_order[3],
        "qrCode": local_order[4],
        "qrCodeBase64": local_order[5],
        "ticketUrl": local_order[6],
        "expiresAt": local_order[7].isoformat() if local_order[7] else None,
        "paidAt": local_order[8].isoformat() if local_order[8] else None,
        "paid": local_order[8] is not None,
    }


@app.post("/webhooks/mercadopago")
async def mercadopago_webhook(
    request: Request,
    x_signature: str | None = Header(default=None, alias="x-signature"),
    x_request_id: str | None = Header(default=None, alias="x-request-id"),
    data_id: str | None = Query(default=None, alias="data.id"),
) -> dict[str, Any]:
    payload = await request.json()
    payload_data = payload.get("data") if isinstance(payload, dict) else None
    resolved_data_id = data_id or (payload_data.get("id") if isinstance(payload_data, dict) else None)
    if not validate_mercadopago_signature(x_signature, x_request_id, resolved_data_id):
        raise HTTPException(status_code=401, detail="Assinatura do webhook inválida.")
    if payload.get("type") not in {None, "order"}:
        return {"received": True, "ignored": True}
    order = mercadopago_request("GET", f"/v1/orders/{resolved_data_id}")
    applied = _apply_mercadopago_order(order)
    return {"received": True, "order": applied}


@app.post("/billing/verify")
def verify_billing_purchase(
    request: BillingVerifyRequest,
    user: dict[str, Any] = Depends(current_user),
) -> dict[str, Any]:
    if request.provider != "google_play":
        raise HTTPException(status_code=422, detail="Provedor de compra não suportado.")
    product = BILLING_PRODUCTS.get(request.productId)
    if product is None or product.get("entitlementKey") != "family_access":
        raise HTTPException(status_code=422, detail="Produto Family inválido.")
    try:
        client = GooglePlayClient(
            package_name=GOOGLE_PLAY_PACKAGE_NAME,
            service_account_file=GOOGLE_PLAY_SERVICE_ACCOUNT_FILE,
        )
        subscription = client.verify_subscription(
            product_id=request.productId,
            purchase_token=request.purchaseToken,
        )
    except GooglePlayConfigurationError as error:
        logger.error("google_play_configuration_error error=%s", error)
        raise HTTPException(status_code=503, detail="Google Play Billing ainda não está configurado.") from error
    except GooglePlayVerificationError as error:
        logger.warning("google_play_verification_failed user_id=%s error=%s", user["sub"], error)
        raise HTTPException(status_code=422, detail="Não foi possível validar esta assinatura no Google Play.") from error

    user_id = int(user["sub"])
    token_hash = hashlib.sha256(request.purchaseToken.encode()).hexdigest()
    now = utc_now()
    entitlement_status = "active" if subscription.grants_entitlement else "pending"
    if subscription.expires_at and subscription.expires_at <= now:
        entitlement_status = "expired"

    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT user_id FROM subscriptions WHERE purchase_token_hash = %s FOR UPDATE",
                (token_hash,),
            )
            existing = cursor.fetchone()
            if existing is not None and int(existing[0]) != user_id:
                raise HTTPException(status_code=409, detail="Esta assinatura já pertence a outra conta.")
            cursor.execute(
                """
                INSERT INTO subscriptions
                    (user_id, provider, product_id, purchase_token_hash,
                     order_id, status, environment, auto_renew,
                     started_at, expires_at, verified_at, updated_at)
                VALUES (%s, 'google_play', %s, %s, %s, %s, 'production', %s,
                        %s, %s, %s, now())
                ON CONFLICT (purchase_token_hash) DO UPDATE SET
                    product_id = EXCLUDED.product_id,
                    order_id = EXCLUDED.order_id,
                    status = EXCLUDED.status,
                    auto_renew = EXCLUDED.auto_renew,
                    started_at = EXCLUDED.started_at,
                    expires_at = EXCLUDED.expires_at,
                    verified_at = EXCLUDED.verified_at,
                    updated_at = now()
                """,
                (
                    user_id,
                    request.productId,
                    token_hash,
                    subscription.order_id,
                    subscription.state,
                    subscription.auto_renew,
                    subscription.started_at,
                    subscription.expires_at,
                    now,
                ),
            )
            cursor.execute(
                """
                SELECT provider, started_at, expires_at
                FROM subscriptions
                WHERE user_id = %s
                  AND product_id IN ('family_monthly', 'family_yearly')
                  AND expires_at > %s
                  AND status IN (
                      'active',
                      'SUBSCRIPTION_STATE_ACTIVE',
                      'SUBSCRIPTION_STATE_IN_GRACE_PERIOD',
                      'SUBSCRIPTION_STATE_CANCELED'
                  )
                ORDER BY expires_at DESC
                LIMIT 1
                """,
                (user_id, now),
            )
            effective_subscription = cursor.fetchone()
            if effective_subscription is not None:
                entitlement_status = "active"
                entitlement_source = effective_subscription[0]
                entitlement_start = effective_subscription[1] or now
                entitlement_until = effective_subscription[2]
            else:
                entitlement_source = "google_play"
                entitlement_start = subscription.started_at or now
                entitlement_until = subscription.expires_at
            cursor.execute(
                """
                INSERT INTO entitlements
                    (user_id, entitlement_key, source, status,
                     valid_from, valid_until, updated_at)
                VALUES (%s, 'family_access', %s, %s, %s, %s, now())
                ON CONFLICT (user_id, entitlement_key) DO UPDATE SET
                    source = 'google_play',
                    status = EXCLUDED.status,
                    valid_from = EXCLUDED.valid_from,
                    valid_until = EXCLUDED.valid_until,
                    updated_at = now()
                """,
                (
                    user_id,
                    entitlement_source,
                    entitlement_status,
                    entitlement_start,
                    entitlement_until,
                ),
            )
            if entitlement_status == "active":
                cursor.execute(
                    "UPDATE users SET edition = 'family', plan_code = 'family' WHERE id = %s",
                    (user_id,),
                )
            else:
                cursor.execute(
                    "UPDATE users SET edition = 'free_offline', plan_code = 'free_offline' WHERE id = %s",
                    (user_id,),
                )

    if subscription.grants_entitlement and not subscription.acknowledged:
        try:
            client.acknowledge(product_id=request.productId, purchase_token=request.purchaseToken)
        except GooglePlayVerificationError as error:
            logger.error("google_play_acknowledge_failed user_id=%s token_hash=%s error=%s", user_id, token_hash[:12], error)
            raise HTTPException(
                status_code=502,
                detail="Assinatura validada, mas o reconhecimento no Google Play falhou. Tente restaurar a compra.",
            ) from error

    return {
        "status": entitlement_status,
        "productId": subscription.product_id,
        "validUntil": entitlement_until.isoformat() if entitlement_until else None,
        "autoRenew": subscription.auto_renew,
    }


@app.get("/admin/users")
def list_users(_: dict[str, Any] = Depends(current_admin)) -> list[dict[str, Any]]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, email, is_admin, is_active, created_at
                FROM users
                ORDER BY id
                """
            )
            users = cursor.fetchall()
    return [
        {
            "id": user[0],
            "email": user[1],
            "isAdmin": user[2],
            "isActive": user[3],
            "createdAt": user[4].isoformat(),
        }
        for user in users
    ]


@app.post("/admin/users")
def create_user(request: AdminCreateUserRequest, _: dict[str, Any] = Depends(current_admin)) -> dict[str, Any]:
    email = request.email.strip().lower()
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1 FROM users WHERE email = %s", (email,))
            if cursor.fetchone() is not None:
                raise HTTPException(status_code=409, detail="E-mail já cadastrado.")
            cursor.execute(
                """
                INSERT INTO users (email, password_hash, is_admin)
                VALUES (%s, %s, %s)
                RETURNING id, email, is_admin, is_active, created_at
                """,
                (email, hash_password(request.password), request.isAdmin),
            )
            user = cursor.fetchone()
    return {"id": user[0], "email": user[1], "isAdmin": user[2], "isActive": user[3], "createdAt": user[4].isoformat()}


@app.post("/admin/users/{user_id}/status")
def update_user_status(user_id: int, request: AdminStatusRequest, admin: dict[str, Any] = Depends(current_admin)) -> dict[str, str]:
    if user_id == int(admin["sub"]):
        raise HTTPException(status_code=400, detail="A conta administrativa atual não pode ser desativada.")
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute("UPDATE users SET is_active = %s WHERE id = %s", (request.active, user_id))
            if cursor.rowcount == 0:
                raise HTTPException(status_code=404, detail="Usuário não encontrado.")
            if not request.active:
                cursor.execute("UPDATE auth_sessions SET revoked_at = now() WHERE user_id = %s AND revoked_at IS NULL", (user_id,))
    return {"status": "ok"}


@app.post("/admin/users/{user_id}/sessions/revoke")
def revoke_user_sessions(user_id: int, _: dict[str, Any] = Depends(current_admin)) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute("UPDATE auth_sessions SET revoked_at = now() WHERE user_id = %s AND revoked_at IS NULL", (user_id,))
            revoked = cursor.rowcount
    return {"status": "ok", "revoked": revoked}


@app.post("/admin/users/{user_id}/reset-token")
def create_user_reset_token(user_id: int, _: dict[str, Any] = Depends(current_admin)) -> dict[str, str]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT is_active FROM users WHERE id = %s", (user_id,))
            user = cursor.fetchone()
    if user is None:
        raise HTTPException(status_code=404, detail="Usuário não encontrado.")
    if not user[0]:
        raise HTTPException(status_code=409, detail="Ative o usuário antes de gerar a recuperação.")
    token, expires_at = issue_password_reset_token(user_id)
    logger.info("password_reset_token_issued_by_admin user_id=%s", user_id)
    return {"token": token, "expiresAt": expires_at.isoformat()}


@app.post("/sync/batch")
def push_batch(batch: SyncBatch, user: dict[str, Any] = Depends(current_user)) -> dict[str, Any]:
    if batch.contractVersion != "v2":
        raise HTTPException(status_code=422, detail="Versão de contrato não suportada.")
    user_id = int(user["sub"])
    acknowledged_ids = [operation.id for operation in batch.operations]
    received_at = utc_now()

    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT revision FROM user_snapshots WHERE user_id = %s FOR UPDATE",
                (user_id,),
            )
            current = cursor.fetchone()
            current_revision = int(current[0]) if current else 0
            if batch.baseRevision != current_revision:
                raise HTTPException(
                    status_code=409,
                    detail="Os dados desta conta foram atualizados em outro aparelho. Baixe a versão mais recente antes de enviar novas alterações.",
                )
            next_revision = current_revision + 1
            cursor.execute(
                """
                INSERT INTO sync_batches
                    (user_id, contract_version, generated_at, snapshot)
                VALUES (%s, %s, %s, %s)
                RETURNING id
                """,
                (
                    user_id,
                    batch.contractVersion,
                    batch.generatedAt,
                    psycopg.types.json.Jsonb(batch.snapshot),
                ),
            )
            batch_id = cursor.fetchone()[0]
            for operation in batch.operations:
                cursor.execute(
                    """
                    INSERT INTO sync_operations
                        (user_id, operation_id, entity_type, entity_id,
                         operation, occurred_at, batch_id)
                    VALUES (%s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT (user_id, operation_id) DO NOTHING
                    """,
                    (
                        user_id,
                        operation.id,
                        operation.entityType,
                        operation.entityId,
                        operation.operation,
                        operation.occurredAt,
                        batch_id,
                    ),
                )
            cursor.execute(
                """
                INSERT INTO user_snapshots
                    (user_id, snapshot, revision, generated_at, updated_at)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (user_id) DO UPDATE
                    SET snapshot = EXCLUDED.snapshot,
                        revision = EXCLUDED.revision,
                        generated_at = EXCLUDED.generated_at,
                        updated_at = EXCLUDED.updated_at
                """,
                (
                    user_id,
                    psycopg.types.json.Jsonb(batch.snapshot),
                    next_revision,
                    batch.generatedAt,
                    received_at,
                ),
            )

    return {
        "acknowledgedOperationIds": acknowledged_ids,
        "revision": next_revision,
        "serverTime": received_at.isoformat(),
    }


@app.get("/sync/snapshot")
def get_snapshot(user: dict[str, Any] = Depends(current_user)) -> dict[str, Any]:
    user_id = int(user["sub"])
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT snapshot, revision, generated_at, updated_at
                FROM user_snapshots
                WHERE user_id = %s
                """,
                (user_id,),
            )
            stored = cursor.fetchone()
    if stored is None:
        return {"snapshot": None, "revision": 0}
    return {
        "snapshot": stored[0],
        "revision": int(stored[1]),
        "generatedAt": stored[2].isoformat(),
        "updatedAt": stored[3].isoformat(),
    }


@app.post("/sync/entities")
def push_entities(
    batch: EntityBatch,
    user: dict[str, Any] = Depends(current_user),
) -> dict[str, Any]:
    user_id = int(user["sub"])
    acknowledged: list[dict[str, Any]] = []
    with database_connection() as connection:
        with connection.cursor() as cursor:
            for change in batch.changes:
                cursor.execute(
                    """
                    SELECT entity_type, entity_id, version
                    FROM entity_sync_operations
                    WHERE user_id = %s AND operation_id = %s
                    """,
                    (user_id, change.operationId),
                )
                processed = cursor.fetchone()
                if processed is not None:
                    if processed[0] != change.entityType or processed[1] != change.entityId:
                        raise HTTPException(
                            status_code=409,
                            detail="Identificador de operação já utilizado por outra entidade.",
                        )
                    acknowledged.append(
                        {
                            "operationId": change.operationId,
                            "entityType": change.entityType,
                            "entityId": change.entityId,
                            "version": int(processed[2]),
                        }
                    )
                    continue
                cursor.execute(
                    """
                    SELECT version
                    FROM user_entities
                    WHERE user_id = %s AND entity_type = %s AND entity_id = %s
                    FOR UPDATE
                    """,
                    (user_id, change.entityType, change.entityId),
                )
                current = cursor.fetchone()
                current_version = int(current[0]) if current else 0
                if change.baseVersion != current_version:
                    raise HTTPException(
                        status_code=409,
                        detail=f"Conflito na entidade {change.entityType}:{change.entityId}.",
                    )
                if not change.deleted and change.payload is None:
                    raise HTTPException(
                        status_code=422,
                        detail="Uma entidade ativa precisa conter payload.",
                    )
                next_version = current_version + 1
                cursor.execute(
                    """
                    INSERT INTO user_entities
                        (user_id, entity_type, entity_id, version, deleted,
                         payload, changed_at, updated_at)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, now())
                    ON CONFLICT (user_id, entity_type, entity_id) DO UPDATE SET
                        version = EXCLUDED.version,
                        deleted = EXCLUDED.deleted,
                        payload = EXCLUDED.payload,
                        changed_at = EXCLUDED.changed_at,
                        updated_at = now()
                    """,
                    (
                        user_id,
                        change.entityType,
                        change.entityId,
                        next_version,
                        change.deleted,
                        None if change.deleted else psycopg.types.json.Jsonb(change.payload),
                        change.changedAt,
                    ),
                )
                cursor.execute(
                    """
                    INSERT INTO entity_sync_operations
                        (user_id, operation_id, entity_type, entity_id, version)
                    VALUES (%s, %s, %s, %s, %s)
                    """,
                    (
                        user_id,
                        change.operationId,
                        change.entityType,
                        change.entityId,
                        next_version,
                    ),
                )
                acknowledged.append(
                    {
                        "operationId": change.operationId,
                        "entityType": change.entityType,
                        "entityId": change.entityId,
                        "version": next_version,
                    }
                )
    return {"acknowledged": acknowledged, "serverTime": utc_now().isoformat()}


@app.get("/sync/entities")
def get_entities(
    entityType: str = Query(pattern="^(pet|vaccine|weight|medication)$"),
    user: dict[str, Any] = Depends(current_user),
) -> dict[str, Any]:
    user_id = int(user["sub"])
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT entity_id, version, deleted, payload, changed_at, updated_at
                FROM user_entities
                WHERE user_id = %s AND entity_type = %s
                ORDER BY updated_at, entity_id
                """,
                (user_id, entityType),
            )
            rows = cursor.fetchall()
    return {
        "entities": [
            {
                "entityType": entityType,
                "entityId": row[0],
                "version": int(row[1]),
                "deleted": bool(row[2]),
                "payload": row[3],
                "changedAt": row[4].isoformat(),
                "updatedAt": row[5].isoformat(),
            }
            for row in rows
        ]
    }
