# Publicação do AuMiau no TestFlight sem Mac próprio

O aplicativo iOS usa o Bundle ID `br.com.cainformatica.aumiau`. O workflow
`.github/workflows/ios-testflight.yml` executa em um runner `macos-26`, valida o
projeto Flutter e pode compilar, assinar e enviar o IPA ao TestFlight.

## Execução segura em duas fases

1. Execute manualmente o workflow com `upload_to_testflight=false` para validar
   compilação iOS sem assinatura e sem usar credenciais Apple.
2. Depois de registrar o aplicativo e configurar os segredos abaixo, execute com
   `upload_to_testflight=true` para assinar, validar e enviar ao TestFlight.

## Registros necessários na Apple

- Identificador explícito: `br.com.cainformatica.aumiau`.
- Aplicativo iOS no App Store Connect associado ao mesmo Bundle ID.
- Certificado do tipo Apple Distribution exportado como `.p12` com senha forte.
- Perfil de provisionamento App Store Connect para o Bundle ID do AuMiau.
- Chave da API do App Store Connect com acesso suficiente para enviar builds.

## Segredos do repositório privado

Cadastre em **Settings > Secrets and variables > Actions** do repositório privado:

- `APPLE_TEAM_ID`
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_BASE64`
- `IOS_DISTRIBUTION_CERTIFICATE_BASE64`
- `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`
- `IOS_PROVISIONING_PROFILE_BASE64`

Os três arquivos sensíveis devem ser convertidos localmente para Base64. Nunca
cole seus conteúdos em conversas, issues, commits ou logs.

No PowerShell:

```powershell
[Convert]::ToBase64String(
  [IO.File]::ReadAllBytes("C:\caminho\AuthKey_XXXXXXXXXX.p8")
) | Set-Clipboard

[Convert]::ToBase64String(
  [IO.File]::ReadAllBytes("C:\caminho\AuMiau-Distribution.p12")
) | Set-Clipboard

[Convert]::ToBase64String(
  [IO.File]::ReadAllBytes("C:\caminho\AuMiau-AppStore.mobileprovision")
) | Set-Clipboard
```

Copie um arquivo por vez e grave imediatamente no segredo correspondente. Limpe a
área de transferência ao terminar:

```powershell
Set-Clipboard -Value ""
```

## Controles aplicados pelo workflow

- usa Xcode 26.6 e SDK aceito para publicação em 2026;
- executa análise estática e testes Flutter;
- separa validação sem assinatura do envio real;
- valida equipe e Bundle ID contidos no perfil;
- cria um chaveiro temporário exclusivo no runner;
- valida o IPA antes do upload;
- remove chave, certificado e perfil ao final;
- mantém o IPA como artefato privado por apenas sete dias.

O primeiro build enviado cria a versão beta no App Store Connect. Após o
processamento da Apple, selecione o build no TestFlight, preencha as informações de
teste e adicione testadores internos ou envie-o à revisão beta para testadores
externos.
