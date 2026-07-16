# AuMiau App

Aplicativo Flutter para rotina, saúde e histórico dos pets em um só lugar.

## Download e atualizações para testes

Enquanto o cadastro da empresa e o D‑U‑N‑S Number para a Google Play Store estão em
andamento, o canal provisório de distribuição do Android fica no GitHub:

- Repositório: https://github.com/cezar-fournier/aumiau-app
- Downloads: https://github.com/cezar-fournier/aumiau-app/releases

Cada release publicada com uma tag `vMAJOR.MINOR.PATCH` gera automaticamente um APK
na página Releases. No Android, o usuário pode baixar o APK, autorizar a instalação
de fontes desconhecidas para o navegador/gerenciador de arquivos e instalar a nova
versão sobre a anterior.

O aplicativo consulta as Releases do GitHub ao abrir, informa quando há uma versão
mais recente e exibe uma notificação local com o link do download. Esse mecanismo é
um canal temporário de homologação; a distribuição oficial e as atualizações gerenciadas
serão migradas para a Google Play Store após a liberação do D‑U‑N‑S.

Usuários que quiserem acompanhar o canal também podem abrir o repositório, clicar em
`Watch` e escolher `Custom > Releases`. Assim, o próprio GitHub envia os avisos de novas
Releases para a conta do usuário, enquanto o app faz a verificação local ao ser aberto.

## Publicar uma nova versão

1. Atualize `version` em `pubspec.yaml`.
2. Execute `flutter analyze` e `flutter test`.
3. Crie e envie uma tag, por exemplo:

```powershell
git tag v0.1.1
git push origin v0.1.1
```

4. O GitHub Actions compila, valida e anexa o APK à Release automaticamente.

O workflow está em `.github/workflows/build-release.yml`. O APK é compilado com a API
de produção `https://aumiau.app.br/` e não depende de arquivos `.env` locais.

## O que já está funcionando

- Dashboard Hoje com cuidados vencidos, de hoje e dos próximos sete dias.
- Persistência local SQLite com Drift e suporte offline.
- Notificações locais no Android/iOS para a véspera e o dia do cuidado.
- Cadastro e edição de pets, lembretes, vacinas e registros de peso.
- Linha do tempo unificada e exportação do histórico em PDF.
- Backup JSON local com restauração confirmada.
- Autenticação, sincronização segura e recuperação de senha via `https://aumiau.app.br/`.
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
não fazem parte deste repositório. O workflow usa apenas o `GITHUB_TOKEN` efêmero
fornecido pelo GitHub Actions para publicar os artefatos.

O protótipo e o modelo PostgreSQL originais permanecem no pacote de produto local como
referência de produto e arquitetura.
