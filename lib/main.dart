import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config/app_config.dart';
import 'data/app_database.dart';
import 'domain/product_plan.dart';
import 'services/backup_service.dart';
import 'services/notification_service.dart';
import 'services/pdf_service.dart';
import 'services/session_store.dart';
import 'services/sync_gateway.dart';
import 'services/sync_service.dart';
import 'services/update_service.dart';

const _forest = Color(0xFF1E4D40);
const _forestDark = Color(0xFF143830);
const _mango = Color(0xFFFFB627);
const _paper = Color(0xFFFBF9F4);
const _ink = Color(0xFF26332E);
const _muted = Color(0xFF6B7A73);
const _line = Color(0xFFE7E3D8);
const _danger = Color(0xFFD9534F);
const _success = Color(0xFF3F8E5F);
const _authPink = _forest;
const _authPinkDark = _forestDark;
const _authBlush = _paper;

enum _AuthScreen { welcome, login, register, verifyEmail }

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AumiauApp());
  unawaited(NotificationService.instance.initialize());
}

class AumiauApp extends StatelessWidget {
  const AumiauApp({super.key, this.database, this.enableUpdateChecks = true});

  final AppDatabase? database;
  final bool enableUpdateChecks;

  @override
  Widget build(BuildContext context) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _forest,
          brightness: Brightness.light,
        ).copyWith(
          primary: _forest,
          onPrimary: Colors.white,
          secondary: _mango,
          surface: _paper,
        );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AuMiau',
      theme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: _paper,
        useMaterial3: true,
        fontFamily: 'sans',
        appBarTheme: const AppBarTheme(
          backgroundColor: _forest,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _forest, width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: _line),
          ),
        ),
      ),
      home: PersistentHomeShell(
        database: database,
        enableUpdateChecks: enableUpdateChecks,
      ),
    );
  }
}

class Pet {
  Pet({
    this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.emoji,
    required this.weight,
    this.allergies = '',
    this.vaccines = const [],
    this.weights = const [],
  });

  final int? id;
  String name;
  final String species;
  final String breed;
  final String emoji;
  double weight;
  String allergies;
  final List<VaccineRecord> vaccines;
  final List<WeightRecord> weights;
}

class VaccineRecord {
  VaccineRecord({
    this.id,
    required this.petId,
    required this.name,
    required this.appliedAt,
    this.nextDoseAt,
    this.clinicName,
  });

  final int? id;
  final int petId;
  final String name;
  final DateTime appliedAt;
  final DateTime? nextDoseAt;
  final String? clinicName;
}

class WeightRecord {
  WeightRecord({
    this.id,
    required this.petId,
    required this.weight,
    required this.measuredAt,
    this.note,
  });

  final int? id;
  final int petId;
  final double weight;
  final DateTime measuredAt;
  final String? note;
}

