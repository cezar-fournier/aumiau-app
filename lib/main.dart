import 'dart:async';

import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'data/app_database.dart';
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
    this.plan = 'Gratuito',
  });

  String name;
  String email;
  String plan;

  factory LocalProfile.defaultProfile() =>
      LocalProfile(name: 'Cezar Fournier', email: 'cezar@exemplo.com');
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
    if (_pets.isEmpty) return;
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

  Future<Map<String, String>?> _askSyncCredentials() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _SyncCredentialsDialog(initialEmail: _profile.email),
    );
    if (result?['action'] == 'recovery') {
      await _showPasswordRecovery(result?['email'] ?? _profile.email);
      return null;
    }
    return result;
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

  Future<void> _restoreSession() async {
    final session = await _sessionStore.read();
    if (!mounted || session == null) return;
    setState(() => _accessToken = session.accessToken);
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
    Map<String, String>? credentials;
    if (storedSession == null) {
      credentials = await _askSyncCredentials();
      if (credentials == null) return;
    }
    if (!mounted) return;
    setState(() => _syncing = true);
    try {
      final email = storedSession?.email ?? credentials!['email']!;
      late StoredSession activeSession;
      if (storedSession != null) {
        _accessToken = storedSession.accessToken;
        activeSession = storedSession;
      } else {
        final session = await _syncGateway.signIn(
          email: email,
          password: credentials!['password']!,
        );
        _accessToken = session.accessToken;
        activeSession = StoredSession(
          email: email,
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );
        await _sessionStore.save(
          email: email,
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );
      }
      final acknowledgement = await _synchronizeWithRefresh(activeSession);
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
    setState(() {});
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

    final pages = [
      TodayPage(
        today: _today,
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

class TodayPage extends StatelessWidget {
  const TodayPage({
    super.key,
    required this.today,
    required this.pets,
    required this.reminders,
    required this.onComplete,
    required this.onAddReminder,
    required this.onEditReminder,
    required this.onDeleteReminder,
  });

  final DateTime today;
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
          'Oi, Cezar! 👋',
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
                      'Plano gratuito',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Você já está cuidando de $petCount pets. Desbloqueie recursos avançados do Plano Família.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => _showComingSoon(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: _mango,
                    foregroundColor: _forestDark,
                  ),
                  child: const Text('Conhecer Plano Família'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
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
