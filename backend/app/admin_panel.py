ADMIN_HTML = r"""<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>AuMiau | Administração</title>
  <style>
    :root { color-scheme: dark; font-family: Inter, system-ui, sans-serif; }
    body { margin: 0; background: #101827; color: #e8eef8; }
    main { max-width: 1100px; margin: 0 auto; padding: 32px 18px 60px; }
    .card { background: #172338; border: 1px solid #2b3b58; border-radius: 14px; padding: 20px; margin: 14px 0; }
    h1, h2 { margin-top: 0; } h1 { color: #8de4c4; }
    form { display: grid; gap: 10px; max-width: 520px; }
    input, button { border-radius: 8px; border: 1px solid #405474; padding: 10px 12px; font: inherit; }
    input { background: #0f192a; color: inherit; } button { background: #2aa37a; color: #07130f; cursor: pointer; font-weight: 700; }
    button.secondary { background: #30415f; color: #e8eef8; } button.danger { background: #d75c67; color: white; }
    label { display: flex; gap: 8px; align-items: center; } label input { accent-color: #2aa37a; }
    #app { display: none; } #message { min-height: 24px; color: #8de4c4; white-space: pre-wrap; }
    table { width: 100%; border-collapse: collapse; font-size: 14px; } th, td { text-align: left; padding: 10px 8px; border-bottom: 1px solid #2b3b58; vertical-align: top; }
    .actions { display: flex; flex-wrap: wrap; gap: 6px; } .actions button { padding: 7px 9px; font-size: 12px; }
    .document-details { background: #0f192a; padding: 14px; }
    .document-details table { font-size: 13px; }
    .status-approved { color: #8de4c4; font-weight: 700; }
    .status-pending { color: #ffd47a; font-weight: 700; }
    .status-rejected { color: #ff9fa8; font-weight: 700; }
    .muted { color: #9eabc0; font-size: 13px; }
  </style>
</head>
<body>
<main>
  <h1>AuMiau — Administração</h1>
  <p class="muted">Sessão administrativa mantida somente na memória desta aba.</p>
  <section id="login" class="card">
    <h2>Entrar</h2>
    <form id="login-form">
      <input id="login-email" type="email" placeholder="E-mail" autocomplete="username" required>
      <input id="login-password" type="password" placeholder="Senha" autocomplete="current-password" required>
      <button type="submit">Acessar painel</button>
    </form>
    <form id="mfa-form" style="display:none">
      <input id="mfa-code" inputmode="numeric" autocomplete="one-time-code" placeholder="Código do autenticador ou recuperação" required>
      <button type="submit">Validar segundo fator</button>
    </form>
  </section>
  <section id="app">
    <div id="mfa-setup" class="card" style="display:none">
      <h2>Ativar autenticação em dois fatores</h2>
      <p class="muted">Adicione a chave ao aplicativo autenticador e confirme o código.</p>
      <button id="mfa-start" type="button">Gerar chave TOTP</button>
      <pre id="mfa-secret"></pre>
      <form id="mfa-activate-form" style="display:none">
        <input id="mfa-activate-code" inputmode="numeric" autocomplete="one-time-code" placeholder="Código de seis dígitos" required>
        <button type="submit">Confirmar e ativar</button>
      </form>
    </div>
    <div class="card">
      <h2>Criar usuário</h2>
      <form id="create-form">
        <input id="new-email" type="email" placeholder="E-mail" required>
        <input id="new-password" type="password" placeholder="Senha (mínimo 8 caracteres)" minlength="8" required>
        <label><input id="new-admin" type="checkbox"> Administrador</label>
        <button type="submit">Criar usuário</button>
      </form>
    </div>
    <div class="card">
      <h2>Usuários</h2>
      <div id="table-wrap"></div>
    </div>
    <div class="card">
      <h2>Parceiros para análise</h2>
      <p class="muted">Perfis pendentes permanecem ocultos no mapa do cliente.</p>
      <div id="partner-table-wrap"></div>
      <p><button id="refresh-partners" class="secondary">Atualizar parceiros</button></p>
    </div>
    <div class="card">
      <p><button id="logout" class="secondary">Sair</button></p>
    </div>
  </section>
  <p id="message"></p>
</main>
<script>
(() => {
  let token = null;
  let mfaChallengeToken = null;
  const $ = (id) => document.getElementById(id);
  const message = (text, error = false) => { $('message').textContent = text; $('message').style.color = error ? '#ff9fa8' : '#8de4c4'; };
  const api = async (path, options = {}) => {
    const headers = Object.assign({'Content-Type': 'application/json'}, options.headers || {});
    if (token) headers.Authorization = `Bearer ${token}`;
    const response = await fetch(path, Object.assign({}, options, {headers}));
    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(data.detail || `Erro HTTP ${response.status}`);
    return data;
  };
  const renderUsers = (users) => {
    const wrap = $('table-wrap'); wrap.textContent = '';
    const table = document.createElement('table');
    const head = document.createElement('tr'); ['ID', 'E-mail', 'Perfil', 'Status', 'Ações'].forEach((value) => { const cell = document.createElement('th'); cell.textContent = value; head.appendChild(cell); });
    const thead = document.createElement('thead'); thead.appendChild(head); table.appendChild(thead);
    const body = document.createElement('tbody');
    users.forEach((user) => {
      const row = document.createElement('tr');
      [user.id, user.email, user.isAdmin ? 'Administrador' : 'Usuário', user.isActive ? 'Ativo' : 'Desativado'].forEach((value) => { const cell = document.createElement('td'); cell.textContent = String(value); row.appendChild(cell); });
      const actions = document.createElement('td'); actions.className = 'actions';
      const statusButton = document.createElement('button'); statusButton.className = user.isActive ? 'danger' : 'secondary'; statusButton.textContent = user.isActive ? 'Desativar' : 'Ativar'; statusButton.onclick = async () => { try { await api(`/admin/users/${user.id}/status`, {method: 'POST', body: JSON.stringify({active: !user.isActive})}); await loadUsers(); message('Status atualizado.'); } catch (error) { message(error.message, true); } };
      const revokeButton = document.createElement('button'); revokeButton.className = 'secondary'; revokeButton.textContent = 'Revogar sessões'; revokeButton.onclick = async () => { try { await api(`/admin/users/${user.id}/sessions/revoke`, {method: 'POST'}); message('Sessões revogadas.'); } catch (error) { message(error.message, true); } };
      const resetButton = document.createElement('button'); resetButton.className = 'secondary'; resetButton.textContent = 'Gerar recuperação'; resetButton.onclick = async () => { try { const result = await api(`/admin/users/${user.id}/reset-token`, {method: 'POST'}); message(`Token temporário para ${user.email}:\n${result.token}\nExpira em ${result.expiresAt}`); } catch (error) { message(error.message, true); } };
      actions.append(statusButton, revokeButton, resetButton); row.appendChild(actions); body.appendChild(row);
    });
    table.appendChild(body); wrap.appendChild(table);
  };
  const statusClass = (status) => `status-${status}`;
  const statusLabel = (status) => ({approved: 'Aprovado', pending: 'Pendente', rejected: 'Rejeitado'})[status] || status;
  const downloadDocument = async (documentId) => {
    const response = await fetch(`/admin/partner-documents/${documentId}/content`, {headers: {Authorization: `Bearer ${token}`}});
    if (!response.ok) throw new Error(`Não foi possível abrir o documento (HTTP ${response.status}).`);
    const blob = await response.blob();
    const objectUrl = URL.createObjectURL(blob);
    window.open(objectUrl, '_blank', 'noopener');
    setTimeout(() => URL.revokeObjectURL(objectUrl), 60000);
  };
  const renderDocumentDetails = (container, partnerId, payload) => {
    container.textContent = '';
    const title = document.createElement('strong'); title.textContent = `Documentos de ${payload.partner.name}`; container.appendChild(title);
    const summary = document.createElement('p'); summary.className = 'muted';
    summary.textContent = payload.requirements.readyForApproval ? 'Todos os documentos obrigatórios foram aprovados.' : 'A aprovação do perfil permanece bloqueada até concluir a análise documental.';
    container.appendChild(summary);
    const requirements = document.createElement('ul');
    payload.requirements.required.forEach((item) => {
      const found = payload.documents.find((doc) => doc.documentType === item.type && doc.verificationStatus === 'approved');
      const li = document.createElement('li'); li.textContent = `${item.label}: ${found ? 'aprovado' : 'pendente'}`; li.className = found ? 'status-approved' : 'status-pending'; requirements.appendChild(li);
    });
    container.appendChild(requirements);
    if (!payload.documents.length) { const empty = document.createElement('p'); empty.className = 'muted'; empty.textContent = 'Nenhum documento foi enviado pelo parceiro.'; container.appendChild(empty); return; }
    const table = document.createElement('table');
    const head = document.createElement('tr'); ['Tipo', 'Arquivo', 'Hash', 'Status', 'Revisado em', 'Ações'].forEach((value) => { const cell = document.createElement('th'); cell.textContent = value; head.appendChild(cell); });
    const thead = document.createElement('thead'); thead.appendChild(head); table.appendChild(thead);
    const body = document.createElement('tbody');
    payload.documents.forEach((doc) => {
      const row = document.createElement('tr');
      [doc.documentType, doc.fileName, doc.documentHash.slice(0, 16) + '…', statusLabel(doc.verificationStatus), doc.reviewedAt || '—'].forEach((value, index) => { const cell = document.createElement('td'); cell.textContent = String(value); if (index === 3) cell.className = statusClass(doc.verificationStatus); row.appendChild(cell); });
      const actions = document.createElement('td'); actions.className = 'actions';
      const open = document.createElement('button'); open.className = 'secondary'; open.textContent = 'Abrir'; open.onclick = async () => { try { await downloadDocument(doc.id); } catch (error) { message(error.message, true); } };
      const approve = document.createElement('button'); approve.textContent = 'Aprovar documento'; approve.disabled = doc.verificationStatus === 'approved'; approve.onclick = async () => { try { await api(`/admin/partner-documents/${doc.id}`, {method: 'PATCH', body: JSON.stringify({status: 'approved', rejectionReason: ''})}); await loadPartnerDocuments(partnerId, container); await loadPartners(); message('Documento aprovado e auditoria registrada.'); } catch (error) { message(error.message, true); } };
      const reject = document.createElement('button'); reject.className = 'danger'; reject.textContent = 'Rejeitar'; reject.onclick = async () => { const reason = window.prompt('Informe o motivo da rejeição:'); if (!reason || !reason.trim()) return; try { await api(`/admin/partner-documents/${doc.id}`, {method: 'PATCH', body: JSON.stringify({status: 'rejected', rejectionReason: reason.trim()})}); await loadPartnerDocuments(partnerId, container); await loadPartners(); message('Documento rejeitado e justificativa registrada.'); } catch (error) { message(error.message, true); } };
      actions.append(open, approve, reject); row.appendChild(actions); body.appendChild(row);
    });
    table.appendChild(body); container.appendChild(table);
  };
  const loadPartnerDocuments = async (partnerId, container) => {
    container.textContent = 'Carregando documentos…';
    try { const payload = await api(`/admin/partners/${partnerId}/documents`); renderDocumentDetails(container, partnerId, payload); } catch (error) { container.textContent = ''; message(error.message, true); }
  };
  const renderPartners = (partners) => {
    const wrap = $('partner-table-wrap'); wrap.textContent = '';
    if (!partners.length) { wrap.textContent = 'Nenhum cadastro de parceiro.'; return; }
    const table = document.createElement('table');
    const head = document.createElement('tr'); ['ID', 'Estabelecimento', 'Documento', 'E-mail', 'Status', 'Documentos', 'Ações'].forEach((value) => { const cell = document.createElement('th'); cell.textContent = value; head.appendChild(cell); });
    const thead = document.createElement('thead'); thead.appendChild(head); table.appendChild(thead);
    const body = document.createElement('tbody');
    partners.forEach((partner) => {
      const row = document.createElement('tr');
      [partner.id, partner.name, partner.document || '-', partner.email, `${partner.verificationStatus} / ${partner.status}`, partner.documentCount].forEach((value) => { const cell = document.createElement('td'); cell.textContent = String(value); row.appendChild(cell); });
      const actions = document.createElement('td'); actions.className = 'actions';
      const detailsRow = document.createElement('tr'); const detailsCell = document.createElement('td'); detailsCell.colSpan = 7; detailsCell.className = 'document-details'; detailsRow.appendChild(detailsCell); detailsRow.hidden = true;
      const details = document.createElement('button'); details.className = 'secondary'; details.textContent = 'Ver documentos'; details.onclick = async () => { detailsRow.hidden = !detailsRow.hidden; if (!detailsRow.hidden) await loadPartnerDocuments(partner.id, detailsCell); };
      const approve = document.createElement('button'); approve.textContent = 'Aprovar perfil'; approve.onclick = async () => { try { await api(`/admin/partners/${partner.id}/status`, {method: 'PATCH', body: JSON.stringify({status: 'active'})}); await loadPartners(); message('Parceiro aprovado e publicado.'); } catch (error) { message(error.message, true); } };
      const suspend = document.createElement('button'); suspend.className = 'danger'; suspend.textContent = 'Suspender'; suspend.onclick = async () => { try { await api(`/admin/partners/${partner.id}/status`, {method: 'PATCH', body: JSON.stringify({status: 'suspended'})}); await loadPartners(); message('Parceiro suspenso.'); } catch (error) { message(error.message, true); } };
      actions.append(details, approve, suspend); row.appendChild(actions); body.append(row, detailsRow);
    });
    table.appendChild(body); wrap.appendChild(table);
  };
  const loadUsers = async () => { const users = await api('/admin/users'); renderUsers(users); };
  const loadPartners = async () => { const partners = await api('/admin/partners'); renderPartners(partners); };
  $('refresh-partners').onclick = async () => { try { await loadPartners(); message('Parceiros atualizados.'); } catch (error) { message(error.message, true); } };
  const openPanel = async (setupRequired = false) => { $('login').style.display = 'none'; $('app').style.display = 'block'; $('mfa-setup').style.display = setupRequired ? 'block' : 'none'; if (!setupRequired) { await loadUsers(); await loadPartners(); } message(setupRequired ? 'Ative o MFA para liberar os recursos administrativos.' : 'Painel carregado.'); };
  $('login-form').onsubmit = async (event) => { event.preventDefault(); try { const result = await api('/auth/login', {method: 'POST', body: JSON.stringify({email: $('login-email').value, password: $('login-password').value})}); if (result.mfaRequired) { mfaChallengeToken = result.challengeToken; $('login-form').style.display = 'none'; $('mfa-form').style.display = 'grid'; message('Informe o código do aplicativo autenticador.'); return; } token = result.accessToken; await openPanel(Boolean(result.mfaSetupRequired)); } catch (error) { message(error.message, true); } };
  $('mfa-form').onsubmit = async (event) => { event.preventDefault(); try { const result = await api('/auth/mfa/verify', {method: 'POST', body: JSON.stringify({challengeToken: mfaChallengeToken, code: $('mfa-code').value})}); token = result.accessToken; mfaChallengeToken = null; await openPanel(false); } catch (error) { message(error.message, true); } };
  $('mfa-start').onclick = async () => { try { const result = await api('/admin/mfa/setup', {method: 'POST'}); $('mfa-secret').textContent = `Chave manual: ${result.secret}\nURI: ${result.provisioningUri}`; $('mfa-activate-form').style.display = 'grid'; message('Chave gerada. Confirme um código para ativar.'); } catch (error) { message(error.message, true); } };
  $('mfa-activate-form').onsubmit = async (event) => { event.preventDefault(); try { const result = await api('/admin/mfa/activate', {method: 'POST', body: JSON.stringify({code: $('mfa-activate-code').value})}); $('mfa-setup').style.display = 'none'; $('mfa-secret').textContent = ''; await loadUsers(); await loadPartners(); message(`MFA ativado. Guarde estes códigos de recuperação em local seguro:\n${result.recoveryCodes.join('\n')}`); } catch (error) { message(error.message, true); } };
  $('create-form').onsubmit = async (event) => { event.preventDefault(); try { await api('/admin/users', {method: 'POST', body: JSON.stringify({email: $('new-email').value, password: $('new-password').value, isAdmin: $('new-admin').checked})}); event.target.reset(); await loadUsers(); message('Usuário criado.'); } catch (error) { message(error.message, true); } };
  $('logout').onclick = () => { token = null; mfaChallengeToken = null; $('app').style.display = 'none'; $('login').style.display = 'block'; $('login-form').style.display = 'grid'; $('mfa-form').style.display = 'none'; message('Sessão local encerrada.'); };
})();
</script>
</body>
</html>
"""
