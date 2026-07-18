import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const apiBaseUrl = 'https://aumiau.app.br';
const forest = Color(0xFF155E50);
const gold = Color(0xFFFFB31A);
const surface = Color(0xFFF6F8F6);

void main() {
  runApp(const PartnerApp());
}

class PartnerApp extends StatelessWidget {
  const PartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AuMiau Parceiro',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: surface,
        colorScheme: ColorScheme.fromSeed(seedColor: forest),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const PartnerGate(),
    );
  }
}

class PartnerGate extends StatefulWidget {
  const PartnerGate({super.key});

  @override
  State<PartnerGate> createState() => _PartnerGateState();
}

class _PartnerGateState extends State<PartnerGate> {
  String? token;

  @override
  Widget build(BuildContext context) {
    if (token == null) {
      return LoginPage(
        onAuthenticated: (value) => setState(() => token = value),
      );
    }
    return PartnerDashboard(
      token: token!,
      onLogout: () => setState(() => token = null),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({required this.onAuthenticated, super.key});

  final ValueChanged<String> onAuthenticated;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final businessName = TextEditingController();
  final responsibleName = TextEditingController();
  final cnpj = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final postalCode = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  bool registering = false;
  bool busy = false;
  String? message;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    businessName.dispose();
    responsibleName.dispose();
    cnpj.dispose();
    phone.dispose();
    address.dispose();
    postalCode.dispose();
    city.dispose();
    state.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.length < 8) {
      setState(
        () => message = 'Informe e-mail e senha com pelo menos 8 caracteres.',
      );
      return;
    }
    if (registering &&
        (businessName.text.trim().length < 2 ||
            responsibleName.text.trim().length < 2 ||
            cnpj.text.replaceAll(RegExp(r'[^0-9]'), '').length != 14 ||
            phone.text.trim().length < 8 ||
            address.text.trim().isEmpty ||
            postalCode.text.trim().isEmpty ||
            city.text.trim().isEmpty ||
            state.text.trim().isEmpty)) {
      setState(
        () =>
            message = 'Complete os dados do estabelecimento e do responsável.',
      );
      return;
    }
    setState(() {
      busy = true;
      message = null;
    });
    try {
      final response = await http.post(
        Uri.parse(
          '$apiBaseUrl/${registering ? 'partner/auth/register' : 'auth/login'}',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          registering
              ? {
                  'businessName': businessName.text.trim(),
                  'partnerType': 'clinic',
                  'cnpj': cnpj.text.trim(),
                  'responsibleName': responsibleName.text.trim(),
                  'email': email.text.trim(),
                  'password': password.text,
                  'phone': phone.text.trim(),
                  'address': address.text.trim(),
                  'postalCode': postalCode.text.trim(),
                  'city': city.text.trim(),
                  'state': state.text.trim(),
                  'termsAccepted': true,
                }
              : {'email': email.text.trim(), 'password': password.text},
        ),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 400) {
        throw Exception(
          data['detail'] ?? 'Não foi possível concluir a operação.',
        );
      }
      final accessToken = data['accessToken'] as String?;
      if (accessToken == null) {
        setState(() {
          registering = false;
          message =
              data['message'] as String? ??
              'Cadastro criado. Confirme o e-mail para entrar.';
        });
      } else {
        widget.onAuthenticated(accessToken);
      }
    } catch (error) {
      setState(
        () => message = error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<bool>(
      canPop: !registering,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && registering && !busy) {
          setState(() {
            registering = false;
            message = null;
          });
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          label: 'AuMiau, gatinha e cachorrinho animados',
                          image: true,
                          child: Image.asset(
                            'assets/branding/aumiau_canva_animation.gif',
                            width: 330,
                            height: 165,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AuMiau Parceiro',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: forest,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          registering
                              ? 'Cadastre sua clínica ou consultório'
                              : 'Acesse sua área profissional',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        if (registering) ...[
                          TextField(
                            controller: businessName,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Nome da clínica ou profissional *',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: responsibleName,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Nome do responsável *',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: cnpj,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'CNPJ *',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: phone,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Telefone ou WhatsApp *',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: address,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Endereço completo *',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: postalCode,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'CEP *',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: city,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Cidade *',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: state,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Estado/UF *',
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-mail *',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: password,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Senha *',
                          ),
                        ),
                        if (message != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            message!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ],
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: busy ? null : submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: forest,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: busy
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  registering
                                      ? 'Criar cadastro profissional'
                                      : 'Entrar',
                                ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: busy
                              ? null
                              : () => setState(() {
                                  registering = !registering;
                                  message = null;
                                }),
                          child: Text(
                            registering
                                ? 'Já tenho cadastro'
                                : 'Criar cadastro de parceiro',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PartnerDashboard extends StatefulWidget {
  const PartnerDashboard({
    required this.token,
    required this.onLogout,
    super.key,
  });

  final String token;
  final VoidCallback onLogout;

  @override
  State<PartnerDashboard> createState() => _PartnerDashboardState();
}

class _PartnerDashboardState extends State<PartnerDashboard> {
  Map<String, dynamic>? profile;
  Map<String, dynamic>? dashboard;
  String? error;
  bool loading = true;
  Timer? poller;

  Map<String, String> get headers => {
    'Authorization': 'Bearer ${widget.token}',
    'Content-Type': 'application/json',
  };

  @override
  void initState() {
    super.initState();
    load();
    poller = Timer.periodic(
      const Duration(seconds: 12),
      (_) => load(silent: true),
    );
  }

  @override
  void dispose() {
    poller?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$apiBaseUrl$path');
    final response = method == 'POST'
        ? await http.post(uri, headers: headers, body: jsonEncode(body ?? {}))
        : await http.get(uri, headers: headers);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw Exception(data['detail'] ?? 'Falha de comunicação com o servidor.');
    }
    return data;
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) setState(() => loading = true);
    try {
      final loadedProfile = await request('/partner/profile');
      Map<String, dynamic>? loadedDashboard;
      if ((loadedProfile['subscription'] as Map<String, dynamic>)['status'] ==
          'active') {
        loadedDashboard = await request('/partner/dashboard');
      }
      if (mounted) {
        setState(() {
          profile = loadedProfile;
          dashboard = loadedDashboard;
          error = null;
          loading = false;
        });
      }
    } catch (exception) {
      if (mounted) {
        setState(() {
          error = exception.toString().replaceFirst('Exception: ', '');
          loading = false;
        });
      }
    }
  }

  Future<void> openPlans() async {
    final products = [
      {'id': 'partner_monthly', 'title': 'Mensal', 'price': 'R\$ 2,99'},
      {'id': 'partner_yearly', 'title': 'Anual', 'price': 'R\$ 25,00'},
    ];
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ative seu perfil profissional',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Após a confirmação do Mercado Pago, seu estabelecimento ficará disponível para clientes AuMiau.',
              ),
              const SizedBox(height: 16),
              for (final product in products)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      createOrder(product['id']!);
                    },
                    child: Text('${product['title']}  •  ${product['price']}'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createOrder(String productId) async {
    try {
      final order = await request(
        '/billing/orders',
        method: 'POST',
        body: {'productId': productId},
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pagamento via Pix'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Escaneie o QR Code de R\$ ${(order['amountBrl'] as num).toStringAsFixed(2).replaceAll('.', ',')}',
                ),
                const SizedBox(height: 16),
                if ((order['qrCode'] as String?)?.isNotEmpty == true)
                  QrImageView(data: order['qrCode'] as String, size: 230),
                const SizedBox(height: 8),
                const Text(
                  'A confirmação é automática. Esta janela será atualizada quando o Mercado Pago confirmar o pagamento.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
      await load();
    } catch (exception) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exception.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }

  Future<void> openDeveloperWhatsApp(String phone) async {
    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent('Olá! Vim pelo AuMiau Parceiro e gostaria de falar com a C.A. Informática.')}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> openDeveloperInfo() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desenvolvedor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/branding/ca_informatica_logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                semanticLabel: 'Logo da C.A. Informática',
              ),
              const SizedBox(height: 12),
              const Text(
                'C.A. Informática',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text('CNPJ: 04.368.187/0001-31'),
              const SizedBox(height: 8),
              const Text(
                'Av. Auton Furtado, 233 - Cidade Nova\n'
                '69.415-000 - Iranduba - AM - Brasil',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => launchUrl(
                  Uri.parse('https://www.cainformatica.com.br'),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text(
                  'www.cainformatica.com.br',
                  style: TextStyle(
                    color: forest,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => openDeveloperWhatsApp('5592991580637'),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('WhatsApp +55 92 99158-0637'),
              ),
              TextButton.icon(
                onPressed: () => openDeveloperWhatsApp('5592986092837'),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('WhatsApp +55 92 98609-2837'),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = profile;
    final subscription = data?['subscription'] as Map<String, dynamic>?;
    final profileData = data?['profile'] as Map<String, dynamic>?;
    final active = subscription?['status'] == 'active';
    return Scaffold(
      appBar: AppBar(
        title: const Text('AuMiau Parceiro'),
        actions: [
          IconButton(
            onPressed: openDeveloperInfo,
            tooltip: 'Desenvolvedor',
            icon: const Icon(Icons.business_outlined),
          ),
          IconButton(
            onPressed: widget.onLogout,
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: loading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (error != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ),
                  Card(
                    color: forest,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profileData?['name'] as String? ??
                                'Seu estabelecimento',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            active ? 'PERFIL PUBLICADO' : 'CADASTRO PENDENTE',
                            style: const TextStyle(
                              color: gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (subscription?['validUntil'] != null)
                            Text(
                              'Válido até ${subscription!['validUntil']}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.business_outlined,
                        color: forest,
                      ),
                      title: const Text('Desenvolvedor'),
                      subtitle: const Text('C.A. Informática • AuMiau'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: openDeveloperInfo,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!active)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Seu perfil ainda não aparece para os clientes.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Contrate a assinatura para publicar localização, serviços, WhatsApp e atendimento de urgência.',
                            ),
                            const SizedBox(height: 14),
                            FilledButton(
                              onPressed: openPlans,
                              child: const Text('Conhecer assinatura'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    Row(
                      children: [
                        _Counter(
                          label: 'Solicitados',
                          value:
                              '${(dashboard?['counters'] as Map<String, dynamic>?)?['requested'] ?? 0}',
                        ),
                        _Counter(
                          label: 'Confirmados',
                          value:
                              '${(dashboard?['counters'] as Map<String, dynamic>?)?['confirmed'] ?? 0}',
                        ),
                        _Counter(
                          label: 'Hoje',
                          value:
                              '${(dashboard?['counters'] as Map<String, dynamic>?)?['today'] ?? 0}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Próximos atendimentos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...((dashboard?['appointments'] as List<dynamic>?) ?? []).map(
                      (item) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.event, color: forest),
                          title: Text(
                            '${item['petName']} • ${item['service']}',
                          ),
                          subtitle: Text(
                            '${item['scheduledAt']}\nStatus: ${item['status']}',
                          ),
                        ),
                      ),
                    ),
                    if (((dashboard?['appointments'] as List<dynamic>?) ?? [])
                        .isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Text('Nenhum atendimento registrado ainda.'),
                        ),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: forest,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}
