# AuMiau App

Aplicativo Flutter para rotina, saúde e histórico dos pets em um só lugar.

## Download e atualizações para testes

Enquanto o cadastro da empresa e o D-U-N-S Number para a Google Play Store estão em
andamento, o canal provisório de distribuição do Android fica no GitHub:

- Repositório: https://github.com/cezar-fournier/aumiau-app
- Downloads: https://github.com/cezar-fournier/aumiau-app/releases

Cada release publicada com uma tag `vMAJOR.MINOR.PATCH` gera automaticamente um APK
e um AAB. O AAB é o pacote destinado à Play Store; o APK é usado para instalação
direta e homologação.

O aplicativo consulta as Releases do GitHub ao abrir, informa quando há uma versão
mais recente e exibe uma notificação local com o link do download. Esse mecanismo é
um canal temporário de homologação; a distribuição oficial e as atualizações
gerenciadas serão migradas para a Google Play Store após a liberação do D-U-N-S.

Usuários que quiserem acompanhar o canal também podem abrir o repositório, clicar em
`Watch` e escolher `Custom > Releases`. Assim, o próprio GitHub envia os avisos de
novas Releases para a conta do usuário, enquanto o app faz a verificação local ao
ser aberto.

## Assinatura Android de produção

O build local continua funcionando com a assinatura de debug. Releases versionadas
no GitHub exigem a assinatura definitiva, para impedir que uma atualização seja
assinada por uma chave diferente da versão instalada.

No repositório GitHub, cadastre estes Secrets em **Settings > Secrets and variables >
Actions**:

- `ANDROID_KEYSTORE_BASE64`: keystore `.jks` codificado em Base64.
- `ANDROID_KEYSTORE_PASSWORD`: senha do keystore.
- `ANDROID_KEY_ALIAS`: alias da chave.
- `ANDROID_KEY_PASSWORD`: senha da chave.

O arquivo `android/key.properties.example` documenta o formato local. O keystore,
o arquivo `key.properties` e as senhas nunca devem ser commitados.

## Publicar uma nova versão

1. Atualize `version` em `pubspec.yaml`.
2. Execute `flutter analyze` e `flutter test`.
3. Crie e envie uma tag, por exemplo:

```powershell
git tag v0.2.0
git push origin v0.2.0
```

4. O GitHub Actions compila, valida e anexa o APK e o AAB à Release automaticamente.

Antes da primeira release assinada, configure os quatro Secrets de assinatura. O
pipeline falha de forma intencional se uma tag for publicada sem esses Secrets.

O workflow está em `.github/workflows/build-release.yml`. Os pacotes são compilados
com a API de produção `https://aumiau.app.br/` e não dependem de arquivos `.env`
locais.

## O que já está funcionando

- Dashboard Hoje com cuidados vencidos, de hoje e dos próximos sete dias.
- Persistência local SQLite com Drift e suporte offline.
- Notificações locais no Android/iOS para a véspera e o dia do cuidado.
- Cadastro e edição de pets, lembretes, vacinas e registros de peso.
- Linha do tempo unificada e exportação do histórico em PDF.
- Backup JSON local com restauração confirmada.
- Autenticação, sincronização segura e recuperação de senha via API.
- Verificação de novas versões publicadas no GitHub.

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