class TimelineEntry {
  TimelineEntry({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final DateTime date;
  final IconData icon;
}

class LocalProfile {
  LocalProfile({
    required this.name,
    required this.email,
    this.plan = 'free_offline',
    this.familyEnabled = false,
  });

  String name;
  String email;
  String plan;
  bool familyEnabled;

  factory LocalProfile.defaultProfile() => LocalProfile(name: '', email: '');

  ProductPlan get productPlan {
    final planDefinition = ProductCatalog.fromCode(plan);
    if (planDefinition.isFamily && !familyEnabled) {
      return ProductCatalog.freeOffline;
    }
    return planDefinition;
  }

  bool get isFamily => productPlan.isFamily;
  bool get isFreeOffline => productPlan.isFreeOffline;
}

class Reminder {
  Reminder({
    this.id,
    required this.title,
    required this.petName,
    required this.icon,
    required this.dueDate,
    required this.intervalDays,
    this.category = 'Rotina',
    this.done = false,
  });

  final int? id;
  String title;
  String petName;
  final String icon;
  DateTime dueDate;
  final int intervalDays;
  final String category;
  bool done;
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;
  late final DateTime _today;
  late final List<Pet> _pets;
  late final List<Reminder> _reminders;
  final List<String> _history = [
    'V10 registrada para Thor',
    'Peso de Mel atualizado: 3,9 kg',
    'Consulta de rotina concluída',
  ];

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _pets = [
      Pet(
        name: 'Thor',
        species: 'Cão',
        breed: 'Vira-lata',
        emoji: '🐶',
        weight: 18.2,
        allergies: 'Alergia a picada de pulga',
      ),
      Pet(name: 'Mel', species: 'Gata', breed: 'SRD', emoji: '🐱', weight: 3.9),
    ];
    _reminders = [
      Reminder(
        title: 'Vermífugo do Thor',
        petName: 'Thor',
        icon: '💊',
        dueDate: _today,
        intervalDays: 90,
      ),
      Reminder(
        title: 'Antipulgas do Thor',
        petName: 'Thor',
        icon: '🪲',
        dueDate: _today,
        intervalDays: 30,
      ),
      Reminder(
        title: 'Vermífugo da Mel',
        petName: 'Mel',
        icon: '💊',
        dueDate: _today.add(const Duration(days: 3)),
        intervalDays: 90,
      ),
      Reminder(
        title: 'Banho do Thor',
        petName: 'Thor',
        icon: '🛁',
        dueDate: _today.add(const Duration(days: 5)),
        intervalDays: 15,
      ),
    ];
  }

  void _completeReminder(Reminder reminder) {
    setState(() {
      reminder.dueDate = reminder.dueDate.add(
        Duration(days: reminder.intervalDays),
      );
      reminder.done = true;
      _history.insert(0, '${reminder.title} concluído');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Feito! Próxima ocorrência em ${_formatDate(reminder.dueDate)}.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _forestDark,
      ),
    );
  }

  void _openAddReminder() {
    final titleController = TextEditingController();
    var petName = _pets.first.name;
    var type = 'Rotina';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              Text(
                'Novo lembrete',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Organize o próximo cuidado do seu pet.',
                style: TextStyle(color: _muted),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'O que precisa ser feito?',
                  hintText: 'Ex.: Dar medicamento',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: petName,
                      decoration: const InputDecoration(labelText: 'Pet'),
                      items: _pets
                          .map(
                            (pet) => DropdownMenuItem(
                              value: pet.name,
                              child: Text('${pet.emoji} ${pet.name}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setModalState(() => petName = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: ['Rotina', 'Medicamento', 'Vacina', 'Banho']
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setModalState(() => type = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _forest,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    setState(
                      () => _reminders.add(
                        Reminder(
                          title: title,
                          petName: petName,
                          icon: type == 'Banho'
                              ? '🛁'
                              : type == 'Vacina'
                              ? '💉'
                              : '💊',
                          dueDate: _today,
                          intervalDays: 30,
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar lembrete'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddPet() {
    final nameController = TextEditingController();
    var species = 'Cão';
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar pet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nome do pet'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: species,
              decoration: const InputDecoration(labelText: 'Espécie'),
              items: const [
                DropdownMenuItem(value: 'Cão', child: Text('🐶 Cão')),
                DropdownMenuItem(value: 'Gata', child: Text('🐱 Gato')),
              ],
              onChanged: (value) => species = value!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              setState(
                () => _pets.add(
                  Pet(
                    name: nameController.text.trim(),
                    species: species,
                    breed: 'A informar',
                    emoji: species == 'Cão' ? '🐶' : '🐱',
                    weight: 0,
                  ),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayPage(
        today: _today,
        profileName: 'Cezar Fournier',
        pets: _pets,
        reminders: _reminders,
        onComplete: _completeReminder,
        onAddReminder: _openAddReminder,
        onEditReminder: (_) {},
        onDeleteReminder: (_) {},
      ),
      PetsPage(pets: _pets, onAddPet: _openAddPet),
      HistoryPage(history: _history, pets: _pets),
      const ProfilePage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: pages[_selectedIndex],
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openAddReminder,
              backgroundColor: _mango,
              foregroundColor: _forestDark,
              icon: const Icon(Icons.add),
              label: const Text('Lembrete'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: _mango.withValues(alpha: .24),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hoje',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Pets',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class PersistentHomeShell extends StatefulWidget {
  const PersistentHomeShell({
    super.key,
    this.database,
    this.enableUpdateChecks = true,
  });

  final AppDatabase? database;
  final bool enableUpdateChecks;

  @override
  State<PersistentHomeShell> createState() => _PersistentHomeShellState();
}

class _PersistentHomeShellState extends State<PersistentHomeShell> {
  int _selectedIndex = 0;
  late final AppDatabase _database;
  late final DateTime _today;
  List<Pet> _pets = [];
  List<Reminder> _reminders = [];
  List<TimelineEntry> _timeline = [];
  LocalProfile _profile = LocalProfile.defaultProfile();
  int _pendingSyncCount = 0;
  late final HttpSyncGateway _syncGateway;
  late final SessionStore _sessionStore;
  String? _accessToken;
  bool _syncing = false;
  bool _loading = true;
  String? _loadError;
  bool _updateNoticeShown = false;
  bool _showAuthGate = true;
  _AuthScreen _authScreen = _AuthScreen.welcome;
  bool _authBusy = false;
  String? _pendingVerificationEmail;
  String? _pendingRegistrationName;

  @override
  void initState() {
    super.initState();
    _database = widget.database ?? AppDatabase();
    _syncGateway = HttpSyncGateway(baseUri: AppConfig.apiBaseUri);
    _sessionStore = SessionStore();
    _today = DateTime.now();
    _restoreSession();
    _loadData();
    if (widget.enableUpdateChecks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdates());
    }
  }

  @override
  void dispose() {
    if (widget.database == null) unawaited(_database.close());
    super.dispose();
  }

  Future<void> _checkForUpdates() async {
    if (_updateNoticeShown) return;
    final update = await UpdateService().checkForUpdate();
    if (!mounted || update == null) return;
    _updateNoticeShown = true;
    await NotificationService.instance.showUpdateAvailable(
      version: update.version,
      downloadUrl: update.downloadUrl,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Nova versão ${update.version} disponível nas Releases do GitHub.',
        ),
        duration: const Duration(seconds: 8),
      ),
    );
  }

  Future<void> _loadData() async {
    try {
      final databasePets = await _database.loadPets();
      final databaseVaccines = await _database.loadVaccines();
      final databaseWeights = await _database.loadWeights();
      final databaseReminders = await _database.loadReminders();
      final databaseProfile = await _database.loadProfile();
      final pendingSyncOperations = await _database.loadPendingSyncOperations();
      final vaccinesByPet = <int, List<VaccineRecord>>{};
      final weightsByPet = <int, List<WeightRecord>>{};

      for (final vaccine in databaseVaccines) {
        vaccinesByPet
            .putIfAbsent(vaccine.petId, () => [])
            .add(
              VaccineRecord(
                id: vaccine.id,
                petId: vaccine.petId,
                name: vaccine.name,
                appliedAt: vaccine.appliedAt,
                nextDoseAt: vaccine.nextDoseAt,
                clinicName: vaccine.clinicName,
              ),
            );
      }

      for (final weight in databaseWeights) {
        weightsByPet
            .putIfAbsent(weight.petId, () => [])
            .add(
              WeightRecord(
                id: weight.id,
                petId: weight.petId,
                weight: weight.weight,
                measuredAt: weight.measuredAt,
                note: weight.note,
              ),
            );
      }

      final petNameById = {for (final pet in databasePets) pet.id: pet.name};
      final timeline = <TimelineEntry>[];
      for (final vaccine in databaseVaccines) {
        timeline.add(
          TimelineEntry(
            title:
                '${vaccine.name} registrada para ${petNameById[vaccine.petId] ?? 'pet'}',
            subtitle: 'Vacinação',
            date: vaccine.appliedAt,
            icon: Icons.vaccines_outlined,
          ),
        );
      }
      for (final weight in databaseWeights) {
        timeline.add(
          TimelineEntry(
            title: 'Peso registrado: ${weight.weight.toStringAsFixed(1)} kg',
            subtitle: petNameById[weight.petId] ?? 'Pet',
            date: weight.measuredAt,
            icon: Icons.monitor_weight_outlined,
          ),
        );
      }
      for (final reminder in databaseReminders) {
        final completedAt = reminder.lastCompletedAt;
        if (completedAt != null) {
          timeline.add(
            TimelineEntry(
              title: '${reminder.title} concluído',
              subtitle: reminder.petName,
              date: completedAt,
              icon: Icons.check_circle_outline,
            ),
          );
        }
      }
      timeline.sort((a, b) => b.date.compareTo(a.date));

      if (!mounted) return;
      setState(() {
        _profile = databaseProfile == null
            ? LocalProfile.defaultProfile()
            : LocalProfile(
                name: databaseProfile.name,
                email: databaseProfile.email,
                plan: databaseProfile.plan,
              );
        _pendingSyncCount = pendingSyncOperations.length;
        _pets = databasePets
            .map(
              (pet) => Pet(
                id: pet.id,
                name: pet.name,
                species: pet.species,
                breed: pet.breed,
                emoji: pet.emoji,
                weight: pet.weight,
                allergies: pet.allergies,
                vaccines: vaccinesByPet[pet.id] ?? [],
                weights: weightsByPet[pet.id] ?? [],
              ),
            )
            .toList();
        _timeline = timeline;
        _reminders = databaseReminders
            .map(
              (reminder) => Reminder(
                id: reminder.id,
                title: reminder.title,
                petName: reminder.petName,
                icon: reminder.icon,
                dueDate: reminder.dueAt,
                intervalDays: reminder.intervalDays,
                category: reminder.category,
              ),
            )
            .toList();
        _loading = false;
        _loadError = null;
      });

      for (final reminder in _reminders) {
        final id = reminder.id;
        if (id != null) {
          try {
            await NotificationService.instance.scheduleReminder(
              id: id,
              title: reminder.title,
              petName: reminder.petName,
              dueDate: reminder.dueDate,
            );
          } catch (_) {
            // Uma notificação indisponível não impede o uso offline.
          }
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'Não foi possível carregar seus dados locais.';
      });
    }
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    final confirmed = await _confirmAction(
      title: 'Excluir lembrete?',
      message:
          '“${reminder.title}” será removido da rotina e das notificações.',
    );
    if (!confirmed || reminder.id == null) return;
    await _database.deleteReminder(reminder.id!);
    await NotificationService.instance.cancelReminder(reminder.id!);
    if (!mounted) return;
    setState(() => _reminders.removeWhere((item) => item.id == reminder.id));
  }

  Future<void> _editReminder(Reminder reminder) async {
    final controller = TextEditingController(text: reminder.title);
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar lembrete'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Título'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (title == null || title.isEmpty || reminder.id == null) return;
    await _database.updateReminderTitle(reminder.id!, title);
    if (!mounted) return;
    setState(() => reminder.title = title);
    await NotificationService.instance.scheduleReminder(
      id: reminder.id!,
      title: reminder.title,
      petName: reminder.petName,
      dueDate: reminder.dueDate,
    );
  }

  Future<void> _deletePet(Pet pet) async {
    final confirmed = await _confirmAction(
      title: 'Excluir ${pet.name}?',
      message: 'As vacinas e lembretes vinculados também serão removidos.',
    );
    if (!confirmed || pet.id == null) return;
    await _database.deletePet(pet.id!);
    if (!mounted) return;
    setState(() {
      _pets.removeWhere((item) => item.id == pet.id);
      _reminders.removeWhere((item) => item.petName == pet.name);
    });
  }

  Future<void> _deleteVaccine(
    Pet pet,
    VaccineRecord vaccine,
    VoidCallback refresh,
  ) async {
    final confirmed = await _confirmAction(
      title: 'Excluir vacina?',
      message: 'O registro “${vaccine.name}” será removido da carteira.',
    );
    if (!confirmed || vaccine.id == null) return;
    await _database.deleteVaccine(vaccine.id!);
    pet.vaccines.removeWhere((item) => item.id == vaccine.id);
    if (!mounted) return;
    setState(
      () => _timeline.insert(
        0,
        TimelineEntry(
          title: '${vaccine.name} removida de ${pet.name}',
          subtitle: 'Carteira de vacinação',
          date: DateTime.now(),
          icon: Icons.delete_outline,
        ),
      ),
    );
    _timeline.sort((a, b) => b.date.compareTo(a.date));
    refresh();
  }

  Future<void> _editPet(Pet pet) async {
    final controller = TextEditingController(text: pet.name);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Editar ${pet.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome do pet'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || name == pet.name || pet.id == null) {
      return;
    }
    final oldName = pet.name;
    await _database.updatePetName(pet.id!, name);
    await _database.updateReminderPetName(pet.id!, name);
    if (!mounted) return;
    setState(() {
      pet.name = name;
      for (final reminder in _reminders.where(
        (item) => item.petName == oldName,
      )) {
        reminder.petName = name;
      }
    });
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _openAddWeight() async {
    if (_pets.isEmpty) return;
    final weightController = TextEditingController();
    final noteController = TextEditingController();
    var selectedPet = _pets.first;
    var measuredAt = _today;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Registrar peso'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Pet>(
                  initialValue: selectedPet,
                  decoration: const InputDecoration(labelText: 'Pet'),
                  items: _pets
                      .map(
                        (pet) => DropdownMenuItem(
                          value: pet,
                          child: Text('${pet.emoji} ${pet.name}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setDialogState(() => selectedPet = value!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Peso em quilogramas',
                    hintText: 'Ex.: 18,4',
                    suffixText: 'kg',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: 'Observação (opcional)',
                    hintText: 'Ex.: Consulta veterinária',
                  ),
                ),
                const SizedBox(height: 12),
                _DatePickerTile(
                  label: 'Medido em',
                  value: _formatDate(measuredAt),
                  onTap: () async {
                    final value = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: measuredAt,
                    );
                    if (value != null) {
                      setDialogState(() => measuredAt = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final weight = double.tryParse(
                  weightController.text.trim().replaceAll(',', '.'),
                );
                if (weight == null || weight <= 0 || selectedPet.id == null) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Informe um peso válido.')),
                  );
                  return;
                }
                final note = noteController.text.trim();
                final id = await _database.addWeight(
                  petId: selectedPet.id!,
                  weight: weight,
                  measuredAt: measuredAt,
                  note: note.isEmpty ? null : note,
                );
                selectedPet.weight = weight;
                selectedPet.weights.insert(
                  0,
                  WeightRecord(
                    id: id,
                    petId: selectedPet.id!,
                    weight: weight,
                    measuredAt: measuredAt,
                    note: note.isEmpty ? null : note,
                  ),
                );
                _timeline.insert(
                  0,
                  TimelineEntry(
                    title: 'Peso registrado: ${weight.toStringAsFixed(1)} kg',
                    subtitle: selectedPet.name,
                    date: measuredAt,
                    icon: Icons.monitor_weight_outlined,
                  ),
                );
                _timeline.sort((a, b) => b.date.compareTo(a.date));
                if (mounted) setState(() {});
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Salvar peso'),
            ),
          ],
        ),
      ),
    );
    weightController.dispose();
    noteController.dispose();
  }

  Future<void> _completePersistentReminder(Reminder reminder) async {
    final nextDate = reminder.dueDate.add(
      Duration(days: reminder.intervalDays),
    );
    if (reminder.id != null) {
      await _database.completeReminder(reminder.id!, nextDate);
    }
    if (!mounted) return;
    setState(() {
      reminder.dueDate = nextDate;
      reminder.done = true;
      _timeline.insert(
        0,
        TimelineEntry(
          title: '${reminder.title} concluído',
          subtitle: reminder.petName,
          date: DateTime.now(),
          icon: Icons.check_circle_outline,
        ),
      );
      _timeline.sort((a, b) => b.date.compareTo(a.date));
    });
    if (reminder.id != null) {
      await NotificationService.instance.scheduleReminder(
        id: reminder.id!,
        title: reminder.title,
        petName: reminder.petName,
        dueDate: reminder.dueDate,
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Feito! Próxima ocorrência em ${_formatDate(reminder.dueDate)}.',
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _forestDark,
      ),
    );
  }

  Future<void> _openAddReminder() async {
    if (_pets.isEmpty) {
      _showProductMessage('Cadastre um pet antes de criar uma rotina.');
      return;
    }
    if (!_profile.productPlan.canAddReminder(_reminders.length)) {
      _showUpgradePrompt(
        title: 'Limite do AuMiau Free Offline',
        message:
            'O Free Offline permite uma rotina. Crie uma conta para usar o AuMiau Family com múltiplos cuidados e sincronização.',
      );
      return;
    }
    final titleController = TextEditingController();
    var selectedPet = _pets.first;
    var category = 'Rotina';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              Text(
                'Novo lembrete',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Organize o próximo cuidado do seu pet.',
                style: TextStyle(color: _muted),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'O que precisa ser feito?',
                  hintText: 'Ex.: Dar medicamento',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Pet>(
                      initialValue: selectedPet,
                      decoration: const InputDecoration(labelText: 'Pet'),
                      items: _pets
                          .map(
                            (pet) => DropdownMenuItem(
                              value: pet,
                              child: Text('${pet.emoji} ${pet.name}'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setModalState(() => selectedPet = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: ['Rotina', 'Medicamento', 'Vacina', 'Banho']
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setModalState(() => category = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _forest,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty || selectedPet.id == null) return;
                    final icon = category == 'Banho'
                        ? '🛁'
                        : category == 'Vacina'
                        ? '💉'
                        : '💊';
                    final id = await _database.addReminder(
                      title: title,
                      petId: selectedPet.id!,
                      petName: selectedPet.name,
                      icon: icon,
                      category: category,
                      dueAt: _today,
                    );
                    if (!mounted) return;
                    setState(
                      () => _reminders.add(
                        Reminder(
                          id: id,
                          title: title,
                          petName: selectedPet.name,
                          icon: icon,
                          dueDate: _today,
                          intervalDays: 30,
                          category: category,
                        ),
                      ),
                    );
                    await NotificationService.instance.scheduleReminder(
                      id: id,
                      title: title,
                      petName: selectedPet.name,
                      dueDate: _today,
                    );
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar lembrete'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    titleController.dispose();
  }

  Future<void> _openAddPet() async {
    if (!_profile.productPlan.canAddPet(_pets.length)) {
      _showUpgradePrompt(
        title: 'Mais pets no AuMiau Family',
        message:
            'O AuMiau Free Offline permite cadastrar um pet. Crie uma conta para continuar cuidando de toda a família.',
      );
      return;
    }
    final nameController = TextEditingController();
    var species = 'Cão';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Adicionar pet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nome do pet'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: species,
                decoration: const InputDecoration(labelText: 'Espécie'),
                items: const [
                  DropdownMenuItem(value: 'Cão', child: Text('🐶 Cão')),
                  DropdownMenuItem(value: 'Gata', child: Text('🐱 Gato')),
                ],
                onChanged: (value) => setDialogState(() => species = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final id = await _database.addPet(
                  name: name,
                  species: species,
                  breed: 'A informar',
                  emoji: species == 'Cão' ? '🐶' : '🐱',
                );
                if (!mounted) return;
                setState(
                  () => _pets.add(
                    Pet(
                      id: id,
                      name: name,
                      species: species,
                      breed: 'A informar',
                      emoji: species == 'Cão' ? '🐶' : '🐱',
                      weight: 0,
                    ),
                  ),
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
  }

  void _showProductMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showUpgradePrompt({required String title, required String message}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _openAuth(_AuthScreen.register);
            },
            child: const Text('Criar conta'),
          ),
        ],
      ),
    );
  }

  Future<void> _openVaccineWallet(Pet pet) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          final records = [...pet.vaccines]
            ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SheetHandle(),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Carteira de ${pet.name}',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: _ink,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Vacinas aplicadas e próximas doses.',
                              style: TextStyle(color: _muted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Adicionar vacina',
                        onPressed: () =>
                            _openAddVaccine(pet, () => setModalState(() {})),
                        icon: const Icon(Icons.add_circle, color: _forest),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (records.isEmpty)
                    const _EmptyState(
                      icon: Icons.vaccines_outlined,
                      title: 'Nenhuma vacina registrada',
                      subtitle:
                          'Adicione a primeira dose para começar a carteira.',
                    ),
                  ...records.map(
                    (record) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _VaccineCard(
                        record: record,
                        today: _today,
                        onDelete: () => _deleteVaccine(
                          pet,
                          record,
                          () => setModalState(() {}),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          _openAddVaccine(pet, () => setModalState(() {})),
                      style: FilledButton.styleFrom(
                        backgroundColor: _forest,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Registrar vacina'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openAddVaccine(Pet pet, VoidCallback onSaved) async {
    final nameController = TextEditingController();
    final clinicController = TextEditingController();
    var appliedAt = _today;
    DateTime? nextDoseAt = _today.add(const Duration(days: 365));

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Nova vacina · ${pet.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nome da vacina',
                    hintText: 'Ex.: Antirrábica',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: clinicController,
                  decoration: const InputDecoration(
                    labelText: 'Clínica ou veterinário (opcional)',
                  ),
                ),
                const SizedBox(height: 12),
                _DatePickerTile(
                  label: 'Aplicada em',
                  value: _formatDate(appliedAt),
                  onTap: () async {
                    final value = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: appliedAt,
                    );
                    if (value != null) {
                      setDialogState(() => appliedAt = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                _DatePickerTile(
                  label: 'Próxima dose',
                  value: nextDoseAt == null
                      ? 'Não informada'
                      : _formatDate(nextDoseAt!),
                  onTap: () async {
                    final value = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: nextDoseAt ?? _today,
                    );
                    if (value != null) {
                      setDialogState(() => nextDoseAt = value);
                    }
                  },
                  onClear: nextDoseAt == null
                      ? null
                      : () => setDialogState(() => nextDoseAt = null),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty || pet.id == null) return;
                final clinic = clinicController.text.trim();
                final id = await _database.addVaccine(
                  petId: pet.id!,
                  name: name,
                  appliedAt: appliedAt,
                  nextDoseAt: nextDoseAt,
                  clinicName: clinic.isEmpty ? null : clinic,
                );
                pet.vaccines.insert(
                  0,
                  VaccineRecord(
                    id: id,
                    petId: pet.id!,
                    name: name,
                    appliedAt: appliedAt,
                    nextDoseAt: nextDoseAt,
                    clinicName: clinic.isEmpty ? null : clinic,
                  ),
                );
                _timeline.insert(
                  0,
                  TimelineEntry(
                    title: '$name registrada para ${pet.name}',
                    subtitle: 'Carteira de vacinação',
                    date: appliedAt,
                    icon: Icons.vaccines_outlined,
                  ),
                );
                _timeline.sort((a, b) => b.date.compareTo(a.date));
                if (mounted) setState(() {});
                onSaved();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Salvar vacina'),
            ),
          ],
        ),
      ),
    );
    nameController.dispose();
    clinicController.dispose();
  }

  Future<void> _exportHistoryPdf() async {
    try {
      await PdfService.exportHealthHistory(
        pets: _pets
            .map(
              (pet) => PdfPetData(
                name: pet.name,
                species: pet.species,
                breed: pet.breed,
                weight: pet.weight,
                vaccines: pet.vaccines
                    .map(
                      (vaccine) => PdfVaccineData(
                        name: vaccine.name,
                        appliedAt: _formatDate(vaccine.appliedAt),
                        nextDoseAt: vaccine.nextDoseAt == null
                            ? 'Não informada'
                            : _formatDate(vaccine.nextDoseAt!),
                        clinicName: vaccine.clinicName?.isNotEmpty == true
                            ? vaccine.clinicName!
                            : 'Sem clínica informada',
                      ),
                    )
                    .toList(),
                weights: pet.weights
                    .map(
                      (weight) => PdfWeightData(
                        weight: '${weight.weight.toStringAsFixed(1)} kg',
                        measuredAt: _formatDate(weight.measuredAt),
                        note: weight.note ?? '',
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
        timeline: _timeline
            .map(
              (entry) => PdfTimelineData(
                title: entry.title,
                subtitle: entry.subtitle,
                date: _formatDate(entry.date),
              ),
            )
            .toList(),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível gerar o PDF agora.')),
      );
    }
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _profile.name);
    final emailController = TextEditingController(text: _profile.email);
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              if (name.length < 2 || !email.contains('@')) return;
              Navigator.pop(dialogContext, (name, email));
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    nameController.dispose();
    emailController.dispose();
    if (result == null) return;
    await _database.saveProfile(name: result.$1, email: result.$2);
    if (!mounted) return;
    setState(() {
      _profile.name = result.$1;
      _profile.email = result.$2;
    });
  }

  Future<void> _saveBackup() async {
    try {
      final path = await BackupService.saveBackup(_database);
      if (!mounted || path == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup salvo com sucesso.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível salvar o backup.')),
      );
    }
  }

  Future<void> _shareBackup() async {
    try {
      await BackupService.shareBackup(_database);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível compartilhar o backup.'),
        ),
      );
    }
  }

  Future<void> _showPasswordRecovery(String initialEmail) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _PasswordRecoveryDialog(
        initialEmail: initialEmail,
        onRequestToken: _syncGateway.requestPasswordReset,
        onConfirm: _syncGateway.confirmPasswordReset,
      ),
    );
  }

  Future<void> _openAddressEditor() async {
    final session = await _sessionStore.read();
    if (session == null) {
      _showProductMessage(
        'Crie uma conta Family para cadastrar endereço e localização.',
      );
      return;
    }
    Map<String, dynamic>? existing;
    try {
      existing = await _syncGateway.loadAccountAddress(
        accessToken: session.accessToken,
      );
    } on SyncGatewayException catch (error) {
      _showProductMessage(error.message);
      return;
    }
    if (!mounted) return;

    final fields = <String, TextEditingController>{
      'country': TextEditingController(
        text: existing?['country'] as String? ?? 'Brasil',
      ),
      'state': TextEditingController(text: existing?['state'] as String? ?? ''),
      'city': TextEditingController(text: existing?['city'] as String? ?? ''),
      'postalCode': TextEditingController(
        text: existing?['postalCode'] as String? ?? '',
      ),
      'street': TextEditingController(
        text: existing?['street'] as String? ?? '',
      ),
      'number': TextEditingController(
        text: existing?['number'] as String? ?? '',
      ),
      'complement': TextEditingController(
        text: existing?['complement'] as String? ?? '',
      ),
      'neighborhood': TextEditingController(
        text: existing?['neighborhood'] as String? ?? '',
      ),
      'reference': TextEditingController(
        text: existing?['reference'] as String? ?? '',
      ),
      'latitude': TextEditingController(
        text: existing?['latitude']?.toString() ?? '',
      ),
      'longitude': TextEditingController(
        text: existing?['longitude']?.toString() ?? '',
      ),
      'accuracy': TextEditingController(
        text: existing?['accuracy']?.toString() ?? '',
      ),
    };
    var allowVetVisit = existing?['allowVetVisit'] == true;
    var busy = false;
    var locating = false;
    var locationSource = existing?['source'] as String? ?? 'manual';

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Endereço e localização'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Informe o endereço para comunicação. As coordenadas são opcionais e poderão ser usadas em uma futura solicitação de visita veterinária.',
                        style: TextStyle(color: _muted, height: 1.35),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _addressField(fields['country']!, 'País'),
                    _addressField(fields['state']!, 'Estado'),
                    _addressField(fields['city']!, 'Cidade'),
                    _addressField(fields['postalCode']!, 'CEP/código postal'),
                    _addressField(fields['street']!, 'Rua/avenida'),
                    _addressField(fields['number']!, 'Número'),
                    _addressField(
                      fields['complement']!,
                      'Complemento (opcional)',
                    ),
                    _addressField(fields['neighborhood']!, 'Bairro (opcional)'),
                    _addressField(
                      fields['reference']!,
                      'Ponto de referência (opcional)',
                    ),
                    const SizedBox(height: 6),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'GPS opcional (latitude, longitude e precisão em metros)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: busy || locating
                            ? null
                            : () async {
                                setDialogState(() => locating = true);
                                try {
                                  if (!await Geolocator.isLocationServiceEnabled()) {
                                    _showProductMessage(
                                      'Ative a localização do aparelho para usar o GPS.',
                                    );
                                    return;
                                  }
                                  var permission =
                                      await Geolocator.checkPermission();
                                  if (permission == LocationPermission.denied) {
                                    permission =
                                        await Geolocator.requestPermission();
                                  }
                                  if (permission == LocationPermission.denied ||
                                      permission ==
                                          LocationPermission.deniedForever) {
                                    _showProductMessage(
                                      'Permissão de localização não concedida. Você pode informar o endereço manualmente.',
                                    );
                                    return;
                                  }
                                  final position =
                                      await Geolocator.getCurrentPosition(
                                        locationSettings:
                                            const LocationSettings(
                                              accuracy: LocationAccuracy.high,
                                            ),
                                      );
                                  fields['latitude']!.text = position.latitude
                                      .toStringAsFixed(7);
                                  fields['longitude']!.text = position.longitude
                                      .toStringAsFixed(7);
                                  fields['accuracy']!.text = position.accuracy
                                      .toStringAsFixed(1);
                                  locationSource = 'device';
                                  _showProductMessage(
                                    'Localização atual preenchida. Confira o endereço antes de salvar.',
                                  );
                                } catch (_) {
                                  _showProductMessage(
                                    'Não foi possível obter a localização atual.',
                                  );
                                } finally {
                                  if (context.mounted) {
                                    setDialogState(() => locating = false);
                                  }
                                }
                              },
                        icon: Icon(
                          locating ? Icons.sync : Icons.my_location_outlined,
                        ),
                        label: Text(
                          locating
                              ? 'Obtendo localização...'
                              : 'Usar localização atual',
                        ),
                      ),
                    ),
                    _addressField(
                      fields['latitude']!,
                      'Latitude',
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    _addressField(
                      fields['longitude']!,
                      'Longitude',
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    _addressField(
                      fields['accuracy']!,
                      'Precisão em metros (opcional)',
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: allowVetVisit,
                      onChanged: busy
                          ? null
                          : (value) =>
                                setDialogState(() => allowVetVisit = value),
                      title: const Text(
                        'Aceito avaliar atendimento veterinário no local',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: busy ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: busy
                    ? null
                    : () async {
                        final requiredKeys = [
                          'country',
                          'state',
                          'city',
                          'postalCode',
                          'street',
                          'number',
                        ];
                        if (requiredKeys.any(
                          (key) => fields[key]!.text.trim().isEmpty,
                        )) {
                          _showProductMessage(
                            'Preencha país, estado, cidade, CEP, rua e número.',
                          );
                          return;
                        }
                        setDialogState(() => busy = true);
                        try {
                          await _syncGateway.saveAccountAddress(
                            accessToken: session.accessToken,
                            address: {
                              'country': fields['country']!.text.trim(),
                              'state': fields['state']!.text.trim(),
                              'city': fields['city']!.text.trim(),
                              'postalCode': fields['postalCode']!.text.trim(),
                              'street': fields['street']!.text.trim(),
                              'number': fields['number']!.text.trim(),
                              'complement': fields['complement']!.text.trim(),
                              'neighborhood': fields['neighborhood']!.text
                                  .trim(),
                              'reference': fields['reference']!.text.trim(),
                              'latitude': double.tryParse(
                                fields['latitude']!.text.trim(),
                              ),
                              'longitude': double.tryParse(
                                fields['longitude']!.text.trim(),
                              ),
                              'accuracy': double.tryParse(
                                fields['accuracy']!.text.trim(),
                              ),
                              'source': locationSource,
                              'allowVetVisit': allowVetVisit,
                              'consentVersion': 'v1.0',
                            },
                          );
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          _showProductMessage('Endereço salvo com segurança.');
                        } on SyncGatewayException catch (error) {
                          if (context.mounted) {
                            setDialogState(() => busy = false);
                            _showProductMessage(error.message);
                          }
                        }
                      },
                child: Text(busy ? 'Salvando...' : 'Salvar endereço'),
              ),
            ],
          ),
        ),
      );
    } finally {
      for (final controller in fields.values) {
        controller.dispose();
      }
    }
  }

  Future<void> _showSubscriptionOptions() async {
    Map<String, dynamic> catalog = const {};
    try {
      catalog = await _syncGateway.loadBillingCatalog();
    } catch (_) {
      // Os preços de referência abaixo mantêm a tela útil durante o modo offline.
    }
    if (!mounted) return;
    final products = catalog['products'] is List
        ? (catalog['products'] as List).whereType<Map>().toList()
        : const <Map>[];
    double pixAmountFor(String productId, double fallback) {
      for (final product in products) {
        if (product['productId'] == productId) {
          final amount = product['priceBrl'] ?? product['pixAmountBrl'];
          if (amount is num) return amount.toDouble();
          return double.tryParse(amount.toString().replaceAll(',', '.')) ??
              fallback;
        }
      }
      return fallback;
    }

    String pixPriceFor(String productId, double fallback) {
      final amount = pixAmountFor(productId, fallback);
      return 'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}';
    }

    void openPix(
      BuildContext dialogContext,
      String productId,
      String planName,
      double fallback,
    ) {
      final amount = pixAmountFor(productId, fallback);
      Navigator.pop(dialogContext);
      Future<void>.delayed(Duration.zero, () {
        if (mounted) {
          _showPixPayment(
            productId: productId,
            planName: planName,
            amount: amount,
          );
        }
      });
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Conheça o AuMiau Family'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mais pets, sincronização e recursos para cuidar da família inteira.',
              style: TextStyle(color: _muted, height: 1.35),
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_month_outlined,
                color: _forest,
              ),
              title: const Text('Plano mensal'),
              subtitle: const Text('Pagamento seguro via Mercado Pago'),
              trailing: Text(
                pixPriceFor('family_monthly', 2.99),
                textAlign: TextAlign.end,
              ),
              onTap: () => openPix(
                dialogContext,
                'family_monthly',
                'Family mensal',
                2.99,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.event_available_outlined,
                color: _forest,
              ),
              title: const Text('Plano anual'),
              subtitle: const Text('Pagamento seguro via Mercado Pago'),
              trailing: Text(
                pixPriceFor('family_yearly', 25.00),
                textAlign: TextAlign.end,
              ),
              onTap: () => openPix(
                dialogContext,
                'family_yearly',
                'Family anual',
                25.00,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Para assinar, entre ou crie uma conta. O Mercado Pago confirmará o pagamento e liberará o Family automaticamente.',
              style: TextStyle(fontSize: 12, color: _muted, height: 1.35),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPixPayment({
    required String productId,
    required String planName,
    required double amount,
  }) async {
    if (_accessToken == null) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Conta necessária'),
          content: const Text(
            'Para assinar o AuMiau Family, entre ou crie uma conta. '
            'Assim o pagamento será associado a você e o acesso será liberado automaticamente.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _openAuth(_AuthScreen.login);
              },
              child: const Text('Entrar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _openAuth(_AuthScreen.register);
              },
              child: const Text('Criar conta'),
            ),
          ],
        ),
      );
      return;
    }

    late final Map<String, dynamic> onlineOrder;
    try {
      onlineOrder = await _syncGateway.createBillingOrder(
        accessToken: _accessToken!,
        productId: productId,
      );
    } on SyncGatewayException catch (error) {
      _showProductMessage(
        'Não foi possível conectar ao Mercado Pago agora. ${error.message}',
      );
      return;
    }
    if (!mounted) return;
    final pixCode = onlineOrder['qrCode'];
    final orderId = onlineOrder['orderId'];
    if (pixCode is! String || pixCode.isEmpty || orderId is! String) {
      _showProductMessage(
        'O Mercado Pago não retornou uma cobrança válida. Tente novamente.',
      );
      return;
    }
    final paidAmount = onlineOrder['amountBrl'] is num
        ? (onlineOrder['amountBrl'] as num).toDouble()
        : amount;
    final amountLabel =
        'R\$ ${paidAmount.toStringAsFixed(2).replaceAll('.', ',')}';
    final qrCodeBase64 = onlineOrder['qrCodeBase64'] is String
        ? onlineOrder['qrCodeBase64'] as String
        : null;
    final isTestEnvironment = onlineOrder['environment'] == 'test';
    final ticketUrl = onlineOrder['ticketUrl'] is String
        ? onlineOrder['ticketUrl'] as String
        : null;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Pix - $planName'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Valor em Reais: $amountLabel',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _forest,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isTestEnvironment
                    ? 'Ambiente de teste: use “Abrir pagamento” para simular a cobrança. Bancos reais não processam este QR.'
                    : 'Escaneie o QR Code usando o aplicativo do seu banco.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 230,
                height: 230,
                child: qrCodeBase64 != null
                    ? Image.memory(
                        base64Decode(qrCodeBase64),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            QrImageView(
                              data: pixCode,
                              version: QrVersions.auto,
                              backgroundColor: Colors.white,
                            ),
                      )
                    : QrImageView(
                        data: pixCode,
                        version: QrVersions.auto,
                        backgroundColor: Colors.white,
                      ),
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pagamento processado pelo Mercado Pago.\n'
                  'Este QR Code é exclusivo para esta cobrança.',
                  style: TextStyle(fontSize: 12, color: _muted),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _openWhatsAppSupport,
                  icon: const Icon(Icons.chat_outlined, size: 18),
                  label: const Text('+55 92 99158-0637 - WhatsApp'),
                ),
              ),
              const SizedBox(height: 10),
              SelectableText(
                pixCode,
                style: const TextStyle(fontSize: 9, color: _muted),
              ),
              const SizedBox(height: 10),
              Text(
                isTestEnvironment
                    ? 'Este pagamento está no sandbox do Mercado Pago e não libera uma cobrança real.'
                    : 'Após o pagamento, o Mercado Pago notificará o servidor. O Family será liberado depois da confirmação do pagamento.',
                style: const TextStyle(
                  fontSize: 12,
                  color: _danger,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (ticketUrl != null)
            TextButton(
              onPressed: () => launchUrl(
                Uri.parse(ticketUrl),
                mode: LaunchMode.externalApplication,
              ),
              child: const Text('Abrir pagamento'),
            ),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: pixCode));
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              _showProductMessage('Pix Copia e Cola copiado.');
            },
            child: const Text('Copiar código'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final updated = await _syncGateway.loadBillingOrder(
                  accessToken: _accessToken!,
                  orderId: orderId,
                );
                if (updated['paid'] == true) {
                  await _refreshAccountEntitlement();
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  _showProductMessage('Pagamento confirmado. Family liberado.');
                } else {
                  _showProductMessage('Pagamento ainda não confirmado.');
                }
              } on SyncGatewayException catch (error) {
                _showProductMessage(error.message);
              }
            },
            child: const Text('Atualizar status'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsAppSupport() async {
    const phone = '5592991580637';
    final message = Uri.encodeComponent(
      'Olá! Preciso de ajuda com o pagamento do AuMiau Family.',
    );
    final whatsappUri = Uri.parse('https://wa.me/$phone?text=$message');
    final opened = await launchUrl(
      whatsappUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      _showProductMessage('Não foi possível abrir o WhatsApp.');
    }
  }

  Widget _addressField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Future<void> _restoreSession() async {
    final session = await _sessionStore.read();
    if (!mounted) return;
    if (session == null) {
      setState(() => _showAuthGate = true);
      return;
    }
    setState(() {
      _accessToken = session.accessToken;
      _showAuthGate = false;
    });
    await _loadData();
    await _refreshAccountEntitlement();
  }

  Future<void> _refreshAccountEntitlement() async {
    final accessToken = _accessToken;
    if (accessToken == null) return;
    try {
      final status = await _syncGateway.loadAccountStatus(
        accessToken: accessToken,
      );
      final entitlement = status['entitlement'];
      final entitlementMap = entitlement is Map
          ? Map<String, dynamic>.from(entitlement)
          : const <String, dynamic>{};
      final validUntil = entitlementMap['validUntil'] is String
          ? DateTime.tryParse(entitlementMap['validUntil'] as String)
          : null;
      final active =
          entitlementMap['status'] == 'active' &&
          (validUntil == null || validUntil.isAfter(DateTime.now().toUtc()));
      final profile = await _database.loadProfile();
      if (profile == null) return;
      await _database.saveProfile(
        name: profile.name,
        email: profile.email,
        plan: active
            ? ProductCatalog.family.code
            : ProductCatalog.freeOffline.code,
      );
      if (!mounted) return;
      setState(() {
        _profile.plan = active
            ? ProductCatalog.family.code
            : ProductCatalog.freeOffline.code;
        _profile.familyEnabled = active;
      });
    } on SyncGatewayException {
      // O app continua offline com o último estado local conhecido.
    }
  }

  void _openAuth(_AuthScreen screen) {
    if (!mounted) return;
    setState(() {
      _authScreen = screen;
      _showAuthGate = true;
    });
  }

  Future<void> _continueOffline() async {
    if (!mounted) return;
    setState(() => _showAuthGate = false);
  }

  Future<void> _completeAuthenticatedSession({
    required String email,
    required SyncAuthSession session,
    String? name,
  }) async {
    _accessToken = session.accessToken;
    await _sessionStore.save(
      email: email,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    final existingProfile = await _database.loadProfile();
    await _database.saveProfile(
      name: name?.trim().isNotEmpty == true
          ? name!.trim()
          : (existingProfile?.name.trim().isNotEmpty == true
                ? existingProfile!.name
                : email),
      email: email,
      plan: ProductCatalog.family.code,
    );
    if (!mounted) return;
    setState(() {
      _showAuthGate = false;
      _authBusy = false;
      _selectedIndex = 0;
    });
    await _loadData();
    await _refreshAccountEntitlement();
    if (name != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_openAddressEditor());
      });
    }
  }

  Future<void> _loginFromAuth({
    required String email,
    required String password,
  }) async {
    if (_authBusy) return;
    setState(() => _authBusy = true);
    try {
      final session = await _syncGateway.signIn(
        email: email.trim(),
        password: password,
      );
      await _completeAuthenticatedSession(
        email: email.trim(),
        session: session,
      );
    } on SyncGatewayException catch (error) {
      if (!mounted) return;
      setState(() => _authBusy = false);
      _showAuthError(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _authBusy = false);
      _showAuthError('Não foi possível entrar agora. Verifique sua conexão.');
    }
  }

  Future<void> _registerFromAuth({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? birthDate,
  }) async {
    if (_authBusy) return;
    setState(() => _authBusy = true);
    try {
      final result = await _syncGateway.register(
        name: name,
        phone: phone,
        email: email.trim(),
        password: password,
        birthDate: birthDate,
        termsAccepted: true,
      );
      if (result.session != null) {
        await _completeAuthenticatedSession(
          email: result.email,
          session: result.session!,
          name: name,
        );
        return;
      }
      if (!mounted) return;
      setState(() {
        _authBusy = false;
        _pendingVerificationEmail = result.email;
        _pendingRegistrationName = name;
        _authScreen = _AuthScreen.verifyEmail;
      });
    } on SyncGatewayException catch (error) {
      if (!mounted) return;
      setState(() => _authBusy = false);
      _showAuthError(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _authBusy = false);
      _showAuthError('Não foi possível criar a conta agora.');
    }
  }

  Future<void> _verifyEmailFromAuth(String token) async {
    final email = _pendingVerificationEmail;
    if (_authBusy || email == null) return;
    setState(() => _authBusy = true);
    try {
      final session = await _syncGateway.verifyEmail(
        email: email,
        token: token,
      );
      await _completeAuthenticatedSession(
        email: email,
        session: session,
        name: _pendingRegistrationName,
      );
    } on SyncGatewayException catch (error) {
      if (!mounted) return;
      setState(() => _authBusy = false);
      _showAuthError(error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _authBusy = false);
      _showAuthError('Não foi possível confirmar o e-mail agora.');
    }
  }

  void _showAuthError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: _danger));
  }

  Future<SyncBatchAck?> _synchronizeWithRefresh(StoredSession session) async {
    try {
      return await SyncService(
        _database,
      ).synchronize(gateway: _syncGateway, accessToken: session.accessToken);
    } on SyncGatewayException catch (error) {
      final refreshToken = session.refreshToken;
      if (error.statusCode != 401 || refreshToken == null) rethrow;
      final refreshed = await _syncGateway.refreshSession(
        refreshToken: refreshToken,
      );
      final refreshedSession = StoredSession(
        email: session.email,
        accessToken: refreshed.accessToken,
        refreshToken: refreshed.refreshToken,
      );
      _accessToken = refreshed.accessToken;
      await _sessionStore.save(
        email: refreshedSession.email,
        accessToken: refreshedSession.accessToken,
        refreshToken: refreshedSession.refreshToken,
      );
      return SyncService(
        _database,
      ).synchronize(gateway: _syncGateway, accessToken: refreshed.accessToken);
    }
  }

  Future<void> _syncNow() async {
    if (_syncing) return;
    final storedSession = await _sessionStore.read();
    if (storedSession == null) {
      _openAuth(_AuthScreen.login);
      return;
    }
    if (!mounted) return;
    setState(() => _syncing = true);
    try {
      _accessToken = storedSession.accessToken;
      final acknowledgement = await _synchronizeWithRefresh(storedSession);
      await _loadData();
      if (!mounted) return;
      final count = acknowledgement?.acknowledgedOperationIds.length ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count == 0
                ? 'Nenhuma alteracao pendente para sincronizar.'
                : 'Sincroniza\u00E7\u00E3o conclu\u00EDda: $count operac\u00E3o(\u00F5es).',
          ),
        ),
      );
    } on SyncGatewayException catch (error) {
      if (error.statusCode == 401) {
        _accessToken = null;
        await _sessionStore.clear();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha na sincroniza\u00E7\u00E3o: ${error.message}'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel sincronizar agora.')),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _logout() async {
    if (_syncing) return;
    final storedSession = await _sessionStore.read();
    final accessToken = _accessToken ?? storedSession?.accessToken;
    try {
      if (accessToken != null) {
        await _syncGateway.logout(accessToken: accessToken);
      }
    } on SyncGatewayException {
      // A sessão local é removida mesmo se o token já estiver expirado.
    } finally {
      await _sessionStore.clear();
      _accessToken = null;
    }
    if (!mounted) return;
    setState(() {
      _authScreen = _AuthScreen.welcome;
      _showAuthGate = true;
      _selectedIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sessão encerrada neste aparelho.')),
    );
  }

  Future<void> _restoreBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restaurar backup?'),
        content: const Text(
          'Os dados locais atuais serão substituídos pelo conteúdo do arquivo. '
          'Faça um backup antes de continuar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Selecionar arquivo'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await BackupService.restoreBackup(_database);
      if (!mounted) return;
      setState(() {
        _loading = true;
        _loadError = null;
      });
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup restaurado com sucesso.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível restaurar o backup.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: _forest)),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, color: _danger, size: 42),
                const SizedBox(height: 12),
                Text(_loadError!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                      _loadError = null;
                    });
                    _loadData();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_showAuthGate) {
      return _AuthFlowPage(
        screen: _authScreen,
        busy: _authBusy,
        verificationEmail: _pendingVerificationEmail,
        onLogin: () => _openAuth(_AuthScreen.login),
        onRegister: () => _openAuth(_AuthScreen.register),
        onOffline: _continueOffline,
        onBack: () => _openAuth(_AuthScreen.welcome),
        onSubmitLogin: _loginFromAuth,
        onSubmitRegister: _registerFromAuth,
        onVerifyEmail: _verifyEmailFromAuth,
        onRecovery: () => _showPasswordRecovery(_profile.email),
      );
    }

    final pages = [
      TodayPage(
        today: _today,
        profileName: _profile.name,
        pets: _pets,
        reminders: _reminders,
        onComplete: _completePersistentReminder,
        onAddReminder: _openAddReminder,
        onEditReminder: _editReminder,
        onDeleteReminder: _deleteReminder,
      ),
      PetsPage(
        pets: _pets,
        onAddPet: _openAddPet,
        onOpenVaccineWallet: _openVaccineWallet,
        onEditPet: _editPet,
        onDeletePet: _deletePet,
      ),
      HistoryPage(
        pets: _pets,
        timeline: _timeline,
        onAddWeight: _openAddWeight,
        onExportPdf: _exportHistoryPdf,
      ),
      ProfilePage(
        profile: _profile,
        petCount: _pets.length,
        onOpenSubscription: _showSubscriptionOptions,
        onEditAddress: _profile.isFamily ? _openAddressEditor : null,
        pendingSyncCount: _pendingSyncCount,
        onEdit: _editProfile,
        onSaveBackup: _saveBackup,
        onShareBackup: _shareBackup,
        onRestoreBackup: _restoreBackup,
        onSync: _syncNow,
        onLogout: _logout,
        syncing: _syncing,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: pages[_selectedIndex],
          ),
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openAddReminder,
              backgroundColor: _mango,
              foregroundColor: _forestDark,
              icon: const Icon(Icons.add),
              label: const Text('Lembrete'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: _mango.withValues(alpha: .24),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hoje',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Pets',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _AuthFlowPage extends StatelessWidget {
  const _AuthFlowPage({
    required this.screen,
    required this.busy,
    required this.verificationEmail,
    required this.onLogin,
    required this.onRegister,
    required this.onOffline,
    required this.onBack,
    required this.onSubmitLogin,
    required this.onSubmitRegister,
    required this.onVerifyEmail,
    required this.onRecovery,
  });

  final _AuthScreen screen;
  final bool busy;
  final String? verificationEmail;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final Future<void> Function() onOffline;
  final VoidCallback onBack;
  final Future<void> Function({required String email, required String password})
  onSubmitLogin;
  final Future<void> Function({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? birthDate,
  })
  onSubmitRegister;
  final Future<void> Function(String token) onVerifyEmail;
  final Future<void> Function() onRecovery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _authBlush,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_paper, Color(0xFFF1EEE5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _PawPrintPatternPainter()),
              ),
            ),
            const Positioned(
              top: -80,
              left: -70,
              child: _AuthBubble(size: 210, color: Color(0x22FFB627)),
            ),
            const Positioned(
              right: -90,
              bottom: -70,
              child: _AuthBubble(size: 230, color: Color(0x221E4D40)),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: _buildScreen(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen(BuildContext context) {
    switch (screen) {
      case _AuthScreen.welcome:
        return _AuthWelcomeView(
          onLogin: onLogin,
          onRegister: onRegister,
          onOffline: onOffline,
        );
      case _AuthScreen.login:
        return _AuthLoginView(
          busy: busy,
          onBack: onBack,
          onRegister: onRegister,
          onSubmit: onSubmitLogin,
          onRecovery: onRecovery,
        );
      case _AuthScreen.register:
        return _AuthRegisterView(
          busy: busy,
          onBack: onBack,
          onLogin: onLogin,
          onSubmit: onSubmitRegister,
        );
      case _AuthScreen.verifyEmail:
        return _AuthVerifyEmailView(
          busy: busy,
          email: verificationEmail ?? '',
          onBack: onBack,
          onSubmit: onVerifyEmail,
        );
    }
  }
}

class _AuthBubble extends StatelessWidget {
  const _AuthBubble({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

class _PawPrintPatternPainter extends CustomPainter {
  const _PawPrintPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const pawSpacingX = 104.0;
    const pawSpacingY = 98.0;
    const rotations = <double>[-.16, .08, .18, -.08];

    var row = 0;
    for (var y = 38.0; y < size.height + pawSpacingY; y += pawSpacingY) {
      var column = 0;
      final offsetX = row.isEven ? 8.0 : 58.0;
      for (var x = offsetX; x < size.width + pawSpacingX; x += pawSpacingX) {
        final rotation = rotations[(row + column) % rotations.length];
        final scale = (row + column).isEven ? .72 : .6;
        _drawPaw(
          canvas,
          Offset(x, y),
          scale,
          rotation,
          const Color(0x0D1E4D40),
        );
        _drawPaw(
          canvas,
          Offset(x - .9, y - 1.2),
          scale,
          rotation,
          const Color(0x2BFFFFFF),
        );
        column++;
      }
      row++;
    }
  }

  void _drawPaw(
    Canvas canvas,
    Offset center,
    double scale,
    double rotation,
    Color color,
  ) {
    final paint = Paint()..color = color;
    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(rotation)
      ..scale(scale);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 11), width: 31, height: 24),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-19, -3), width: 11, height: 16),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-7, -13), width: 11, height: 16),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(7, -13), width: 11, height: 16),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(19, -3), width: 11, height: 16),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AuthWelcomeView extends StatelessWidget {
  const _AuthWelcomeView({
    required this.onLogin,
    required this.onRegister,
    required this.onOffline,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final Future<void> Function() onOffline;

  @override
  Widget build(BuildContext context) {
    return _AuthCard(
      children: [
        const SizedBox(height: 18),
        const _AuthBrand(showTagline: true),
        const SizedBox(height: 30),
        const Text(
          'Cuide de quem ama',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ink,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Rotina, saúde e carinho para seus pets em um só lugar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 16, height: 1.45),
        ),
        const SizedBox(height: 34),
        _AuthPrimaryButton(label: 'Entrar', onPressed: onLogin),
        const SizedBox(height: 14),
        _AuthOutlineButton(label: 'Criar conta', onPressed: onRegister),
        const SizedBox(height: 24),
        TextButton(
          onPressed: onOffline,
          child: const Text(
            'Usar aplicativo offline',
            style: TextStyle(color: _authPinkDark, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'AuMiau Free Offline: seus dados ficam somente neste aparelho.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 12),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _AuthLoginView extends StatefulWidget {
  const _AuthLoginView({
    required this.busy,
    required this.onBack,
    required this.onRegister,
    required this.onSubmit,
    required this.onRecovery,
  });

  final bool busy;
  final VoidCallback onBack;
  final VoidCallback onRegister;
  final Future<void> Function({required String email, required String password})
  onSubmit;
  final Future<void> Function() onRecovery;

  @override
  State<_AuthLoginView> createState() => _AuthLoginViewState();
}

class _AuthLoginViewState extends State<_AuthLoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (!email.contains('@') || _password.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um e-mail e uma senha válida.')),
      );
      return;
    }
    await widget.onSubmit(email: email, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    return _AuthCard(
      children: [
        _AuthBackButton(onPressed: widget.onBack),
        const _AuthBrand(),
        const SizedBox(height: 24),
        const Text(
          'Bem-vindo(a)! 👋',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ink,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Entre para acompanhar a rotina dos seus pets.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 15),
        ),
        const SizedBox(height: 28),
        _AuthField(
          controller: _email,
          label: 'E-mail',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _AuthField(
          controller: _password,
          label: 'Senha',
          icon: Icons.lock_outline,
          obscureText: _obscure,
          suffix: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(
              _obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: widget.busy ? null : widget.onRecovery,
            child: const Text('Esqueci minha senha?'),
          ),
        ),
        _AuthPrimaryButton(
          label: 'Entrar',
          busy: widget.busy,
          onPressed: _submit,
        ),
        const SizedBox(height: 22),
        _AuthFooterLink(
          prefix: 'Ainda não tem conta? ',
          action: 'Criar conta',
          onPressed: widget.onRegister,
        ),
      ],
    );
  }
}

class _AuthRegisterView extends StatefulWidget {
  const _AuthRegisterView({
    required this.busy,
    required this.onBack,
    required this.onLogin,
    required this.onSubmit,
  });

  final bool busy;
  final VoidCallback onBack;
  final VoidCallback onLogin;
  final Future<void> Function({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? birthDate,
  })
  onSubmit;

  @override
  State<_AuthRegisterView> createState() => _AuthRegisterViewState();
}

class _AuthRegisterViewState extends State<_AuthRegisterView> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  DateTime? _birthDate;
  bool _obscure = true;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _phone = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: _birthDate ?? DateTime(1990),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _authPink)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    if (_name.text.trim().length < 2 ||
        _phone.text.trim().length < 8 ||
        !_email.text.contains('@') ||
        _password.text.length < 8 ||
        _password.text != _confirmPassword.text ||
        !_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revise os dados e aceite os termos para continuar.'),
        ),
      );
      return;
    }
    await widget.onSubmit(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      birthDate: _birthDate?.toIso8601String(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final birthLabel = _birthDate == null
        ? 'Data de nascimento (opcional)'
        : '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}';
    return _AuthCard(
      children: [
        _AuthBackButton(onPressed: widget.onBack),
        const _AuthBrand(),
        const SizedBox(height: 22),
        const Text(
          'Criar conta',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ink,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Vamos começar!',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 16),
        ),
        const SizedBox(height: 24),
        _AuthField(
          controller: _name,
          label: 'Nome completo',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _AuthField(
          controller: _phone,
          label: 'Telefone/WhatsApp',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        _AuthField(
          controller: _email,
          label: 'E-mail',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _AuthField(
          controller: _password,
          label: 'Senha (mínimo de 8 caracteres)',
          icon: Icons.lock_outline,
          obscureText: _obscure,
          suffix: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(
              _obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _AuthField(
          controller: _confirmPassword,
          label: 'Confirmar senha',
          icon: Icons.lock_reset_outlined,
          obscureText: _obscure,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickBirthDate,
          borderRadius: BorderRadius.circular(14),
          child: InputDecorator(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_month_outlined),
            ),
            child: Text(
              birthLabel,
              style: TextStyle(color: _birthDate == null ? _muted : _ink),
            ),
          ),
        ),
        const SizedBox(height: 14),
        CheckboxListTile(
          value: _acceptedTerms,
          onChanged: widget.busy
              ? null
              : (value) => setState(() => _acceptedTerms = value ?? false),
          contentPadding: EdgeInsets.zero,
          activeColor: _authPink,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            'Li e aceito os Termos de Uso e a Política de Privacidade.',
            style: TextStyle(fontSize: 13, height: 1.35),
          ),
        ),
        const SizedBox(height: 8),
        _AuthPrimaryButton(
          label: 'Criar conta',
          busy: widget.busy,
          onPressed: _submit,
        ),
        const SizedBox(height: 22),
        _AuthFooterLink(
          prefix: 'Já tem conta? ',
          action: 'Entrar',
          onPressed: widget.onLogin,
        ),
      ],
    );
  }
}

class _AuthVerifyEmailView extends StatefulWidget {
  const _AuthVerifyEmailView({
    required this.busy,
    required this.email,
    required this.onBack,
    required this.onSubmit,
  });

  final bool busy;
  final String email;
  final VoidCallback onBack;
  final Future<void> Function(String token) onSubmit;

  @override
  State<_AuthVerifyEmailView> createState() => _AuthVerifyEmailViewState();
}

class _AuthVerifyEmailViewState extends State<_AuthVerifyEmailView> {
  late final TextEditingController _token;

  @override
  void initState() {
    super.initState();
    _token = TextEditingController();
  }

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_token.text.trim().length < 32) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o token completo enviado por e-mail.'),
        ),
      );
      return;
    }
    await widget.onSubmit(_token.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return _AuthCard(
      children: [
        _AuthBackButton(onPressed: widget.onBack),
        const _AuthBrand(),
        const SizedBox(height: 28),
        const Icon(Icons.mark_email_read_outlined, color: _authPink, size: 62),
        const SizedBox(height: 18),
        const Text(
          'Confirme seu e-mail',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ink,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Enviamos um token de confirmação para ${widget.email}.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, height: 1.45),
        ),
        const SizedBox(height: 26),
        _AuthField(
          controller: _token,
          label: 'Token de confirmação',
          icon: Icons.key_outlined,
          keyboardType: TextInputType.text,
        ),
        const SizedBox(height: 18),
        _AuthPrimaryButton(
          label: 'Confirmar e entrar',
          busy: widget.busy,
          onPressed: _submit,
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .88),
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: const Color(0x331E4D40)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x16000000),
          blurRadius: 28,
          offset: Offset(0, 12),
        ),
      ],
    ),
    child: Column(children: children),
  );
}

