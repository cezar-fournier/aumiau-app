from __future__ import annotations

from html import escape


PRIVACY_POLICY_EFFECTIVE_DATE = "11 de agosto de 2026"
PRIVACY_CONTACT_EMAIL = "suporte@aumiau.app.br"


def privacy_policy_html() -> str:
    contact = escape(PRIVACY_CONTACT_EMAIL)
    effective_date = escape(PRIVACY_POLICY_EFFECTIVE_DATE)
    return f"""<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="light">
  <title>Política de Privacidade — AuMiau</title>
  <style>
    :root {{ color-scheme: light; --ink:#19362f; --muted:#5f6f69; --brand:#176b57; --paper:#fffdf8; --line:#dfe8e3; }}
    * {{ box-sizing: border-box; }}
    body {{ margin:0; background:#f5f2e9; color:var(--ink); font:16px/1.65 system-ui,-apple-system,"Segoe UI",sans-serif; overflow-wrap:anywhere; }}
    main {{ width:calc(100% - 32px); max-width:920px; min-width:0; margin:32px auto; padding:clamp(24px,5vw,56px); background:var(--paper); border:1px solid var(--line); border-radius:24px; box-shadow:0 18px 50px rgba(25,54,47,.08); }}
    h1 {{ margin:0 0 8px; font-size:clamp(2rem,6vw,3rem); line-height:1.12; }}
    h2 {{ margin-top:2.2rem; font-size:1.35rem; }}
    p,li {{ max-width:78ch; }}
    .tag {{ display:inline-block; margin-bottom:20px; padding:6px 12px; border:1px solid #e5c987; border-radius:999px; color:#765915; font-weight:700; font-size:.82rem; letter-spacing:.06em; text-transform:uppercase; }}
    .summary {{ padding:18px 20px; background:#edf7f3; border-left:4px solid var(--brand); border-radius:12px; }}
    a {{ color:var(--brand); font-weight:650; }}
    footer {{ margin-top:40px; padding-top:22px; border-top:1px solid var(--line); color:var(--muted); font-size:.92rem; }}
    @media (max-width:480px) {{
      main {{ width:100%; margin:0; padding:28px 22px 40px; border-width:0; border-radius:0; box-shadow:none; }}
      h1 {{ font-size:1.85rem; }}
      h2 {{ font-size:1.25rem; }}
      .summary {{ padding:16px; }}
    }}
  </style>
</head>
<body>
<main>
  <span class="tag">AuMiau</span>
  <h1>Política de Privacidade</h1>
  <p><strong>Vigência:</strong> {effective_date}</p>
  <p class="summary">Esta política explica como o AuMiau trata dados de tutores, animais e parceiros. O tratamento observa a Lei Geral de Proteção de Dados Pessoais (LGPD) e os princípios de finalidade, necessidade, segurança e transparência.</p>

  <h2>1. Controlador e contato</h2>
  <p>O AuMiau é desenvolvido e operado por <strong>Cezar Fournier</strong>. Dúvidas, solicitações de titulares e questões de privacidade podem ser enviadas para <a href="mailto:{contact}">{contact}</a>.</p>

  <h2>2. Dados que podem ser tratados</h2>
  <ul>
    <li><strong>Conta e identificação:</strong> nome, e-mail, telefone, data de nascimento, aceite de termos, perfil de acesso e credenciais protegidas por hash.</li>
    <li><strong>Dados dos animais:</strong> nome, espécie, raça, sexo, nascimento, peso, vacinas, medicamentos, rotina, observações, histórico e demais registros informados pelo tutor.</li>
    <li><strong>Atendimento veterinário:</strong> agendamentos, check-in, documentos, prescrições, registros clínicos e trilhas de auditoria de emissão, visualização ou download.</li>
    <li><strong>Parceiros:</strong> dados do estabelecimento ou profissional, endereço, serviços, localização, CPF ou CNPJ, registro profissional e documentos usados na verificação cadastral.</li>
    <li><strong>Pagamentos e assinaturas:</strong> produto, situação, vigência, identificadores da ordem e confirmações do provedor. O AuMiau não recebe nem armazena o número completo do cartão.</li>
    <li><strong>Dados técnicos e de segurança:</strong> sessões, identificadores de requisição, versão do aplicativo, registros operacionais, endereço IP e eventos necessários à prevenção de fraude e diagnóstico de falhas.</li>
    <li><strong>Localização:</strong> coordenadas aproximadas ou precisas somente quando o usuário aciona uma função que depende delas e concede a permissão do sistema.</li>
  </ul>

  <h2>3. Finalidades e bases legais</h2>
  <p>Os dados são usados para criar e proteger a conta, sincronizar registros, permitir atendimentos, localizar parceiros, processar assinaturas, prestar suporte, prevenir abuso, manter auditoria e cumprir obrigações legais ou regulatórias. Conforme o caso, as bases legais incluem execução de contrato, consentimento, cumprimento de obrigação legal, exercício regular de direitos e legítimo interesse, sempre com avaliação de necessidade.</p>

  <h2>4. Uso offline e sincronização</h2>
  <p>No modo Free Offline, os dados podem permanecer somente no aparelho. Ao usar uma conta conectada ou recursos Family/Parceiro, os registros selecionados podem ser enviados de forma protegida ao backend do AuMiau para sincronização, recuperação e acesso em outros dispositivos.</p>

  <h2>5. Compartilhamento e operadores</h2>
  <p>O AuMiau não vende dados pessoais. Dados podem ser compartilhados estritamente com prestadores necessários à operação, como infraestrutura de hospedagem e backup, envio de e-mails, Google Play, Apple App Store e Mercado Pago, de acordo com a plataforma e o meio de pagamento aplicável. Também podem ser fornecidos a autoridades quando houver obrigação legal.</p>

  <h2>6. Armazenamento, transferência e retenção</h2>
  <p>Os dados podem ser processados em infraestrutura contratada no Brasil ou no exterior, com medidas contratuais e técnicas compatíveis com a LGPD. Eles são mantidos enquanto a conta estiver ativa e pelo período necessário à prestação do serviço, segurança, auditoria e cumprimento de obrigações legais. Backups protegidos seguem ciclos próprios de retenção e expiração.</p>

  <h2>7. Segurança</h2>
  <p>Adotamos HTTPS, controle de acesso por recurso, autenticação, MFA administrativo, limitação de tentativas, validação de documentos, registros de auditoria, backups criptografados e testes de restauração. Nenhum sistema é absolutamente invulnerável; incidentes relevantes serão tratados conforme a legislação aplicável.</p>

  <h2>8. Direitos do titular e exclusão</h2>
  <p>O titular pode solicitar confirmação do tratamento, acesso, correção, portabilidade quando aplicável, informação sobre compartilhamentos, revogação do consentimento, oposição e eliminação de dados, observadas as hipóteses legais de conservação. A exclusão da conta pode ser executada diretamente no aplicativo em <strong>Perfil → Privacidade e dados → Excluir minha conta</strong>. Também disponibilizamos instruções e um canal alternativo em <a href="/excluir-conta">aumiau.app.br/excluir-conta</a>.</p>

  <h2>9. Crianças e adolescentes</h2>
  <p>O AuMiau é destinado a pessoas com 18 anos ou mais. Não buscamos coletar conscientemente dados de crianças ou adolescentes como titulares de conta.</p>

  <h2>10. Permissões do dispositivo</h2>
  <p>Localização, câmera, fotos, arquivos e notificações são acessados apenas para as funções correspondentes e conforme as permissões concedidas. O usuário pode revisar essas permissões nas configurações do dispositivo, sabendo que a revogação pode limitar determinados recursos.</p>

  <h2>11. Alterações desta política</h2>
  <p>Esta política poderá ser atualizada para refletir mudanças legais ou funcionais. Alterações relevantes serão comunicadas no aplicativo ou pelos canais disponíveis, com indicação da nova data de vigência.</p>

  <footer>AuMiau · Desenvolvido por Cezar Fournier · <a href="mailto:{contact}">{contact}</a></footer>
</main>
</body>
</html>"""


