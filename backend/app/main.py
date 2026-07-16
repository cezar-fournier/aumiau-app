from __future__ import annotations

import os
import hashlib
import hmac
import json
import logging
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
from fastapi.responses import HTMLResponse, PlainTextResponse
from pydantic import BaseModel, Field

from app.admin_panel import ADMIN_HTML


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
logger = logging.getLogger("aumiau.api")
STARTED_AT = time.monotonic()


class LoginRequest(BaseModel):
    email: str = Field(min_length=3, max_length=180)
    password: str = Field(min_length=8, max_length=128)


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
    snapshot: dict[str, Any]
    operations: list[Operation] = Field(max_length=1000)


app = FastAPI(title="AuMiau API", version="1.0.0")

BILLING_PRODUCTS: dict[str, dict[str, Any]] = {
    "family_monthly": {
        "amountBrl": "5.76",
        "periodDays": 30,
        "billingPeriod": "P1M",
        "displayName": "AuMiau Family mensal",
    },
    "family_yearly": {
        "amountBrl": "46.55",
        "periodDays": 365,
        "billingPeriod": "P1Y",
        "displayName": "AuMiau Family anual",
    },
}


@app.middleware("http")
async def request_logging(request, call_next):
    started = time.perf_counter()
    response = await call_next(request)
    elapsed_ms = (time.perf_counter() - started) * 1000
    logger.info(
        "request method=%s path=%s status=%s duration_ms=%.1f",
        request.method,
        request.url.path,
        response.status_code,
        elapsed_ms,
    )
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


