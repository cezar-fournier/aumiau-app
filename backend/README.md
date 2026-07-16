# AuMiau API

Backend inicial do contrato de sincronização v1 do aplicativo.

## Serviços

- FastAPI: autenticação e sincronização.
- PostgreSQL: usuários, lotes, operações idempotentes e último snapshot.
- Caddy: proxy reverso e HTTPS automático quando `AUMIAU_DOMAIN` aponta para a VPS.

## Configuração

```bash
cp .env.example .env
nano .env
docker compose up -d --build
curl https://api.seudominio.com/health
```

## Painel e recuperação de senha

O painel administrativo está disponível em `/admin`. A autenticação acontece
por access token mantido apenas na memória da aba. A conta bootstrap é
administradora; novas contas criadas pelo comando acima são usuários comuns.

Para gerar um token de recuperação em operação assistida, use o servidor:

```bash
docker compose exec api python scripts/request_password_reset.py pessoa@dominio.com
```

O token exibido é único, expira conforme `RESET_TOKEN_TTL_MINUTES` e deve ser
entregue por um canal seguro. A confirmação é feita por
`POST /auth/password-reset/confirm`; ao trocar a senha, todas as sessões
anteriores são revogadas.

## Observabilidade

- `/health`: verificação básica da API e do PostgreSQL.
- `/ready`: readiness para publicação e monitoramento.
- `/metrics`: métricas agregadas em formato Prometheus, sem tokens ou dados
  pessoais sensíveis.
- Os logs registram método, caminho, status e duração, sem cabeçalhos ou corpo
  de requisições.

O arquivo `.env` contém credenciais e não deve ser versionado.

## Contas de produção

Crie contas adicionais dentro do container da API. A senha é solicitada
interativamente e não deve ser passada na linha de comando:

```bash
docker compose exec api python scripts/create_user.py pessoa@dominio.com
```

As sessões usam access token curto, refresh token rotativo e logout com
revogação no servidor.
