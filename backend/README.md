# AuMiau API

## Family, parceiros e atendimentos

O backend mantém os recursos comerciais do Family no PostgreSQL, sem depender
do banco local do celular.

- `GET/POST /family/invitations`: lista e cria convites por e-mail, pet, papel e permissões.
- `POST /family/invitations/{id}/accept`: aceita o convite somente para o e-mail autenticado do destinatário.
- `DELETE /family/invitations/{id}`: cancela um convite pendente.
- `GET /family/access`: lista os acessos ativos por pet.
- `GET /partners`: busca parceiros ativos por localização, serviço e urgência.
- `POST /admin/partners` e `PATCH /admin/partners/{id}/status`: cadastro e moderação administrativa.
- `GET/POST /appointments`: consulta e solicita atendimentos Family.
- `PATCH /appointments/{id}/status`: confirma, cancela, faz check-in ou conclui um atendimento.

Os endpoints de família e atendimento exigem entitlement `family_access` ativo.
A localização só é filtrada quando o usuário fornece latitude e longitude; o backend não coleta localização continuamente.

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

## Mercado Pago e Pix Family

O backend cria uma cobrança Pix individual em `POST /billing/orders`, usando o
plano informado pelo aplicativo e o valor definido no servidor. O QR Code
retornado pelo Mercado Pago é exclusivo para o pedido e não deve ser
substituído por um QR fixo.

Configure no `.env` da VPS:

```bash
MERCADOPAGO_ACCESS_TOKEN=APP_USR_...
MERCADOPAGO_WEBHOOK_SECRET=chave-gerada-em-Webhooks
MERCADOPAGO_ENVIRONMENT=test
MERCADOPAGO_NOTIFICATION_URL=https://aumiau.app.br/webhooks/mercadopago
```

No painel Mercado Pago, configure o evento **Order** para a URL HTTPS acima.
O endpoint valida `x-signature`, consulta a order no Mercado Pago e somente
depois cria a assinatura e ativa o entitlement `family_access`. O token e a
chave do webhook nunca devem ser colocados no APK, no Git ou enviados pelo
chat.

## Cadastro de usuários

O aplicativo oferece cadastro público em `POST /auth/register`. O usuário informa
nome, telefone, e-mail, senha, data de nascimento opcional e aceita os termos.
Quando `REQUIRE_EMAIL_VERIFICATION=true`, a API envia um token usando
`suporte@aumiau.app.br`; a confirmação é feita em `POST /auth/verify-email`.
Após a confirmação, o aplicativo cria a sessão automaticamente.

## Contas administrativas e operação assistida

Crie contas adicionais dentro do container da API. A senha é solicitada
interativamente e não deve ser passada na linha de comando:

```bash
docker compose exec api python scripts/create_user.py pessoa@dominio.com
```

As sessões usam access token curto, refresh token rotativo e logout com
revogação no servidor.