def account_deletion_html() -> str:
    contact = escape(PRIVACY_CONTACT_EMAIL)
    return f"""<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Exclusão de conta — AuMiau</title>
  <style>
    :root {{ --ink:#19362f; --muted:#5f6f69; --brand:#176b57; --danger:#a72d2d; --paper:#fffdf8; --line:#dfe8e3; }}
    * {{ box-sizing:border-box; }}
    body {{ margin:0; background:#f5f2e9; color:var(--ink); font:16px/1.65 system-ui,-apple-system,"Segoe UI",sans-serif; overflow-wrap:anywhere; }}
    main {{ width:calc(100% - 32px); max-width:820px; margin:32px auto; padding:clamp(24px,5vw,56px); background:var(--paper); border:1px solid var(--line); border-radius:24px; }}
    h1 {{ margin:0 0 8px; font-size:clamp(2rem,6vw,3rem); line-height:1.12; }}
    h2 {{ margin-top:2rem; font-size:1.3rem; }}
    .warning {{ padding:18px 20px; background:#fff1ef; border-left:4px solid var(--danger); border-radius:12px; }}
    .action {{ display:inline-block; padding:12px 18px; border-radius:12px; background:var(--brand); color:white; font-weight:750; text-decoration:none; }}
    a {{ color:var(--brand); font-weight:650; }}
    footer {{ margin-top:36px; padding-top:20px; border-top:1px solid var(--line); color:var(--muted); }}
    @media (max-width:480px) {{ main {{ width:100%; margin:0; padding:28px 22px 40px; border:0; border-radius:0; }} }}
  </style>
</head>
<body><main>
  <h1>Excluir conta AuMiau</h1>
  <p>Esta página explica como excluir uma conta e os dados associados ao AuMiau.</p>
  <p class="warning"><strong>A exclusão é permanente.</strong> O acesso é encerrado, os dados operacionais são eliminados ou anonimizados e não poderão ser recuperados.</p>
  <h2>Pelo aplicativo</h2>
  <ol><li>Entre na conta que deseja excluir.</li><li>Abra <strong>Perfil → Privacidade e dados → Excluir minha conta</strong>.</li><li>Confirme sua senha e digite <strong>EXCLUIR</strong>.</li></ol>
  <h2>Solicitação pela web</h2>
  <p>Se não conseguir acessar o aplicativo, solicite a exclusão usando o mesmo e-mail cadastrado. Poderemos pedir uma confirmação de identidade antes de executar o pedido.</p>
  <p><a class="action" href="mailto:{contact}?subject=Exclus%C3%A3o%20de%20conta%20AuMiau">Solicitar exclusão por e-mail</a></p>
  <h2>O que é excluído</h2>
  <p>Dados de perfil, sessões, endereço, sincronização, contatos privados, acessos Family e informações operacionais do parceiro são eliminados ou anonimizados.</p>
  <h2>Dados que podem ser conservados</h2>
  <p>Registros fiscais, antifraude, auditorias e documentos clínicos ou prescrições podem ser conservados pelo prazo legal aplicável. Nesses casos, o acesso à conta permanece bloqueado e os dados são limitados ao necessário para cumprimento de obrigação legal, defesa de direitos e segurança.</p>
  <footer>AuMiau · Desenvolvido por Cezar Fournier · <a href="mailto:{contact}">{contact}</a></footer>
</main></body></html>"""
