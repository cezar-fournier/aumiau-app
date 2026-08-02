# Linha de base do produto AuMiau

**Status:** autoridade vigente para desenvolvimento  
**Atualização:** 1º de agosto de 2026

Esta linha de base resolve as diferenças entre os documentos históricos. Em caso
de conflito, este arquivo prevalece para decisões de escopo e implementação.

## Produtos oficiais

### AuMiau Free Offline

- Sem conta obrigatória e com dados mantidos no aparelho.
- Limite de 1 pet, 1 rotina ativa e 1 compromisso ativo.
- Carteira e histórico locais, notificações locais e backup manual.
- Conversão para Family sempre explícita, precedida de backup e consentimento.

### AuMiau Family

- Conta verificada, múltiplos pets, sincronização e restauração.
- Histórico ampliado, família/cuidadores, parceiros e agenda.
- Acesso controlado por `family_access`, cuja fonte de verdade é o backend.
- Cobrança comercial somente em canal homologado e com validação server-side.

### AuMiau Parceiro

- O Parceiro opera no mesmo aplicativo oficial usado pelo Cliente, com contexto
  selecionado após a autenticação e permissões isoladas no backend.
- O aplicativo Parceiro separado foi aposentado e não deve voltar ao catálogo ou
  ao pipeline de release.
- A publicação do perfil depende de identidade, documentos, análise e
  entitlement válidos.

### AuMiau Clínicas

- Evolução posterior do ecossistema.
- Não pode ser promovido como plataforma clínica completa antes dos gates P0.
- A primeira entrega clínica deve ser vertical: agendamento, check-in, triagem,
  SOAP, prescrição e documento liberado ao tutor.

## Gates obrigatórios

1. Análise estática, testes, build e validação em dispositivo quando disponível.
2. Autorização por usuário e, no domínio clínico, por tenant/unidade/contexto.
3. MFA para administração e profissionais antes da operação clínica real.
4. Rate limit, logs seguros, documentos privados e trilha de auditoria.
5. Migrações versionadas, backup externo e restauração comprovada.
6. Compra, restauração, renovação, cancelamento e revogação reconciliados.
7. Português do Brasil, acessibilidade e estados offline/erro/sucesso revisados.

## Documentos históricos

Os documentos em `AuMiau_Pacote_Produto_v1.0` continuam como fonte de visão,
requisitos e contexto, mas não substituem esta decisão de catálogo e sequência.
O arquivo `documentacao-app-pets.md` representa a concepção inicial do produto.