class _AuthBrand extends StatelessWidget {
  const _AuthBrand({this.showTagline = false});

  final bool showTagline;

  @override
  Widget build(BuildContext context) => Column(
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
      if (showTagline)
        const Text(
          'CUIDADO COM CARINHO',
          style: TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
    ],
  );
}

class _AuthBackButton extends StatelessWidget {
  const _AuthBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back, color: _ink),
    ),
  );
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscureText,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _authPink),
      suffixIcon: suffix,
    ),
  );
}

class _AuthPrimaryButton extends StatelessWidget {
  const _AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: FilledButton(
      onPressed: busy ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: _authPink,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: busy
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
    ),
  );
}

class _AuthOutlineButton extends StatelessWidget {
  const _AuthOutlineButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _ink,
        side: const BorderSide(color: _authPink, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
    ),
  );
}

class _AuthFooterLink extends StatelessWidget {
  const _AuthFooterLink({
    required this.prefix,
    required this.action,
    required this.onPressed,
  });

  final String prefix;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    children: [
      Text(prefix, style: const TextStyle(color: _muted)),
      GestureDetector(
        onTap: onPressed,
        child: Text(
          action,
          style: const TextStyle(
            color: _authPinkDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ],
  );
}

class TodayPage extends StatelessWidget {
  const TodayPage({
    super.key,
    required this.today,
    required this.profileName,
    required this.pets,
    required this.reminders,
    required this.onComplete,
    required this.onAddReminder,
    required this.onEditReminder,
    required this.onDeleteReminder,
  });

  final DateTime today;
  final String profileName;
  final List<Pet> pets;
  final List<Reminder> reminders;
  final void Function(Reminder) onComplete;
  final VoidCallback onAddReminder;
  final void Function(Reminder) onEditReminder;
  final void Function(Reminder) onDeleteReminder;

  @override
  Widget build(BuildContext context) {
    final due = reminders
        .where(
          (item) => !_sameDay(item.dueDate, today)
              ? item.dueDate.isBefore(today.add(const Duration(days: 1)))
              : true,
        )
        .toList();
    final upcoming = reminders
        .where(
          (item) =>
              item.dueDate.isAfter(today) &&
              item.dueDate.isBefore(today.add(const Duration(days: 8))),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        _TopHeader(today: today),
        const SizedBox(height: 22),
        Text(
          profileName.trim().isEmpty
              ? 'Cuide de quem ama'
              : 'Oi, ${profileName.trim()}! 👋',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          due.isEmpty
              ? 'Tudo em dia por hoje!'
              : '${due.length} cuidado${due.length == 1 ? '' : 's'} dos seus pets para hoje.',
          style: const TextStyle(color: _muted, fontSize: 15),
        ),
        const SizedBox(height: 18),
        Row(
          children: pets
              .map(
                (pet) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _PetMiniCard(pet: pet),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 26),
        _SectionHeader(
          title: 'Cuidados de hoje',
          action: 'Ver histórico',
          onTap: () {},
        ),
        const SizedBox(height: 10),
        if (due.isEmpty)
          const _EmptyState(
            icon: Icons.check_circle_outline,
            title: 'Nenhum cuidado pendente',
            subtitle: 'A rotina dos seus pets está em dia.',
          ),
        ...due.map(
          (reminder) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ReminderCard(
              reminder: reminder,
              today: today,
              onComplete: () => onComplete(reminder),
              onEdit: () => onEditReminder(reminder),
              onDelete: () => onDeleteReminder(reminder),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SectionHeader(
          title: 'Próximos 7 dias',
          action: 'Adicionar',
          onTap: onAddReminder,
        ),
        const SizedBox(height: 10),
        if (upcoming.isEmpty)
          const _EmptyState(
            icon: Icons.event_available_outlined,
            title: 'Nada agendado para a semana',
            subtitle: 'Adicione um lembrete para não depender da memória.',
          ),
        ...upcoming.map(
          (reminder) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ReminderCard(
              reminder: reminder,
              today: today,
              onComplete: () => onComplete(reminder),
              onEdit: () => onEditReminder(reminder),
              onDelete: () => onDeleteReminder(reminder),
              compact: true,
            ),
          ),
        ),
      ],
    );
  }
}

class PetsPage extends StatelessWidget {
  const PetsPage({
    super.key,
    required this.pets,
    required this.onAddPet,
    this.onOpenVaccineWallet,
    this.onEditPet,
    this.onDeletePet,
  });

  final List<Pet> pets;
  final VoidCallback onAddPet;
  final void Function(Pet pet)? onOpenVaccineWallet;
  final void Function(Pet pet)? onEditPet;
  final void Function(Pet pet)? onDeletePet;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        Text(
          'Seus pets',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Carteira de saúde, rotina e histórico em um só lugar.',
          style: TextStyle(color: _muted, fontSize: 15),
        ),
        const SizedBox(height: 22),
        ...pets.map(
          (pet) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _PetCard(
              pet: pet,
              onOpenVaccineWallet: onOpenVaccineWallet,
              onEdit: onEditPet,
              onDelete: onDeletePet,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onAddPet,
          icon: const Icon(Icons.add),
          label: const Text('Cadastrar outro pet'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _forest,
            side: const BorderSide(color: _forest),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 26),
        const _InfoBanner(
          icon: Icons.lock_outline,
          title: 'Seus dados ficam com você',
          text:
              'Nesta primeira versão, o núcleo funciona localmente. A sincronização segura será conectada na próxima etapa.',
        ),
      ],
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({
    super.key,
    this.history = const [],
    required this.pets,
    this.timeline = const [],
    this.onAddWeight,
    this.onExportPdf,
  });

  final List<String> history;
  final List<Pet> pets;
  final List<TimelineEntry> timeline;
  final VoidCallback? onAddWeight;
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        Text(
          'Histórico',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Acompanhe a evolução e leve informações organizadas ao veterinário.',
          style: TextStyle(color: _muted, fontSize: 15),
        ),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Peso dos pets',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: _ink,
                        ),
                      ),
                    ),
                    if (onAddWeight != null)
                      TextButton.icon(
                        onPressed: onAddWeight,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Registrar'),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Últimos registros',
                  style: TextStyle(color: _muted),
                ),
                const SizedBox(height: 16),
                SizedBox(height: 150, child: _WeightChart(pets: pets)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Registros de peso',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: _ink,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: [
              for (final pet in pets)
                for (final weight in pet.weights.take(4))
                  ListTile(
                    leading: const Icon(
                      Icons.monitor_weight_outlined,
                      color: _forest,
                    ),
                    title: Text(
                      '${pet.name}: ${weight.weight.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                    subtitle: Text(
                      '${_formatDate(weight.measuredAt)}${weight.note?.isNotEmpty == true ? ' · ${weight.note}' : ''}',
                      style: const TextStyle(color: _muted),
                    ),
                  ),
              if (pets.every((pet) => pet.weights.isEmpty))
                const ListTile(
                  leading: Icon(Icons.info_outline, color: _muted),
                  title: Text('Nenhum peso detalhado registrado.'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Linha do tempo unificada',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: _ink,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: timeline.isNotEmpty
                ? timeline
                      .map(
                        (entry) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _forest.withValues(alpha: .1),
                            child: Icon(entry.icon, color: _forest, size: 18),
                          ),
                          title: Text(
                            entry.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _ink,
                            ),
                          ),
                          subtitle: Text(
                            '${entry.subtitle} · ${_formatDate(entry.date)}',
                            style: const TextStyle(color: _muted),
                          ),
                        ),
                      )
                      .toList()
                : history
                      .asMap()
                      .entries
                      .map(
                        (entry) => ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: _forest,
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          title: Text(entry.value),
                          subtitle: Text(
                            entry.key == 0
                                ? 'Hoje'
                                : 'Há ${entry.key} dia${entry.key == 1 ? '' : 's'}',
                          ),
                        ),
                      )
                      .toList(),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed:
              onExportPdf ??
              () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exportação em PDF ainda não está disponível.'),
                ),
              ),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Exportar histórico em PDF'),
          style: FilledButton.styleFrom(
            backgroundColor: _forest,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _SyncCredentialsDialog extends StatefulWidget {
  const _SyncCredentialsDialog({required this.initialEmail});

  final String initialEmail;

  @override
  State<_SyncCredentialsDialog> createState() => _SyncCredentialsDialogState();
}

class _SyncCredentialsDialogState extends State<_SyncCredentialsDialog> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Entrar e sincronizar'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-mail'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Senha'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'action': 'recovery',
              'email': _emailController.text.trim(),
            });
          },
          child: const Text('Esqueci minha senha'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final email = _emailController.text.trim();
            final password = _passwordController.text;
            if (email.isEmpty || password.isEmpty) return;
            Navigator.pop(context, {'email': email, 'password': password});
          },
          child: const Text('Entrar'),
        ),
      ],
    );
  }
}

