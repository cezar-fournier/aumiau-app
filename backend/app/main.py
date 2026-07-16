from __future__ import annotations

import os
import hashlib
import logging
import secrets
import smtplib
import time
from datetime import datetime, timedelta, timezone
from email.message import EmailMessage
from typing import Any

import bcrypt
import jwt
import psycopg
from fastapi import Depends, FastAPI, Header, HTTPException, status
from fastapi.responses import HTMLResponse, PlainTextResponse
from pydantic import BaseModel, Field

from app.admin_panel import ADMIN_HTML


DATABASE_URL = os.environ["DATABASE_URL"]
JWT_SECRET = os.environ["JWT_SECRET"]
JWT_ALGORITHM = "HS256"
TOKEN_TTL_HOURS = int(os.getenv("TOKEN_TTL_HOURS", "24"))
REFRESH_TTL_DAYS = int(os.getenv("REFRESH_TTL_DAYS", "30"))
RESET_TOKEN_TTL_MINUTES = int(os.getenv("RESET_TOKEN_TTL_MINUTES", "30"))
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
            is_admin BOOLEAN NOT NULL DEFAULT FALSE,
            is_active BOOLEAN NOT NULL DEFAULT TRUE,
            created_at TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """,
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT FALSE",
        "ALTER TABLE users ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE",
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
    ]
    with database_connection() as connection:
        with connection.cursor() as cursor:
            for statement in statements:
                cursor.execute(statement)
            cursor.execute("DELETE FROM auth_sessions WHERE refresh_expires_at <= now()")
            cursor.execute("DELETE FROM password_reset_tokens WHERE expires_at <= now() OR used_at IS NOT NULL")


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
                "SELECT id, email, password_hash, is_active FROM users WHERE email = %s",
                (email,),
            )
            user = cursor.fetchone()
    if user is None or not user[3] or not check_password(request.password, user[2]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="E-mail ou senha inválidos.",
        )
    return create_auth_session(user[0], user[1])


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
