# AuMiau App

Aplicativo Flutter para rotina, saúde e histórico dos pets em um só lugar.

## Distribuição e atualizações

Os únicos canais destinados aos usuários são:

- Android: Google Play, incluindo testes fechados e atualizações oficiais;
- iPhone: TestFlight durante o beta e App Store após o lançamento.

O aplicativo não consulta nem oferece downloads por GitHub Releases. No Android
instalado pela Google Play, a tela de perfil usa a API oficial de atualização da
loja. No iPhone, TestFlight/App Store gerenciam a instalação de novas versões.

O GitHub permanece como repositório do código e arquivo privado de artefatos de CI.
O workflow manual `build-release.yml` gera APK/AAB somente como artefatos internos,
sem criar uma Release pública e sem transformar o APK em canal de distribuição.

## Assinatura Android de produção

O build local continua funcionando com a assinatura de debug. Artefatos Android
arquivados exigem a assinatura definitiva, para impedir que um pacote seja
assinada por uma chave diferente da versão instalada.

No repositório GitHub, cadastre estes Secrets em **Settings > Secrets and variables >
Actions**:

- `ANDROID_KEYSTORE_BASE64`: keystore `.jks` codificado em Base64.
- `ANDROID_KEYSTORE_PASSWORD`: senha do keystore.
- `ANDROID_KEY_ALIAS`: alias da chave.
- `ANDROID_KEY_PASSWORD`: senha da chave.

O arquivo `android/key.properties.example` documenta o formato local. O keystore,
o arquivo `key.properties` e as senhas nunca devem ser commitados.

## Gerar arquivo interno Android

1. Atualize `version` em `pubspec.yaml`.
2. Execute `flutter analyze` e `flutter test`.
3. Execute manualmente o workflow `Archive AuMiau Android artifacts`.
4. Baixe o APK/AAB na área de artefatos da execução, se uma cópia técnica for necessária.

Antes da primeira release assinada, configure os quatro Secrets de assinatura. O
pipeline falha de forma intencional se uma tag for publicada sem esses Secrets.

O workflow está em `.github/workflows/build-release.yml`. Os pacotes são compilados
com a API de produção `https://aumiau.app.br/` e não dependem de arquivos `.env`
locais.

## Experiência Cliente e Parceiro

Cliente e Parceiro usam o mesmo aplicativo oficial. Após a autenticação, o app
seleciona o contexto operacional autorizado para a conta e apresenta os fluxos
correspondentes. O aplicativo Parceiro separado foi aposentado e não integra mais
o build nem o pipeline de publicação.

Cada release gera somente dois artefatos comerciais do aplicativo unificado:

- APK para instalação e homologação;
- AAB para publicação na Google Play Store.

## O que já está funcionando

- Dashboard Hoje com cuidados vencidos, de hoje e dos próximos sete dias.
- Persistência local SQLite com Drift e suporte offline.
- Notificações locais no Android/iOS para a véspera e o dia do cuidado.
- Cadastro e edição de pets, lembretes, vacinas e registros de peso.
- Linha do tempo unificada e exportação do histórico em PDF.
- Backup JSON local com restauração confirmada.
- Autenticação, sincronização segura e recuperação de senha via API.
- Atualizações oficiais pela Google Play no Android.

## Executar localmente

```powershell
flutter pub get
flutter run
```

Para gerar um APK local apontando para a API de produção:

```powershell
flutter build apk --release `
  --dart-define=AUMIAU_API_BASE_URL=https://aumiau.app.br/
```

## Segurança

Credenciais do backend, SMTP, banco de dados, chaves privadas e arquivos de ambiente
não fazem parte deste repositório. O workflow usa o `GITHUB_TOKEN` efêmero para
publicar os artefatos e remove o material de assinatura ao final da execução.