class _PasswordRecoveryDialog extends StatefulWidget {
  const _PasswordRecoveryDialog({
    required this.initialEmail,
    required this.onRequestToken,
    required this.onConfirm,
  });

  final String initialEmail;
  final Future<String> Function({required String email}) onRequestToken;
  final Future<String> Function({
    required String token,
    required String newPassword,
  })
  onConfirm;

  @override
  State<_PasswordRecoveryDialog> createState() =>
      _PasswordRecoveryDialogState();
}

class _PasswordRecoveryDialogState extends State<_PasswordRecoveryDialog> {
  late final TextEditingController _emailController;
  late final TextEditingController _tokenController;
  late final TextEditingController _passwordController;
  bool _tokenRequested = false;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    _tokenController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _requestToken() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final message = await widget.onRequestToken(email: email);
      if (!mounted) return;
      setState(() {
        _tokenRequested = true;
        _message = message;
      });
    } on SyncGatewayException catch (error) {
      if (!mounted) return;
      setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final token = _tokenController.text.trim();
    final password = _passwordController.text;
    if (token.isEmpty || password.length < 8) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final message = await widget.onConfirm(
        token: token,
        newPassword: password,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Senha atualizada'),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    } on SyncGatewayException catch (error) {
      if (!mounted) return;
      setState(() => _message = error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Recuperar senha'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            if (_tokenRequested) ...[
              const SizedBox(height: 12),
              const Text('Confira o e-mail e informe o token recebido.'),
              const SizedBox(height: 12),
              TextField(
                controller: _tokenController,
                decoration: const InputDecoration(labelText: 'Token'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nova senha (mínimo 8 caracteres)',
                ),
              ),
            ],
            if (_message != null) ...[
              const SizedBox(height: 12),
              Text(_message!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _busy
              ? null
              : (_tokenRequested ? _confirm : _requestToken),
          child: Text(
            _busy
                ? 'Aguarde...'
                : (_tokenRequested ? 'Atualizar senha' : 'Enviar token'),
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    this.profile,
    this.petCount = 2,
    this.onOpenSubscription,
    this.onEditAddress,
    this.pendingSyncCount = 0,
    this.onEdit,
    this.onSaveBackup,
    this.onShareBackup,
    this.onRestoreBackup,
    this.onSync,
    this.onLogout,
    this.syncing = false,
  });

  final LocalProfile? profile;
  final int petCount;
  final VoidCallback? onOpenSubscription;
  final VoidCallback? onEditAddress;
  final int pendingSyncCount;
  final VoidCallback? onEdit;
  final VoidCallback? onSaveBackup;
  final VoidCallback? onShareBackup;
  final VoidCallback? onRestoreBackup;
  final VoidCallback? onSync;
  final VoidCallback? onLogout;
  final bool syncing;

  @override
  Widget build(BuildContext context) {
    final currentProfile = profile ?? LocalProfile.defaultProfile();
    final initials = currentProfile.name.trim().isEmpty
        ? 'A'
        : currentProfile.name.trim().substring(0, 1).toUpperCase();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        Text(
          'Perfil',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _mango,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: _forestDark,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentProfile.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          currentProfile.email,
                          style: const TextStyle(color: _muted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_outlined, color: _muted),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          color: _forest,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: _mango),
                    const SizedBox(width: 8),
                    Text(
                      currentProfile.productPlan.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currentProfile.isFreeOffline
                      ? 'Você está cuidando de $petCount pet. No Family, você poderá cadastrar múltiplos pets e sincronizar seus dados.'
                      : 'Sua conta está conectada ao AuMiau Family. Seus dados podem ser sincronizados com segurança.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed:
                      onOpenSubscription ?? () => _showComingSoon(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: _mango,
                    foregroundColor: _forestDark,
                  ),
                  child: Text(
                    currentProfile.isFreeOffline
                        ? 'Conhecer Plano Família'
                        : 'Gerenciar assinatura',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (onEditAddress != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: _forest),
                      const SizedBox(width: 10),
                      Text(
                        'Endereço e localização',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: _ink,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cadastre o endereço manualmente. O GPS é opcional e só será usado com seu consentimento.',
                    style: TextStyle(color: _muted, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onEditAddress,
                    icon: const Icon(Icons.edit_location_alt_outlined),
                    label: const Text('Cadastrar ou editar endereço'),
                  ),
                ],
              ),
            ),
          ),
        if (onEditAddress != null) const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.backup_outlined, color: _forest),
                    const SizedBox(width: 10),
                    Text(
                      'Dados e backup',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Seus dados continuam disponíveis offline e podem ser sincronizados com segurança.',
                  style: TextStyle(color: _muted, height: 1.4),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: onSaveBackup ?? () => _showComingSoon(context),
                      icon: const Icon(Icons.save_alt_outlined),
                      label: const Text('Salvar backup'),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          onShareBackup ?? () => _showComingSoon(context),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Compartilhar'),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          onRestoreBackup ?? () => _showComingSoon(context),
                      icon: const Icon(Icons.restore_outlined),
                      label: const Text('Restaurar'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: syncing ? null : onSync,
                    icon: Icon(
                      syncing ? Icons.sync : Icons.cloud_sync_outlined,
                    ),
                    label: Text(
                      syncing ? 'Sincronizando...' : 'Entrar e sincronizar',
                    ),
                  ),
                ),
                if (onLogout != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: syncing ? null : onLogout,
                      icon: const Icon(Icons.logout_outlined),
                      label: const Text('Sair da conta'),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      size: 18,
                      color: _muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pendingSyncCount == 0
                            ? 'Nenhuma alteração pendente. Sincronização com a nuvem disponível.'
                            : '$pendingSyncCount alteração${pendingSyncCount == 1 ? '' : 'ões'} aguardando sincronização.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: _muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: const [
              _SettingsTile(
                icon: Icons.notifications_none,
                title: 'Notificações',
                subtitle: 'Lembretes locais e preferências',
              ),
              _SettingsTile(
                icon: Icons.security_outlined,
                title: 'Privacidade e dados',
                subtitle: 'Controle e exclusão da sua conta',
              ),
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Ajuda',
                subtitle: 'Fale com o suporte AuMiau',
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Assinaturas serão conectadas depois da validação do MVP.',
          ),
        ),
      );
}

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.reminder,
    required this.today,
    required this.onComplete,
    this.onEdit,
    this.onDelete,
    this.compact = false,
  });

  final Reminder reminder;
  final DateTime today;
  final VoidCallback onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final late =
        reminder.dueDate.isBefore(today) && !_sameDay(reminder.dueDate, today);
    final color = late ? _danger : _forest;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? 13 : 15),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (late ? _danger : _mango).withValues(alpha: .18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(reminder.icon, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${reminder.petName} · ${late
                        ? 'atrasado'
                        : _sameDay(reminder.dueDate, today)
                        ? 'hoje'
                        : _formatDate(reminder.dueDate)}',
                    style: TextStyle(
                      color: late ? _danger : _muted,
                      fontSize: 13,
                      fontWeight: late ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (!compact)
              FilledButton(
                onPressed: reminder.done ? null : onComplete,
                style: FilledButton.styleFrom(
                  backgroundColor: _mango,
                  foregroundColor: _forestDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                child: Text(reminder.done ? 'Feito' : 'Feito ✓'),
              ),
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                tooltip: 'Opções do lembrete',
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Excluir'),
                    ),
                ],
              ),
            if (compact) Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.today});
  final DateTime today;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
    decoration: BoxDecoration(
      color: _forest,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(text: 'Au'),
                    TextSpan(
                      text: 'Miau',
                      style: TextStyle(color: _mango),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _formatLongDate(today),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _mango.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _mango.withValues(alpha: .45)),
          ),
          child: const Text(
            'PLANO GRATUITO',
            style: TextStyle(
              color: _mango,
              fontWeight: FontWeight.w800,
              fontSize: 10,
            ),
          ),
        ),
      ],
    ),
  );
}

