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
- `GET /partner/appointments`: lista a agenda pertencente ao parceiro autenticado.
- `PATCH /partner/appointments/{id}/status`: confirma, cancela ou conclui como parceiro.

Os endpoints de família e atendimento exigem entitlement `family_access` ativo.
A localização só é filtrada quando o usuário fornece latitude e longitude; o backend não coleta localização continuamente.

## Receituário veterinário preparatório

O módulo fica disponível somente para atendimentos concluídos e parceiros com
responsável técnico aprovado. Nesta etapa, o sistema gera apenas PDF de
receituário comum, sempre marcado como
`RASCUNHO — SEM VALIDADE PARA DISPENSAÇÃO`.

- `POST /partner/prescriptions`: cria o rascunho vinculado ao atendimento.
- `POST /partner/prescriptions/{id}/prepare`: gera o PDF e o QR de verificação.
- `GET /partner/prescriptions`: lista documentos do parceiro proprietário.
- `POST /partner/prescriptions/{id}/cancel`: cancela sem apagar o histórico.
- `GET /prescriptions`: lista documentos disponibilizados ao tutor.
- `GET /prescriptions/{id}/content`: entrega o PDF ao tutor proprietário.
- `GET /prescriptions/verify/{public_id}?token=...`: consulta pública mínima.

Antimicrobianos, receitas de controle especial e notificações controladas são
bloqueados antes da preparação. O estado `signed` existe para a futura
integração com assinatura eletrônica, mas não há endpoint que permita marcá-lo
sem a validação criptográfica de um provedor autorizado.

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
- Toda resposta inclui `X-Request-ID`; um identificador seguro enviado pelo
  cliente é preservado para correlação ponta a ponta.
- O logger `aumiau.api` produz eventos JSON com método, rota, status, duração e
  IP, sem registrar corpo, senha, token ou documento.
- `/metrics` expõe métricas Prometheus e indicadores do banco somente com
  `Authorization: Bearer <METRICS_TOKEN>`. Sem configuração, responde 404.
- `scripts/monitor_operations.py` verifica os endpoints, disco, idade do backup
  e containers. Os modelos em `ops/` executam o monitor a cada cinco minutos e
  permitem entregar alertas por webhook privado.

O arquivo `.env` contém credenciais e não deve ser versionado.

## Migrações e recuperação

Alterações novas do PostgreSQL devem ser adicionadas como arquivos SQL imutáveis
em `migrations/`. A API registra versão e SHA-256 em `schema_migrations` e recusa
uma migração já aplicada que tenha sido modificada.

Para gerar um backup local com checksum e retenção padrão de 14 dias:

```powershell
.\scripts\backup_postgres.ps1
```

Para comprovar a restauração em um banco temporário isolado:

```powershell
.\scripts\verify_restore.ps1 -DumpPath .\backups\aumiau-AAAAmmdd-HHMMSS.dump
```

O teste de restauração remove apenas o banco temporário criado por ele e não
altera o banco `aumiau` em uso.

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

## Google Play Billing Family

O aplicativo consulta os produtos `family_monthly` e `family_yearly` na Play
Store. Compras e restaurações enviam o `purchaseToken` autenticado para
`POST /billing/verify`. O backend consulta `purchases.subscriptionsv2.get`,
reconcilia todas as assinaturas Family da conta e reconhece compras novas no
servidor. O APK nunca concede o entitlement diretamente.

Configure somente na VPS:

```bash
GOOGLE_PLAY_PACKAGE_NAME=com.aumiau.aumiau_app
GOOGLE_PLAY_SERVICE_ACCOUNT_FILE=/run/secrets/google-play-service-account.json
```

No host de produção, mantenha o JSON fora do repositório, com permissão `600`,
por padrão em `/etc/aumiau/google-play-service-account.json`. O Compose monta o
arquivo somente para leitura em `/run/secrets/google-play-service-account.json`.
A conta de serviço deve receber apenas as permissões necessárias para consultar
e gerenciar pedidos e assinaturas do AuMiau no Google Play Console.

O JSON da conta de serviço deve ser montado como arquivo somente leitura, não
deve entrar na imagem Docker, no Git, em logs ou no aplicativo. A conta precisa
ter acesso ao app na Play Console e permissão para consultar e gerenciar pedidos
e assinaturas.

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
