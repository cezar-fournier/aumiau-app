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
  </section>
  <section id="app">
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
      <p><button id="logout" class="secondary">Sair</button></p>
    </div>
  </section>
  <p id="message"></p>
</main>
<script>
(() => {
  let token = null;
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
  const loadUsers = async () => { const users = await api('/admin/users'); renderUsers(users); };
  $('login-form').onsubmit = async (event) => { event.preventDefault(); try { const result = await api('/auth/login', {method: 'POST', body: JSON.stringify({email: $('login-email').value, password: $('login-password').value})}); token = result.accessToken; await loadUsers(); $('login').style.display = 'none'; $('app').style.display = 'block'; message('Painel carregado.'); } catch (error) { message(error.message, true); } };
  $('create-form').onsubmit = async (event) => { event.preventDefault(); try { await api('/admin/users', {method: 'POST', body: JSON.stringify({email: $('new-email').value, password: $('new-password').value, isAdmin: $('new-admin').checked})}); event.target.reset(); await loadUsers(); message('Usuário criado.'); } catch (error) { message(error.message, true); } };
  $('logout').onclick = () => { token = null; $('app').style.display = 'none'; $('login').style.display = 'block'; message('Sessão local encerrada.'); };
})();
</script>
</body>
</html>
"""
