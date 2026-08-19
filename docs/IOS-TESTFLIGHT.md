# Publicação do AuMiau no TestFlight sem Mac próprio

O aplicativo iOS usa o Bundle ID `br.com.cainformatica.aumiau`. O workflow
`.github/workflows/ios-testflight.yml` executa em um runner `macos-26`, valida o
projeto Flutter e pode compilar, assinar e enviar o IPA ao TestFlight.

O GitHub Actions é apenas a infraestrutura de compilação remota. Ele fornece uma
máquina macOS temporária com Xcode porque o IPA não pode ser produzido no Windows.
O canal de instalação e atualização para os testadores continua sendo o TestFlight;
o GitHub não deve ser divulgado como fonte de download do aplicativo.

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

O workflow pode ser executado manualmente ou automaticamente por uma tag
`stores-v*`. Antes de criar a tag, incremente obrigatoriamente o número de build em
`pubspec.yaml`, confirme os testes locais e verifique se a mesma revisão de código
está pronta para Google Play e TestFlight.

O envio deve acontecer no repositório privado `cezar-fournier/aumiau-source`, onde
ficam os segredos Apple. Ao publicar por tag, envie-a ao remoto privado:

```powershell
git push source stores-v<versão>
```

Uma tag enviada apenas ao repositório público não publica o aplicativo. Os jobs de
loja possuem uma proteção explícita que permite sua execução somente no repositório
privado.

O primeiro build enviado cria a versão beta no App Store Connect. Após o
processamento da Apple, selecione o build no TestFlight, preencha as informações de
teste e adicione testadores internos ou envie-o à revisão beta para testadores
externos.