class _PetMiniCard extends StatelessWidget {
  const _PetMiniCard({required this.pet});
  final Pet pet;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Text(pet.emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                Text(
                  '${pet.weight.toStringAsFixed(1)} kg',
                  style: const TextStyle(fontSize: 12, color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _PetCard extends StatelessWidget {
  const _PetCard({
    required this.pet,
    this.onOpenVaccineWallet,
    this.onEdit,
    this.onDelete,
  });
  final Pet pet;
  final void Function(Pet pet)? onOpenVaccineWallet;
  final void Function(Pet pet)? onEdit;
  final void Function(Pet pet)? onDelete;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 29,
                  backgroundColor: _mango.withValues(alpha: .3),
                  child: Text(pet.emoji, style: const TextStyle(fontSize: 31)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${pet.species} · ${pet.breed}',
                        style: const TextStyle(color: _muted),
                      ),
                      if (pet.allergies.isNotEmpty)
                        Text(
                          'Atenção: ${pet.allergies}',
                          style: const TextStyle(
                            color: _danger,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
                if (onEdit != null || onDelete != null)
                  PopupMenuButton<String>(
                    tooltip: 'Opções do pet',
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call(pet);
                      if (value == 'delete') onDelete?.call(pet);
                    },
                    itemBuilder: (context) => [
                      if (onEdit != null)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Editar nome'),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Excluir pet'),
                        ),
                    ],
                  )
                else
                  const Icon(Icons.chevron_right, color: _muted),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _PetMetric(
                    label: 'Peso atual',
                    value: pet.weight > 0
                        ? '${pet.weight.toStringAsFixed(1)} kg'
                        : 'A informar',
                    icon: Icons.monitor_weight_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PetMetric(
                    label: 'Vacinas',
                    value: pet.vaccines.isEmpty
                        ? 'Sem registro'
                        : '${pet.vaccines.length} registrada${pet.vaccines.length == 1 ? '' : 's'}',
                    icon: Icons.vaccines_outlined,
                  ),
                ),
              ],
            ),
            if (onOpenVaccineWallet != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => onOpenVaccineWallet!(pet),
                  icon: const Icon(Icons.vaccines_outlined, size: 18),
                  label: const Text('Abrir carteira de vacinação'),
                  style: TextButton.styleFrom(foregroundColor: _forest),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VaccineCard extends StatelessWidget {
  const _VaccineCard({
    required this.record,
    required this.today,
    this.onDelete,
  });

  final VaccineRecord record;
  final DateTime today;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final nextDose = record.nextDoseAt;
    final days = nextDose?.difference(today).inDays;
    final statusColor = days == null
        ? _muted
        : days < 0
        ? _danger
        : days <= 30
        ? const Color(0xFFE8A13C)
        : _success;
    final status = days == null
        ? 'Sem próxima dose'
        : days < 0
        ? 'Atrasada'
        : days <= 30
        ? 'Vence em breve'
        : 'Em dia';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _forest.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.vaccines_outlined, color: _forest),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    record.clinicName?.isNotEmpty == true
                        ? record.clinicName!
                        : 'Aplicada em ${_formatDate(record.appliedAt)}',
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                  if (nextDose != null)
                    Text(
                      'Próxima dose: ${_formatDate(nextDose)}',
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            if (onDelete != null)
              PopupMenuButton<String>(
                tooltip: 'Opções da vacina',
                onSelected: (value) {
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: _forest, size: 19),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: _muted, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              IconButton(
                tooltip: 'Remover data',
                onPressed: onClear,
                icon: const Icon(Icons.close, size: 18, color: _muted),
              )
            else
              const Icon(Icons.chevron_right, color: _muted),
          ],
        ),
      ),
    );
  }
}