def send_email_verification(recipient: str, token: str, expires_at: datetime) -> None:
    if not SMTP_HOST or not SMTP_USERNAME or not SMTP_PASSWORD or not SMTP_FROM:
        raise RuntimeError("SMTP de verificação não configurado.")
    message = EmailMessage()
    message["Subject"] = "AuMiau — confirme seu e-mail"
    message["From"] = SMTP_FROM
    message["To"] = recipient
    message.set_content(
        "Olá!\n\n"
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


def send_password_reset_email(recipient: str, token: str, expires_at: datetime) -> None:
    if not SMTP_HOST or not SMTP_USERNAME or not SMTP_PASSWORD or not SMTP_FROM:
        raise RuntimeError("SMTP de recuperação não configurado.")
    message = EmailMessage()
    message["Subject"] = "AuMiau — recuperação de senha"
    message["From"] = SMTP_FROM
    message["To"] = recipient
    message.set_content(
        "Olá!\n\n"
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


def create_auth_session(user_id: int, email: str) -> dict[str, str]:
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
                    (jti, user_id, refresh_token_hash, refresh_expires_at)
                VALUES (%s, %s, %s, %s)
                """,
                (session_jti, user_id, hash_refresh_token(refresh_token), refresh_expires_at),
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


def current_admin(user: dict[str, Any] = Depends(current_user)) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT is_admin, is_active FROM users WHERE id = %s",
                (int(user["sub"]),),
            )
            account = cursor.fetchone()
    if account is None or not account[0] or not account[1]:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Acesso administrativo necessário.")
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
    ]
    with database_connection() as connection:
        with connection.cursor() as cursor:
            for statement in statements:
                cursor.execute(statement)
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
            else:
                cursor.execute("UPDATE users SET is_admin = TRUE, is_active = TRUE WHERE id = %s", (user[0],))


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
def metrics() -> str:
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
    return "\n".join(
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


@app.get("/admin", response_class=HTMLResponse)
def admin_panel() -> str:
    return ADMIN_HTML


@app.post("/auth/login")
def login(request: LoginRequest) -> dict[str, str]:
    email = request.email.strip().lower()
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "SELECT id, email, password_hash, is_active, email_verified FROM users WHERE email = %s",
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
    return create_auth_session(user[0], user[1])


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
            send_email_verification(email, token, expires_at)
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
            cursor.execute("SELECT id, is_active FROM users WHERE email = %s", (email,))
            user = cursor.fetchone()
    if user is not None and user[1]:
        token, expires_at = issue_password_reset_token(user[0])
        try:
            send_password_reset_email(email, token, expires_at)
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
                SELECT sessions.id, sessions.user_id, users.email
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
    return create_auth_session(session[1], session[2])


@app.post("/auth/logout")
def logout(user: dict[str, Any] = Depends(current_user)) -> dict[str, str]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                "UPDATE auth_sessions SET revoked_at = now() WHERE jti = %s",
                (user["jti"],),
            )
    return {"status": "ok"}


@app.get("/account/status")
def account_status(user: dict[str, Any] = Depends(current_user)) -> dict[str, Any]:
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT users.edition, users.plan_code,
                       entitlements.status, entitlements.valid_until,
                       subscriptions.status, subscriptions.expires_at
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
                (int(user["sub"]),),
            )
            account = cursor.fetchone()
    if account is None:
        raise HTTPException(status_code=404, detail="Conta não encontrada.")
    entitlement_status = account[2] or "none"
    if account[3] and account[3] <= utc_now():
        entitlement_status = "expired"
    return {
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


@app.get("/billing/catalog")
def billing_catalog() -> dict[str, Any]:
    return {
        "currencyPolicy": "localized_by_store",
        "referenceCurrency": "EUR",
        "products": [
            {
                "productId": "family_monthly",
                "billingPeriod": "P1M",
                "referencePriceEur": "0.99",
                "pixAmountBrl": "5.76",
                "displayName": "AuMiau Family mensal",
            },
            {
                "productId": "family_yearly",
                "billingPeriod": "P1Y",
                "referencePriceEur": "8.00",
                "pixAmountBrl": "46.55",
                "displayName": "AuMiau Family anual",
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
        "ticketUrl": payment_method.get("ticket_url"),
    }


def _apply_mercadopago_order(order: dict[str, Any]) -> dict[str, Any] | None:
    provider_order_id = order.get("id")
    if not isinstance(provider_order_id, str) or not provider_order_id:
        return None
    payment = _order_payment(order)
    payment_status = str(payment["status"]).lower()
    order_status = str(order.get("status") or "").lower()
    paid = order_status == "processed" or payment_status in {"approved", "processed"}
    status_value = "active" if paid else order_status or payment_status or "pending"
    now = utc_now()

    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, user_id, product_id, amount_brl, status, paid_at
                FROM billing_orders
                WHERE provider_order_id = %s
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
                cursor.execute(
                    """
                    SELECT valid_until
                    FROM entitlements
                    WHERE user_id = %s AND entitlement_key = 'family_access'
                    """,
                    (local_order[1],),
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
                    VALUES (%s, 'family_access', 'mercadopago', 'active',
                            %s, %s, now())
                    ON CONFLICT (user_id, entitlement_key) DO UPDATE SET
                        source = 'mercadopago',
                        status = 'active',
                        valid_from = EXCLUDED.valid_from,
                        valid_until = EXCLUDED.valid_until,
                        updated_at = now()
                    """,
                    (local_order[1], now, valid_until),
                )
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
                    ticket_url = COALESCE(%s, ticket_url),
                    paid_at = CASE WHEN %s AND paid_at IS NULL THEN now() ELSE paid_at END,
                    updated_at = now()
                WHERE provider_order_id = %s
                """,
                (
                    payment["paymentId"], status_value, payment["statusDetail"],
                    payment["qrCode"], payment["ticketUrl"], paid,
                    provider_order_id,
                ),
            )
    return {
        "orderId": provider_order_id,
        "status": "active" if paid else status_value,
        "paid": paid or already_paid,
        "validUntil": valid_until.isoformat() if valid_until else None,
    }


@app.post("/billing/orders")
def create_billing_order(
    request: BillingOrderRequest,
    user: dict[str, Any] = Depends(current_user),
) -> dict[str, Any]:
    product = BILLING_PRODUCTS.get(request.productId)
    if product is None:
        raise HTTPException(status_code=400, detail="Plano Family inválido.")
    with database_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute("SELECT email FROM users WHERE id = %s", (int(user["sub"]),))
            account = cursor.fetchone()
    if account is None:
        raise HTTPException(status_code=404, detail="Conta não encontrada.")

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
            "transactions": {
                "payments": [
                    {
                        "amount": amount,
                        "payment_method": {"id": "pix", "type": "bank_transfer"},
                        "expiration_time": "P1D",
                    }
                ]
            },
            "payer": {"email": account[0]},
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
                     status, status_detail, environment, qr_code, ticket_url,
                     expires_at, updated_at)
                VALUES (%s, 'mercadopago', %s, %s, %s, %s, %s, %s, %s,
                        %s, %s, %s, %s, now())
                ON CONFLICT (provider_order_id) DO UPDATE SET
                    qr_code = EXCLUDED.qr_code,
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
                    qr_code, payment["ticketUrl"], expires_at,
                ),
            )
    return {
        "provider": "mercadopago",
        "orderId": provider_order_id,
        "productId": request.productId,
        "amountBrl": float(amount),
        "status": response.get("status") or payment["status"],
        "qrCode": qr_code,
        "ticketUrl": payment["ticketUrl"],
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
                       ticket_url, expires_at, paid_at
                FROM billing_orders
                WHERE provider_order_id = %s AND user_id = %s
                """,
                (order_id, int(user["sub"])),
            )
            local_order = cursor.fetchone()
    if local_order is None:
        raise HTTPException(status_code=404, detail="Pedido não encontrado.")
    if MERCADOPAGO_ACCESS_TOKEN and not local_order[7]:
        try:
            _apply_mercadopago_order(mercadopago_request("GET", f"/v1/orders/{order_id}"))
        except HTTPException:
            logger.warning("mercadopago_order_refresh_failed order_id=%s", order_id)
        with database_connection() as connection:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT product_id, amount_brl, status, status_detail, qr_code,
                           ticket_url, expires_at, paid_at
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
        "ticketUrl": local_order[5],
        "expiresAt": local_order[6].isoformat() if local_order[6] else None,
        "paidAt": local_order[7].isoformat() if local_order[7] else None,
        "paid": local_order[7] is not None,
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
    _: dict[str, Any] = Depends(current_user),
) -> dict[str, str]:
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail=(
            "A verificação do Google Play será habilitada quando o aplicativo "
            "estiver configurado na Play Console. Nenhum acesso pago foi concedido."
        ),
    )


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
    if batch.contractVersion != "v1":
        raise HTTPException(status_code=422, detail="Versão de contrato não suportada.")
    user_id = int(user["sub"])
    acknowledged_ids = [operation.id for operation in batch.operations]
    received_at = utc_now()

    with database_connection() as connection:
        with connection.cursor() as cursor:
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
                INSERT INTO user_snapshots (user_id, snapshot, updated_at)
                VALUES (%s, %s, %s)
                ON CONFLICT (user_id) DO UPDATE
                    SET snapshot = EXCLUDED.snapshot,
                        updated_at = EXCLUDED.updated_at
                """,
                (user_id, psycopg.types.json.Jsonb(batch.snapshot), received_at),
            )

    return {
        "acknowledgedOperationIds": acknowledged_ids,
        "serverTime": received_at.isoformat(),
    }
