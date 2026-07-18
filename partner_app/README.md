# AuMiau Parceiro

Aplicativo Android inicial para clínicas e profissionais veterinários parceiros.

## Fluxos implementados

- Cadastro profissional com responsável, e-mail, telefone e aceite dos termos.
- CNPJ obrigatório com validação dos dígitos verificadores e unicidade cadastral.
- Login usando a API AuMiau existente.
- Perfil pendente até a confirmação da assinatura.
- Assinaturas mensal de R$ 2,99 e anual de R$ 25,00 via Mercado Pago/Pix.
- Publicação automática do perfil no diretório do cliente após pagamento confirmado.
- Painel com atendimentos solicitados, confirmados e do dia.
- APK debug gerado em `build/app/outputs/flutter-apk/app-debug.apk`.

## API utilizada

- `POST /partner/auth/register`
- `POST /auth/login`
- `GET /partner/profile`
- `GET /partner/dashboard`
- `POST /billing/orders`
- `PATCH /partner/appointments/{appointment_id}/status`

O token permanece apenas em memória nesta primeira base. Antes da distribuição comercial, será necessário integrar armazenamento seguro de sessão, política de privacidade específica do parceiro, assinatura Android de produção e testes de homologação com credenciais reais.