class _PetMetric extends StatelessWidget {
  const _PetMetric({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: _paper,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: _forest),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: _muted)),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800, color: _ink),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });
  final String title;
  final String action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
      ),
      TextButton(
        onPressed: onTap,
        child: Text(
          action,
          style: const TextStyle(color: _forest, fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, color: _success, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _forest.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _forest),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _forest,
                ),
              ),
              const SizedBox(height: 4),
              Text(text, style: const TextStyle(color: _muted, height: 1.4)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: _forest),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w700, color: _ink),
    ),
    subtitle: Text(subtitle, style: const TextStyle(color: _muted)),
    trailing: const Icon(Icons.chevron_right, color: _muted),
  );
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 42,
      height: 4,
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: _line,
        borderRadius: BorderRadius.circular(9),
      ),
    ),
  );
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.pets});
  final List<Pet> pets;
  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _ChartPainter(),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: pets
          .map(
            (pet) => Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  pet.weight > 0 ? '${pet.weight.toStringAsFixed(1)} kg' : '—',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _forest,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 64,
                  height: pet.weight > 0 ? (pet.weight > 10 ? 105 : 44) : 12,
                  decoration: BoxDecoration(
                    color: pet.weight > 10 ? _forest : _mango,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  pet.name,
                  style: const TextStyle(
                    color: _muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    ),
  );
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _line
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

String _formatLongDate(DateTime date) {
  const weekdays = [
    'segunda-feira',
    'terça-feira',
    'quarta-feira',
    'quinta-feira',
    'sexta-feira',
    'sábado',
    'domingo',
  ];
  return '${weekdays[date.weekday - 1]}, ${date.day} de ${_monthName(date.month)}';
}

String _monthName(int month) => const [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
][month - 1];
