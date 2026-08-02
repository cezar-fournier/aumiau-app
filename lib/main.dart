import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config/app_config.dart';
import 'data/app_database.dart';
import 'domain/partner_directory.dart';
import 'domain/brazil_documents.dart';
import 'domain/partner_profile.dart';
import 'domain/product_plan.dart';
import 'services/backup_service.dart';
import 'services/notification_service.dart';
import 'services/pdf_service.dart';
import 'services/play_billing_service.dart';
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

enum _AppMode { client, partner }

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
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
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
    this.birthDate,
    this.sex = '',
    this.color = '',
    this.characteristics = '',
    this.hasPedigree = false,
    this.pedigreeNumber,
    this.microchip,
    this.size = '',
    this.reproductiveStatus = '',
    this.bodyConditionScore,
    this.clinicReference = '',
    this.veterinarianReference = '',
    this.documentNotes = '',
    this.photoData,
    List<VaccineRecord> vaccines = const [],
    List<WeightRecord> weights = const [],
    List<PreventiveRecord> preventives = const [],
    List<MedicationPlan> medications = const [],
  }) : vaccines = List<VaccineRecord>.of(vaccines),
       weights = List<WeightRecord>.of(weights),
       preventives = List<PreventiveRecord>.of(preventives),
       medications = List<MedicationPlan>.of(medications);

  final int? id;
  String name;
  final String species;
  final String breed;
  final String emoji;
  double weight;
  String allergies;
  final DateTime? birthDate;
  final String sex;
  final String color;
  final String characteristics;
  final bool hasPedigree;
  final String? pedigreeNumber;
  final String? microchip;
  final String size;
  final String reproductiveStatus;
  final double? bodyConditionScore;
  final String clinicReference;
  final String veterinarianReference;
  final String documentNotes;
  final String? photoData;
  final List<VaccineRecord> vaccines;
  final List<WeightRecord> weights;
  final List<PreventiveRecord> preventives;
  final List<MedicationPlan> medications;
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

class PreventiveRecord {
  PreventiveRecord({
    this.id,
    required this.petId,
    required this.category,
    required this.product,
    required this.appliedAt,
    this.nextDueAt,
    this.provider,
    this.notes,
  });

  final int? id;
  final int petId;
  final String category;
  final String product;
  final DateTime appliedAt;
  final DateTime? nextDueAt;
  final String? provider;
  final String? notes;
}

class MedicationPlan {
  MedicationPlan({
    this.id,
    required this.petId,
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.startAt,
    this.endAt,
    this.active = true,
    this.lastTakenAt,
    this.notes,
  });

  final int? id;
  final int petId;
  final String name;
  final String dosage;
  final String schedule;
  final DateTime startAt;
  final DateTime? endAt;
  final bool active;
  DateTime? lastTakenAt;
  final String? notes;
}

class FamilyInvitation {
  FamilyInvitation({
    this.id,
    required this.petId,
    required this.email,
    required this.role,
    required this.permissions,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
  });

  final int? id;
  final int petId;
  final String email;
  final String role;
  final String permissions;
  final String status;
  final DateTime expiresAt;
  final DateTime createdAt;
}

class Appointment {
  Appointment({
    this.id,
    required this.petId,
    this.partnerId,
    this.petName,
    this.clientName,
    this.clientEmail,
    required this.partnerName,
    required this.service,
    required this.scheduledAt,
    required this.status,
    this.notes,
    this.checkInAt,
    required this.createdAt,
  });

  final int? id;
  final int petId;
  final int? partnerId;
  final String? petName;
  final String? clientName;
  final String? clientEmail;
  final String partnerName;
  final String service;
  final DateTime scheduledAt;
  String status;
  final String? notes;
  DateTime? checkInAt;
  final DateTime createdAt;
}

String _appointmentStatusLabel(String status) => switch (status) {
  'requested' => 'Solicitado',
  'confirmed' => 'Confirmado',
  'checked_in' || 'check_in' => 'Check-in realizado',
  'completed' => 'Concluído',
  'cancelled' => 'Cancelado',
  _ => 'Em atualização',
};

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
    this.familyValidUntil,
  });

  String name;
  String email;
  String plan;
  bool familyEnabled;
  DateTime? familyValidUntil;

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
            icon: Icon(Icons.location_searching_outlined),
            selectedIcon: Icon(Icons.location_searching),
            label: 'Atendimento',
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
  // Temporariamente desativado até a conta Google Play Console estar ativa.
  // O código permanece preparado para reativação controlada posteriormente.
  static const bool _googlePlayBillingEnabled = false;
  int _selectedIndex = 0;
  late AppDatabase _database;
  String? _databaseAccountEmail;
  late final DateTime _today;
  List<Pet> _pets = [];
  List<Reminder> _reminders = [];
  List<TimelineEntry> _timeline = [];
  List<FamilyInvitation> _familyInvitations = [];
  List<Appointment> _appointments = [];
  List<PrivateVeterinaryContact> _veterinaryContacts = [];
  LocalProfile _profile = LocalProfile.defaultProfile();
  int _pendingSyncCount = 0;
  late final HttpSyncGateway _syncGateway;
  late final PlayBillingService _playBilling;
  late final SessionStore _sessionStore;
  String? _accessToken;
  bool _syncing = false;
  bool _loading = true;
  String? _loadError;
  bool _updateNoticeShown = false;
  bool _showAuthGate = true;
  bool _showProfileChooser = false;
  _AppMode _activeMode = _AppMode.client;
  bool _partnerRegistrationPending = false;
  String _partnerVerificationStatus = 'not_submitted';
  String _partnerProfileStatus = 'pending';
  _AuthScreen _authScreen = _AuthScreen.welcome;
  bool _authBusy = false;
  String? _pendingVerificationEmail;
  String? _pendingRegistrationName;

  @override
  void initState() {
    super.initState();
    _database = widget.database ?? AppDatabase();
    _syncGateway = HttpSyncGateway(baseUri: AppConfig.apiBaseUri);
    _playBilling = PlayBillingService();
    if (_googlePlayBillingEnabled) {
      unawaited(
        _playBilling.initialize(
          verifier: _verifyGooglePlayPurchase,
          onMessage: _showProductMessage,
        ),
      );
    }
    _sessionStore = SessionStore();
    _today = DateTime.now();
    unawaited(_initializeApp());
    if (widget.enableUpdateChecks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdates());
    }
  }

  @override
  void dispose() {
    if (_googlePlayBillingEnabled) unawaited(_playBilling.dispose());
    if (widget.database == null) unawaited(_database.close());
    super.dispose();
  }

  Future<void> _initializeApp() async {
    if (widget.database == null) {
      final session = await _sessionStore.read();
      if (session != null) {
        await _switchDatabaseForAccount(session.email);
      }
    }
    await _loadData();
    final draft = await _sessionStore.readPartnerDraft(_draftOwner);
    if (draft != null) _partnerRegistrationPending = true;
    if (!mounted) return;
    await _restoreSession();
  }

  String get _draftOwner => _databaseAccountEmail ?? 'offline';

  Future<void> _switchDatabaseForAccount(String? email) async {
    if (widget.database != null) return;
    final normalized = email?.trim().toLowerCase();
    final target = normalized == null || normalized.isEmpty ? null : normalized;
    if (_databaseAccountEmail == target) return;
    final previous = _database;
    _database = target == null ? AppDatabase() : AppDatabase.forAccount(target);
    _databaseAccountEmail = target;
    await previous.close();
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
      final databasePreventives = await _database.loadPreventiveRecords();
      final databaseMedications = await _database.loadMedicationPlans();
      final databaseInvitations = await _database.loadFamilyInvitations();
      final databaseAppointments = await _database.loadAppointments();
      final databaseVeterinaryContacts = await _database
          .loadVeterinaryContacts();
      final databaseWeights = await _database.loadWeights();
      final databaseReminders = await _database.loadReminders();
      final databaseProfile = await _database.loadProfile();
      final pendingSyncOperations = await _database.loadPendingSyncOperations();
      final vaccinesByPet = <int, List<VaccineRecord>>{};
      final weightsByPet = <int, List<WeightRecord>>{};
      final preventivesByPet = <int, List<PreventiveRecord>>{};
      final medicationsByPet = <int, List<MedicationPlan>>{};

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

      for (final record in databasePreventives) {
        preventivesByPet
            .putIfAbsent(record.petId, () => [])
            .add(
              PreventiveRecord(
                id: record.id,
                petId: record.petId,
                category: record.category,
                product: record.product,
                appliedAt: record.appliedAt,
                nextDueAt: record.nextDueAt,
                provider: record.provider,
                notes: record.notes,
              ),
            );
      }

      for (final medication in databaseMedications) {
        medicationsByPet
            .putIfAbsent(medication.petId, () => [])
            .add(
              MedicationPlan(
                id: medication.id,
                petId: medication.petId,
                name: medication.name,
                dosage: medication.dosage,
                schedule: medication.schedule,
                startAt: medication.startAt,
                endAt: medication.endAt,
                active: medication.active,
                lastTakenAt: medication.lastTakenAt,
                notes: medication.notes,
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
      for (final appointment in databaseAppointments) {
        timeline.add(
          TimelineEntry(
            title: 'Atendimento: ${appointment.service}',
            subtitle: appointment.partnerName,
            date: appointment.scheduledAt,
            icon: Icons.event_available_outlined,
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
      for (final record in databasePreventives) {
        timeline.add(
          TimelineEntry(
            title: '${record.category}: ${record.product}',
            subtitle: petNameById[record.petId] ?? 'Pet',
            date: record.appliedAt,
            icon: Icons.health_and_safety_outlined,
          ),
        );
      }
      for (final medication in databaseMedications) {
        timeline.add(
          TimelineEntry(
            title: 'Plano de medicamento: ${medication.name}',
            subtitle: petNameById[medication.petId] ?? 'Pet',
            date: medication.startAt,
            icon: Icons.medication_outlined,
          ),
        );
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
                familyEnabled:
                    databaseProfile.plan == ProductCatalog.family.code &&
                    (databaseProfile.familyValidUntil == null ||
                        databaseProfile.familyValidUntil!.isAfter(
                          DateTime.now(),
                        )),
                familyValidUntil: databaseProfile.familyValidUntil,
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
                birthDate: pet.birthDate,
                sex: pet.sex,
                color: pet.color,
                characteristics: pet.characteristics,
                hasPedigree: pet.hasPedigree,
                pedigreeNumber: pet.pedigreeNumber,
                microchip: pet.microchip,
                size: pet.size,
                reproductiveStatus: pet.reproductiveStatus,
                bodyConditionScore: pet.bodyConditionScore,
                clinicReference: pet.clinicReference,
                veterinarianReference: pet.veterinarianReference,
                documentNotes: pet.documentNotes,
                photoData: pet.photoData,
                vaccines: vaccinesByPet[pet.id] ?? [],
                weights: weightsByPet[pet.id] ?? [],
                preventives: preventivesByPet[pet.id] ?? [],
                medications: medicationsByPet[pet.id] ?? [],
              ),
            )
            .toList();
        _timeline = timeline;
        _familyInvitations = databaseInvitations
            .map(
              (invitation) => FamilyInvitation(
                id: invitation.id,
                petId: invitation.petId,
                email: invitation.email,
                role: invitation.role,
                permissions: invitation.permissions,
                status: invitation.status,
                expiresAt: invitation.expiresAt,
                createdAt: invitation.createdAt,
              ),
            )
            .toList();
        _appointments = databaseAppointments
            .map(
              (appointment) => Appointment(
                id: appointment.id,
                petId: appointment.petId,
                partnerName: appointment.partnerName,
                service: appointment.service,
                scheduledAt: appointment.scheduledAt,
                status: appointment.status,
                notes: appointment.notes,
                createdAt: appointment.createdAt,
              ),
            )
            .toList();
        _veterinaryContacts = databaseVeterinaryContacts
            .map(
              (contact) => PrivateVeterinaryContact(
                id: contact.id,
                name: contact.name,
                kind: contact.kind,
                specialty: contact.specialty,
                phone: contact.phone,
                whatsapp: contact.whatsapp,
                address: contact.address,
                city: contact.city,
                state: contact.state,
                notes: contact.notes,
                latitude: contact.latitude,
                longitude: contact.longitude,
              ),
            )
            .toList();
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
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.of(dialogContext).pop(false);
                },
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
    await WidgetsBinding.instance.endOfFrame;
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
    final breedController = TextEditingController();
    final colorController = TextEditingController();
    final weightController = TextEditingController();
    final characteristicsController = TextEditingController();
    final pedigreeController = TextEditingController();
    final microchipController = TextEditingController();
    final allergiesController = TextEditingController();
    final bodyConditionController = TextEditingController();
    final clinicReferenceController = TextEditingController();
    final veterinarianReferenceController = TextEditingController();
    final documentNotesController = TextEditingController();
    var species = 'Cão';
    var sex = '';
    var size = '';
    var reproductiveStatus = '';
    String? photoData;
    DateTime? birthDate;
    var hasPedigree = false;
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Cadastro completo do pet'),
            content: SingleChildScrollView(
              // O rótulo flutuante do primeiro campo ultrapassa ligeiramente
              // a borda superior do TextField. O respiro evita que o viewport
              // do diálogo, especialmente com o teclado aberto, o corte.
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Nome do pet *',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: species,
                    decoration: const InputDecoration(labelText: 'Espécie *'),
                    items: const [
                      DropdownMenuItem(value: 'Cão', child: Text('🐶 Cão')),
                      DropdownMenuItem(value: 'Gata', child: Text('🐱 Gato')),
                      DropdownMenuItem(value: 'Outro', child: Text('🐾 Outro')),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => species = value!),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final selected = await showDatePicker(
                        context: context,
                        firstDate: DateTime(1990),
                        lastDate: DateTime.now(),
                        initialDate: birthDate ?? DateTime.now(),
                      );
                      if (selected != null) {
                        setDialogState(() => birthDate = selected);
                      }
                    },
                    icon: const Icon(Icons.cake_outlined),
                    label: Text(
                      birthDate == null
                          ? 'Data de nascimento'
                          : 'Nascimento: ${_formatFullDate(birthDate!)}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: sex.isEmpty ? null : sex,
                    decoration: const InputDecoration(labelText: 'Sexo'),
                    items: const [
                      DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                      DropdownMenuItem(value: 'Fêmea', child: Text('Fêmea')),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => sex = value ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: breedController,
                    decoration: const InputDecoration(labelText: 'Raça'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: colorController,
                    decoration: const InputDecoration(labelText: 'Cor'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Peso atual (kg)',
                    ),
                  ),
                  if (_profile.isFamily) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await FilePicker.pickFiles(
                            type: FileType.image,
                            withData: true,
                          );
                          final bytes = result?.files.single.bytes;
                          if (bytes == null || bytes.length > 2 * 1024 * 1024) {
                            if (bytes != null && context.mounted) {
                              _showProductMessage(
                                'A foto deve ter no máximo 2 MB.',
                              );
                            }
                            return;
                          }
                          setDialogState(() => photoData = base64Encode(bytes));
                        },
                        icon: const Icon(Icons.add_a_photo_outlined),
                        label: Text(
                          photoData == null ? 'Adicionar foto' : 'Trocar foto',
                        ),
                      ),
                    ),
                    if (photoData != null) ...[
                      const SizedBox(height: 8),
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: MemoryImage(base64Decode(photoData!)),
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: size.isEmpty ? null : size,
                      decoration: const InputDecoration(labelText: 'Porte'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Pequeno',
                          child: Text('Pequeno'),
                        ),
                        DropdownMenuItem(value: 'Médio', child: Text('Médio')),
                        DropdownMenuItem(
                          value: 'Grande',
                          child: Text('Grande'),
                        ),
                      ],
                      onChanged: (value) =>
                          setDialogState(() => size = value ?? ''),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: reproductiveStatus.isEmpty
                          ? null
                          : reproductiveStatus,
                      decoration: const InputDecoration(
                        labelText: 'Condição reprodutiva',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Não informado',
                          child: Text('Não informado'),
                        ),
                        DropdownMenuItem(
                          value: 'Inteiro(a)',
                          child: Text('Inteiro(a)'),
                        ),
                        DropdownMenuItem(
                          value: 'Castrado(a)',
                          child: Text('Castrado(a)'),
                        ),
                      ],
                      onChanged: (value) => setDialogState(
                        () => reproductiveStatus = value ?? '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: bodyConditionController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Escore corporal (1 a 9)',
                        hintText: 'Avaliação feita pelo tutor ou veterinário',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: characteristicsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Características e observações',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Possui pedigree'),
                      value: hasPedigree,
                      onChanged: (value) =>
                          setDialogState(() => hasPedigree = value),
                    ),
                    if (hasPedigree)
                      TextField(
                        controller: pedigreeController,
                        decoration: const InputDecoration(
                          labelText: 'Número do pedigree',
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: microchipController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Microchip (opcional)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: allergiesController,
                      decoration: const InputDecoration(
                        labelText: 'Alergias e cuidados especiais',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: clinicReferenceController,
                      decoration: const InputDecoration(
                        labelText: 'Clínica de referência',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: veterinarianReferenceController,
                      decoration: const InputDecoration(
                        labelText: 'Veterinário de referência',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: documentNotesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Documentos e observações',
                        hintText: 'Ex.: carteira física, registro, laudo...',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'No Family, você também pode registrar características, pedigree, microchip e cuidados especiais.',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
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
                  if (name.isEmpty) return;
                  final breed = breedController.text.trim().isEmpty
                      ? 'A informar'
                      : breedController.text.trim();
                  final weight =
                      double.tryParse(
                        weightController.text.trim().replaceAll(',', '.'),
                      ) ??
                      0;
                  final id = await _database.addPet(
                    name: name,
                    species: species,
                    breed: breed,
                    emoji: species == 'Cão'
                        ? '🐶'
                        : species == 'Gata'
                        ? '🐱'
                        : '🐾',
                    birthDate: birthDate,
                    sex: sex,
                    color: colorController.text.trim(),
                    characteristics: characteristicsController.text.trim(),
                    hasPedigree: hasPedigree,
                    pedigreeNumber: hasPedigree
                        ? pedigreeController.text.trim()
                        : null,
                    microchip: microchipController.text.trim().isEmpty
                        ? null
                        : microchipController.text.trim(),
                    size: size,
                    reproductiveStatus: reproductiveStatus,
                    bodyConditionScore: double.tryParse(
                      bodyConditionController.text.trim().replaceAll(',', '.'),
                    ),
                    clinicReference: clinicReferenceController.text.trim(),
                    veterinarianReference: veterinarianReferenceController.text
                        .trim(),
                    documentNotes: documentNotesController.text.trim(),
                    photoData: photoData,
                    weight: weight,
                    allergies: allergiesController.text.trim(),
                  );
                  if (!mounted) return;
                  setState(
                    () => _pets.add(
                      Pet(
                        id: id,
                        name: name,
                        species: species,
                        breed: breed,
                        emoji: species == 'Cão'
                            ? '🐶'
                            : species == 'Gata'
                            ? '🐱'
                            : '🐾',
                        weight: weight,
                        birthDate: birthDate,
                        sex: sex,
                        color: colorController.text.trim(),
                        characteristics: characteristicsController.text.trim(),
                        hasPedigree: hasPedigree,
                        pedigreeNumber: hasPedigree
                            ? pedigreeController.text.trim()
                            : null,
                        microchip: microchipController.text.trim().isEmpty
                            ? null
                            : microchipController.text.trim(),
                        size: size,
                        reproductiveStatus: reproductiveStatus,
                        bodyConditionScore: double.tryParse(
                          bodyConditionController.text.trim().replaceAll(
                            ',',
                            '.',
                          ),
                        ),
                        clinicReference: clinicReferenceController.text.trim(),
                        veterinarianReference: veterinarianReferenceController
                            .text
                            .trim(),
                        documentNotes: documentNotesController.text.trim(),
                        photoData: photoData,
                        allergies: allergiesController.text.trim(),
                      ),
                    ),
                  );
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                },
                child: const Text('Salvar cadastro'),
              ),
            ],
          ),
        ),
      );
    } finally {
      await WidgetsBinding.instance.endOfFrame;
      for (final controller in [
        nameController,
        breedController,
        colorController,
        weightController,
        characteristicsController,
        pedigreeController,
        microchipController,
        allergiesController,
        bodyConditionController,
        clinicReferenceController,
        veterinarianReferenceController,
        documentNotesController,
      ]) {
        controller.dispose();
      }
    }
  }

  void _showProductMessage(String message) {
    if (!mounted) return;
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
          final preventives = [...pet.preventives]
            ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
          final medications = [...pet.medications]
            ..sort((a, b) => b.startAt.compareTo(a.startAt));
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
                  if (preventives.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Prevenção',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...preventives.map(
                      (record) => Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.health_and_safety_outlined,
                            color: _forest,
                          ),
                          title: Text('${record.category}: ${record.product}'),
                          subtitle: Text(
                            'Aplicado em ${_formatDate(record.appliedAt)}${record.nextDueAt == null ? '' : ' · Próximo: ${_formatDate(record.nextDueAt!)}'}',
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (medications.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Medicamentos',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...medications.map(
                      (medication) => Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.medication_outlined,
                            color: _forest,
                          ),
                          title: Text(medication.name),
                          subtitle: Text(
                            '${medication.dosage} · ${medication.schedule}${medication.lastTakenAt == null ? '' : '\nÚltima dose: ${_formatDate(medication.lastTakenAt!)}'}',
                          ),
                          isThreeLine: medication.lastTakenAt != null,
                          trailing: IconButton(
                            tooltip: 'Registrar dose',
                            onPressed: medication.id == null
                                ? null
                                : () async {
                                    await _database.markMedicationTaken(
                                      medication.id!,
                                    );
                                    medication.lastTakenAt = DateTime.now();
                                    if (mounted) setState(() {});
                                    setModalState(() {});
                                  },
                            icon: const Icon(Icons.check_circle_outline),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            _openAddPreventive(pet, () => setModalState(() {})),
                        icon: const Icon(Icons.health_and_safety_outlined),
                        label: const Text('Prevenção'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _openAddMedication(pet, () => setModalState(() {})),
                        icon: const Icon(Icons.medication_outlined),
                        label: const Text('Medicamento'),
                      ),
                    ],
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
    await WidgetsBinding.instance.endOfFrame;
    nameController.dispose();
    clinicController.dispose();
  }

  Future<void> _openAddPreventive(Pet pet, VoidCallback onSaved) async {
    final categoryController = TextEditingController();
    final productController = TextEditingController();
    final providerController = TextEditingController();
    final notesController = TextEditingController();
    var appliedAt = _today;
    DateTime? nextDueAt = _today.add(const Duration(days: 90));

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Nova prevenção · ${pet.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: categoryController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de prevenção',
                    hintText: 'Ex.: Vermífugo ou antipulgas',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: productController,
                  decoration: const InputDecoration(labelText: 'Produto'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: providerController,
                  decoration: const InputDecoration(
                    labelText: 'Clínica ou veterinário (opcional)',
                  ),
                ),
                const SizedBox(height: 12),
                _DatePickerTile(
                  label: 'Aplicado em',
                  value: _formatDate(appliedAt),
                  onTap: () async {
                    final value = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: appliedAt,
                    );
                    if (value != null) setDialogState(() => appliedAt = value);
                  },
                ),
                const SizedBox(height: 8),
                _DatePickerTile(
                  label: 'Próxima aplicação',
                  value: nextDueAt == null
                      ? 'Não informada'
                      : _formatDate(nextDueAt!),
                  onTap: () async {
                    final value = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: nextDueAt ?? _today,
                    );
                    if (value != null) setDialogState(() => nextDueAt = value);
                  },
                  onClear: nextDueAt == null
                      ? null
                      : () => setDialogState(() => nextDueAt = null),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Observações',
                    alignLabelWithHint: true,
                  ),
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
                final category = categoryController.text.trim();
                final product = productController.text.trim();
                if (category.isEmpty || product.isEmpty || pet.id == null) {
                  return;
                }
                final id = await _database.addPreventive(
                  petId: pet.id!,
                  category: category,
                  product: product,
                  appliedAt: appliedAt,
                  nextDueAt: nextDueAt,
                  provider: providerController.text.trim().isEmpty
                      ? null
                      : providerController.text.trim(),
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                );
                pet.preventives.insert(
                  0,
                  PreventiveRecord(
                    id: id,
                    petId: pet.id!,
                    category: category,
                    product: product,
                    appliedAt: appliedAt,
                    nextDueAt: nextDueAt,
                    provider: providerController.text.trim().isEmpty
                        ? null
                        : providerController.text.trim(),
                    notes: notesController.text.trim().isEmpty
                        ? null
                        : notesController.text.trim(),
                  ),
                );
                _timeline.insert(
                  0,
                  TimelineEntry(
                    title: '$category: $product',
                    subtitle: pet.name,
                    date: appliedAt,
                    icon: Icons.health_and_safety_outlined,
                  ),
                );
                _timeline.sort((a, b) => b.date.compareTo(a.date));
                if (mounted) setState(() {});
                onSaved();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Salvar prevenção'),
            ),
          ],
        ),
      ),
    );
    await WidgetsBinding.instance.endOfFrame;
    for (final controller in [
      categoryController,
      productController,
      providerController,
      notesController,
    ]) {
      controller.dispose();
    }
  }

  Future<void> _openAddMedication(Pet pet, VoidCallback onSaved) async {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final scheduleController = TextEditingController();
    final notesController = TextEditingController();
    final startAt = _today;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Novo medicamento · ${pet.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Registre a orientação prescrita e confirme cada dose administrada.',
                style: TextStyle(color: _muted, height: 1.35),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Medicamento'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dose',
                  hintText: 'Ex.: 1 comprimido',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: scheduleController,
                decoration: const InputDecoration(
                  labelText: 'Horários e frequência',
                  hintText: 'Ex.: a cada 12 horas',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  alignLabelWithHint: true,
                ),
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
              final dosage = dosageController.text.trim();
              final schedule = scheduleController.text.trim();
              if (name.isEmpty ||
                  dosage.isEmpty ||
                  schedule.isEmpty ||
                  pet.id == null) {
                return;
              }
              final id = await _database.addMedicationPlan(
                petId: pet.id!,
                name: name,
                dosage: dosage,
                schedule: schedule,
                startAt: startAt,
                notes: notesController.text.trim().isEmpty
                    ? null
                    : notesController.text.trim(),
              );
              pet.medications.insert(
                0,
                MedicationPlan(
                  id: id,
                  petId: pet.id!,
                  name: name,
                  dosage: dosage,
                  schedule: schedule,
                  startAt: startAt,
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                ),
              );
              _timeline.insert(
                0,
                TimelineEntry(
                  title: 'Plano de medicamento: $name',
                  subtitle: pet.name,
                  date: startAt,
                  icon: Icons.medication_outlined,
                ),
              );
              _timeline.sort((a, b) => b.date.compareTo(a.date));
              if (mounted) setState(() {});
              onSaved();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Salvar medicamento'),
          ),
        ],
      ),
    );
    await WidgetsBinding.instance.endOfFrame;
    for (final controller in [
      nameController,
      dosageController,
      scheduleController,
      notesController,
    ]) {
      controller.dispose();
    }
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
    await WidgetsBinding.instance.endOfFrame;
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

  Future<void> _openContentLibrary() => ContentLibrarySheet.show(context);

  Future<void> _openAddVeterinaryContact() async {
    if (!_profile.isFamily) {
      _showProductMessage(
        'Cadastros privados de profissionais estão disponíveis no Family.',
      );
      return;
    }
    final nameController = TextEditingController();
    final kindController = TextEditingController(text: 'Veterinário');
    final specialtyController = TextEditingController();
    final phoneController = TextEditingController();
    final whatsappController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final notesController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cadastrar meu profissional'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Este cadastro é privado e só ficará visível para você.',
                  style: TextStyle(color: _muted, height: 1.35),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nome *'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: kindController,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  hintText: 'Veterinário ou clínica',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: specialtyController,
                decoration: const InputDecoration(labelText: 'Especialidade'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Telefone'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: whatsappController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'WhatsApp'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Endereço'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cityController,
                      decoration: const InputDecoration(labelText: 'Cidade'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 74,
                    child: TextField(
                      controller: stateController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'UF'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  alignLabelWithHint: true,
                ),
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
              if (name.length < 2) {
                _showProductMessage('Informe o nome do profissional.');
                return;
              }
              final id = await _database.addVeterinaryContact(
                name: name,
                kind: kindController.text,
                specialty: specialtyController.text,
                phone: phoneController.text,
                whatsapp: whatsappController.text,
                address: addressController.text,
                city: cityController.text,
                state: stateController.text,
                notes: notesController.text,
              );
              final contact = PrivateVeterinaryContact(
                id: id,
                name: name,
                kind: kindController.text.trim().isEmpty
                    ? 'Veterinário'
                    : kindController.text.trim(),
                specialty: specialtyController.text.trim(),
                phone: phoneController.text.trim(),
                whatsapp: whatsappController.text.trim(),
                address: addressController.text.trim(),
                city: cityController.text.trim(),
                state: stateController.text.trim().toUpperCase(),
                notes: notesController.text.trim(),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              await WidgetsBinding.instance.endOfFrame;
              if (!mounted) return;
              setState(() => _veterinaryContacts.add(contact));
              _showProductMessage('Profissional salvo somente neste aparelho.');
              unawaited(_syncPrivateVeterinaryContacts());
            },
            child: const Text('Salvar contato'),
          ),
        ],
      ),
    );
    nameController.dispose();
    kindController.dispose();
    specialtyController.dispose();
    phoneController.dispose();
    whatsappController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    notesController.dispose();
  }

  Future<void> _deleteVeterinaryContact(
    PrivateVeterinaryContact contact,
  ) async {
    if (contact.id == null) return;
    final confirmed = await _confirmAction(
      title: 'Excluir contato?',
      message: 'O cadastro privado de ${contact.name} será removido.',
    );
    if (!confirmed) return;
    await _database.deleteVeterinaryContact(contact.id!);
    if (!mounted) return;
    setState(
      () => _veterinaryContacts.removeWhere((item) => item.id == contact.id),
    );
    _showProductMessage('Contato privado removido.');
  }

  Future<List<PartnerClinic>> _loadRemotePartners({
    double? latitude,
    double? longitude,
    bool urgency = false,
    String? service,
  }) => _syncGateway.loadPartners(
    latitude: latitude,
    longitude: longitude,
    urgency: urgency,
    service: service,
  );

  Appointment _appointmentFromJson(
    Map<String, dynamic> item, {
    bool partnerView = false,
  }) => Appointment(
    id: (item['id'] as num?)?.toInt(),
    petId: int.tryParse(item['petId']?.toString() ?? '') ?? 0,
    partnerId: (item['partnerId'] as num?)?.toInt(),
    petName: item['petName']?.toString(),
    clientName: item['clientName']?.toString(),
    clientEmail: item['clientEmail']?.toString(),
    partnerName: partnerView
        ? 'Atendimento solicitado'
        : (item['partnerName']?.toString() ?? 'Parceiro AuMiau'),
    service: item['service']?.toString() ?? 'Atendimento',
    scheduledAt:
        DateTime.tryParse(item['scheduledAt']?.toString() ?? '')?.toLocal() ??
        DateTime.now(),
    status: item['status']?.toString() ?? 'requested',
    notes: item['notes']?.toString(),
    checkInAt: DateTime.tryParse(
      item['checkInAt']?.toString() ?? '',
    )?.toLocal(),
    createdAt:
        DateTime.tryParse(item['createdAt']?.toString() ?? '')?.toLocal() ??
        DateTime.now(),
  );

  String _appointmentErrorMessage(SyncGatewayException error) =>
      switch (error.statusCode) {
        404 => 'Este agendamento não está mais disponível. Atualize a agenda.',
        409 => error.message,
        429 =>
          'Muitas ações em sequência. Aguarde um instante e tente novamente.',
        _ => error.message,
      };

  Future<void> _loadRemoteAppointments() async {
    final accessToken = _accessToken;
    if (accessToken == null || accessToken.isEmpty) return;
    try {
      final items = await _syncGateway.loadAppointments(
        accessToken: accessToken,
      );
      if (!mounted) return;
      setState(() {
        _appointments = items.map(_appointmentFromJson).toList();
      });
    } on SyncGatewayException {
      // Mantém o cache local disponível quando não houver conexão.
    }
  }

  Future<List<Appointment>> _loadPartnerAppointments() async {
    final accessToken = _accessToken;
    if (accessToken == null || accessToken.isEmpty) return const [];
    final items = await _syncGateway.loadPartnerAppointments(
      accessToken: accessToken,
    );
    return items
        .map((item) => _appointmentFromJson(item, partnerView: true))
        .toList();
  }

  Future<String> _updatePartnerAppointment(
    Appointment appointment,
    String status,
  ) async {
    final accessToken = _accessToken;
    if (accessToken == null || appointment.id == null) {
      return 'Entre novamente para atualizar este atendimento.';
    }
    try {
      final result = await _syncGateway.updatePartnerAppointmentStatus(
        accessToken: accessToken,
        appointmentId: appointment.id!,
        status: status,
      );
      appointment.status = result['status']?.toString() ?? status;
      return 'Atendimento atualizado para ${_appointmentStatusLabel(appointment.status)}.';
    } on SyncGatewayException catch (error) {
      return _appointmentErrorMessage(error);
    }
  }

  Future<void> _openScheduleAppointment(PartnerClinic partner) async {
    if (_pets.isEmpty) {
      _showProductMessage('Cadastre um pet antes de solicitar atendimento.');
      return;
    }
    final notesController = TextEditingController();
    final serviceController = TextEditingController(
      text: partner.services.isEmpty
          ? 'Consulta veterinária'
          : partner.services.first,
    );
    var selectedPetId = _pets.first.id;
    var scheduledAt = DateTime.now().add(const Duration(days: 1));
    scheduledAt = DateTime(
      scheduledAt.year,
      scheduledAt.month,
      scheduledAt.day,
      10,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Solicitar atendimento · ${partner.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'O registro organiza o pedido no app. Confirme a disponibilidade diretamente com o parceiro.',
                  style: TextStyle(color: _muted, height: 1.35),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<int>(
                  initialValue: selectedPetId,
                  decoration: const InputDecoration(labelText: 'Pet'),
                  items: _pets
                      .where((pet) => pet.id != null)
                      .map(
                        (pet) => DropdownMenuItem<int>(
                          value: pet.id,
                          child: Text(pet.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setDialogState(
                    () => selectedPetId = value ?? selectedPetId,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: serviceController,
                  decoration: const InputDecoration(labelText: 'Serviço'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 180)),
                      initialDate: scheduledAt,
                    );
                    if (date == null || !context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(scheduledAt),
                    );
                    if (time == null) return;
                    setDialogState(
                      () => scheduledAt = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    'Data e hora: ${_formatAppointmentDateTime(scheduledAt)}',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Observações (opcional)',
                    alignLabelWithHint: true,
                  ),
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
                final service = serviceController.text.trim();
                if (service.isEmpty || selectedPetId == null) {
                  _showProductMessage('Informe o serviço e selecione o pet.');
                  return;
                }
                final accessToken = _accessToken;
                final partnerId = int.tryParse(partner.id);
                Pet? selectedPet;
                for (final pet in _pets) {
                  if (pet.id == selectedPetId) {
                    selectedPet = pet;
                    break;
                  }
                }
                if (accessToken == null || accessToken.isEmpty) {
                  _showProductMessage(
                    'Entre na sua conta para solicitar o atendimento.',
                  );
                  return;
                }
                if (partnerId == null || selectedPet == null) {
                  _showProductMessage(
                    'Não foi possível identificar o parceiro ou o pet.',
                  );
                  return;
                }
                Map<String, dynamic> result;
                try {
                  result = await _syncGateway.createAppointment(
                    accessToken: accessToken,
                    partnerId: partnerId,
                    petId: selectedPetId.toString(),
                    petName: selectedPet.name,
                    service: service,
                    scheduledAt: scheduledAt,
                    notes: notesController.text.trim(),
                  );
                } on SyncGatewayException catch (error) {
                  _showProductMessage(_appointmentErrorMessage(error));
                  return;
                }
                final appointment = Appointment(
                  id: (result['id'] as num?)?.toInt(),
                  petId: selectedPetId!,
                  partnerId: partnerId,
                  petName: selectedPet.name,
                  partnerName: partner.name,
                  service: service,
                  scheduledAt: scheduledAt,
                  status: result['status']?.toString() ?? 'requested',
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                  createdAt:
                      DateTime.tryParse(
                        result['createdAt']?.toString() ?? '',
                      )?.toLocal() ??
                      DateTime.now(),
                );
                _appointments.insert(0, appointment);
                _timeline.insert(
                  0,
                  TimelineEntry(
                    title: 'Atendimento: $service',
                    subtitle: partner.name,
                    date: scheduledAt,
                    icon: Icons.event_available_outlined,
                  ),
                );
                if (mounted) setState(() {});
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                _showProductMessage('Solicitação enviada ao parceiro.');
              },
              child: const Text('Registrar atendimento'),
            ),
          ],
        ),
      ),
    );
    serviceController.dispose();
    notesController.dispose();
  }

  Future<void> _checkInAppointment(Appointment appointment) async {
    final accessToken = _accessToken;
    if (appointment.id == null || accessToken == null) return;
    try {
      final result = await _syncGateway.updateAppointmentStatus(
        accessToken: accessToken,
        appointmentId: appointment.id!,
        status: 'checked_in',
      );
      appointment.status = result['status']?.toString() ?? 'checked_in';
      appointment.checkInAt = DateTime.tryParse(
        result['checkInAt']?.toString() ?? '',
      )?.toLocal();
    } on SyncGatewayException catch (error) {
      _showProductMessage(_appointmentErrorMessage(error));
      return;
    }
    if (!mounted) return;
    setState(() {});
    _showProductMessage('Check-in registrado para este atendimento.');
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    final accessToken = _accessToken;
    if (appointment.id == null || accessToken == null) return;
    try {
      final result = await _syncGateway.updateAppointmentStatus(
        accessToken: accessToken,
        appointmentId: appointment.id!,
        status: 'cancelled',
      );
      if (!mounted) return;
      setState(
        () => appointment.status = result['status']?.toString() ?? 'cancelled',
      );
      _showProductMessage('Atendimento cancelado.');
    } on SyncGatewayException catch (error) {
      _showProductMessage(_appointmentErrorMessage(error));
    }
  }

  Future<void> _openFamilyInvitation() async {
    if (!_profile.isFamily) {
      _showProductMessage(
        'A colaboração entre familiares está disponível no plano Family.',
      );
      return;
    }
    if (_pets.isEmpty) {
      _showProductMessage('Cadastre um pet antes de convidar alguém.');
      return;
    }

    final emailController = TextEditingController();
    var selectedPetId = _pets.first.id;
    var selectedRole = 'Familiar';
    var selectedPermissions = 'saude';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Convidar familiar ou cuidador'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'O convite ficará pendente por 7 dias. Ele será sincronizado com o backend quando a conta estiver conectada.',
                  style: TextStyle(color: _muted, height: 1.35),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'E-mail do convidado',
                    hintText: 'nome@exemplo.com',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: selectedPetId,
                  decoration: const InputDecoration(labelText: 'Pet'),
                  items: _pets
                      .where((pet) => pet.id != null)
                      .map(
                        (pet) => DropdownMenuItem<int>(
                          value: pet.id,
                          child: Text(pet.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setDialogState(
                    () => selectedPetId = value ?? selectedPetId,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'Perfil'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Familiar',
                      child: Text('Familiar'),
                    ),
                    DropdownMenuItem(
                      value: 'Cuidador',
                      child: Text('Cuidador'),
                    ),
                    DropdownMenuItem(
                      value: 'Passeador',
                      child: Text('Passeador'),
                    ),
                  ],
                  onChanged: (value) => setDialogState(
                    () => selectedRole = value ?? selectedRole,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedPermissions,
                  decoration: const InputDecoration(labelText: 'Permissões'),
                  items: const [
                    DropdownMenuItem(
                      value: 'saude',
                      child: Text('Saúde e histórico'),
                    ),
                    DropdownMenuItem(
                      value: 'saude_rotina',
                      child: Text('Saúde, histórico e rotina'),
                    ),
                    DropdownMenuItem(
                      value: 'visualizacao',
                      child: Text('Somente visualização'),
                    ),
                  ],
                  onChanged: (value) => setDialogState(
                    () => selectedPermissions = value ?? selectedPermissions,
                  ),
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
                final email = emailController.text.trim().toLowerCase();
                if (!email.contains('@') || selectedPetId == null) {
                  _showProductMessage(
                    'Informe um e-mail válido e selecione o pet.',
                  );
                  return;
                }
                final id = await _database.addFamilyInvitation(
                  petId: selectedPetId!,
                  email: email,
                  role: selectedRole,
                  permissions: selectedPermissions,
                  expiresAt: DateTime.now().add(const Duration(days: 7)),
                );
                _familyInvitations.insert(
                  0,
                  FamilyInvitation(
                    id: id,
                    petId: selectedPetId!,
                    email: email,
                    role: selectedRole,
                    permissions: selectedPermissions,
                    status: 'pendente',
                    expiresAt: DateTime.now().add(const Duration(days: 7)),
                    createdAt: DateTime.now(),
                  ),
                );
                if (mounted) setState(() {});
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                _showProductMessage(
                  'Convite registrado. O envio por e-mail será conectado ao backend.',
                );
              },
              child: const Text('Registrar convite'),
            ),
          ],
        ),
      ),
    );
    emailController.dispose();
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
      await WidgetsBinding.instance.endOfFrame;
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
              subtitle: const Text('Pagamento via Mercado Pago'),
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
              subtitle: const Text('Pagamento via Mercado Pago'),
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
              'Para assinar, entre ou crie uma conta. O pagamento temporário é processado com segurança pelo Mercado Pago via Pix.',
              style: TextStyle(fontSize: 12, color: _muted, height: 1.35),
            ),
          ],
        ),
        actions: [
          if (_googlePlayBillingEnabled && _playBilling.supported)
            TextButton(
              onPressed: () async {
                await _playBilling.restore();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                _showProductMessage(
                  'Consultando compras anteriores no Google Play...',
                );
              },
              child: const Text('Restaurar compras'),
            ),
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

    Timer? paymentPoller;
    var dialogClosed = false;
    var paymentCheckInFlight = false;
    var statusMessage = isTestEnvironment
        ? 'Ambiente de teste: use o bot\u00e3o Abrir pagamento para simular a cobran\u00e7a.'
        : 'Aguardando confirma\u00e7\u00e3o do pagamento...';
    var statusColor = isTestEnvironment ? _muted : _forest;

    Future<void> checkPayment(
      BuildContext dialogContext,
      StateSetter setDialogState, {
      bool manual = false,
    }) async {
      if (paymentCheckInFlight || dialogClosed) return;
      paymentCheckInFlight = true;
      if (manual && dialogContext.mounted) {
        setDialogState(() {
          statusMessage = 'Consultando o status do pagamento...';
          statusColor = _forest;
        });
      }
      try {
        final updated = await _syncGateway.loadBillingOrder(
          accessToken: _accessToken!,
          orderId: orderId,
        );
        if (updated['paid'] == true) {
          dialogClosed = true;
          paymentPoller?.cancel();
          await _refreshAccountEntitlement();
          if (dialogContext.mounted) Navigator.pop(dialogContext);
          if (mounted) {
            _showProductMessage(
              'Pagamento confirmado. O acesso ao Family foi liberado.',
            );
          }
          return;
        }
        if (dialogContext.mounted) {
          setDialogState(() {
            statusMessage = manual
                ? 'Pagamento ainda n\u00e3o confirmado. Continuaremos verificando automaticamente.'
                : 'Aguardando confirma\u00e7\u00e3o do pagamento...';
            statusColor = _forest;
          });
        }
      } on SyncGatewayException catch (error) {
        if (manual && dialogContext.mounted) {
          setDialogState(() {
            statusMessage = error.message;
            statusColor = _danger;
          });
        }
      } finally {
        paymentCheckInFlight = false;
      }
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          if (paymentPoller == null) {
            paymentPoller = Timer.periodic(
              const Duration(seconds: 5),
              (_) => unawaited(checkPayment(dialogContext, setDialogState)),
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (dialogContext.mounted) {
                unawaited(checkPayment(dialogContext, setDialogState));
              }
            });
          }
          return AlertDialog(
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
                        ? 'Ambiente de teste: use o bot\u00e3o Abrir pagamento para simular a cobran\u00e7a. Bancos reais n\u00e3o processam este QR.'
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
                    statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isTestEnvironment
                        ? 'Este pagamento est\u00e1 no sandbox do Mercado Pago e n\u00e3o libera uma cobran\u00e7a real.'
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
                      _showProductMessage(
                        'Pagamento confirmado. Family liberado.',
                      );
                    } else {
                      _showProductMessage('Pagamento ainda não confirmado.');
                    }
                  } on SyncGatewayException catch (error) {
                    _showProductMessage(error.message);
                  }
                },
                child: const Text('Verificar pagamento'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Fechar'),
              ),
            ],
          );
        },
      ),
    );
    dialogClosed = true;
    paymentPoller?.cancel();
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

  Future<void> _openDeveloperWhatsApp(String phone) async {
    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent('Olá! Vim pelo AuMiau e gostaria de falar com a C.A. Informática.')}',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _showProductMessage('Não foi possível abrir o WhatsApp.');
    }
  }

  Future<void> _openDeveloperInfo() async {
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
                    color: _forest,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: () => _openDeveloperWhatsApp('5592991580637'),
                icon: const Icon(Icons.chat_outlined),
                label: const Text('WhatsApp +55 92 99158-0637'),
              ),
              TextButton.icon(
                onPressed: () => _openDeveloperWhatsApp('5592986092837'),
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
    await _switchDatabaseForAccount(session.email);
    setState(() {
      _accessToken = session.accessToken;
      _showAuthGate = false;
      _showProfileChooser = true;
    });
    await _restoreRemoteAccountData(session.accessToken);
    await _refreshAccountEntitlement();
    await _loadData();
    await _loadRemoteAppointments();
    await _synchronizePartnerProfile();
    unawaited(_syncPrivateVeterinaryContacts());
  }

  Future<bool> _verifyGooglePlayPurchase(
    String productId,
    String purchaseToken,
  ) async {
    final accessToken = _accessToken;
    if (accessToken == null) {
      _showProductMessage('Entre na sua conta antes de validar a assinatura.');
      return false;
    }
    try {
      final result = await _syncGateway.verifyGooglePlayPurchase(
        accessToken: accessToken,
        productId: productId,
        purchaseToken: purchaseToken,
      );
      await _refreshAccountEntitlement();
      final active = result['status'] == 'active';
      _showProductMessage(
        active
            ? 'Assinatura confirmada. O AuMiau Family está ativo.'
            : 'A assinatura ainda está pendente no Google Play.',
      );
      return active;
    } on SyncGatewayException catch (error) {
      _showProductMessage(error.message);
      return false;
    }
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
      final storedSession = await _sessionStore.read();
      final serverNameValue = status['registeredName'] ?? status['name'];
      final serverName = serverNameValue is String
          ? serverNameValue.trim()
          : '';
      final profileName = profile?.name.trim() ?? '';
      final profileEmail = profile?.email.trim() ?? '';
      final accountEmail = profileEmail.isNotEmpty
          ? profileEmail
          : (storedSession?.email ?? '');
      final displayName = serverName.isNotEmpty
          ? serverName
          : (profileName.isNotEmpty ? profileName : accountEmail);
      if (displayName.isEmpty || accountEmail.isEmpty) return;
      await _database.saveProfile(
        name: displayName,
        email: accountEmail,
        plan: active
            ? ProductCatalog.family.code
            : ProductCatalog.freeOffline.code,
        familyValidUntil: active ? validUntil : null,
        preserveFamilyValidUntil: false,
        recordSyncOperation: false,
      );
      if (!mounted) return;
      setState(() {
        _profile.name = displayName;
        _profile.plan = active
            ? ProductCatalog.family.code
            : ProductCatalog.freeOffline.code;
        _profile.familyEnabled = active;
        _profile.familyValidUntil = active ? validUntil : null;
      });
      await NotificationService.instance.scheduleFamilyExpiryWarning(
        validUntil: active ? validUntil : null,
      );
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

  void _selectAppMode(_AppMode mode) {
    if (!mounted) return;
    setState(() {
      _activeMode = mode;
      _showProfileChooser = false;
      _selectedIndex = 0;
    });
  }

  Future<void> _continueOffline() async {
    if (!mounted) return;
    setState(() {
      _showAuthGate = false;
      _showProfileChooser = true;
    });
  }

  Future<void> _completeAuthenticatedSession({
    required String email,
    required SyncAuthSession session,
    String? name,
  }) async {
    await _switchDatabaseForAccount(email);
    _accessToken = session.accessToken;
    await _sessionStore.save(
      email: email,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    await _restoreRemoteAccountData(session.accessToken);
    final existingProfile = await _database.loadProfile();
    await _database.saveProfile(
      name: name?.trim().isNotEmpty == true
          ? name!.trim()
          : (existingProfile?.name.trim().isNotEmpty == true
                ? existingProfile!.name
                : email),
      email: email,
      // Uma conta nova começa no FreePet. O Family só é ativado após
      // confirmação real da assinatura pelo backend/Mercado Pago.
      plan: ProductCatalog.freeOffline.code,
      familyValidUntil: null,
      preserveFamilyValidUntil: false,
    );
    if (!mounted) return;
    setState(() {
      _showAuthGate = false;
      _showProfileChooser = true;
      _authBusy = false;
      _selectedIndex = 0;
    });
    await _loadData();
    await _refreshAccountEntitlement();
    await _loadRemoteAppointments();
    await _synchronizePartnerProfile();
    if (name != null && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_openAddressEditor());
      });
    }
  }

  Future<void> _restoreRemoteAccountData(String accessToken) async {
    try {
      await SyncService(
        _database,
      ).pullLatest(gateway: _syncGateway, accessToken: accessToken);
    } on SyncGatewayException {
      // O login continua com os dados já disponíveis no aparelho.
    }
  }

  Future<String> _submitPartnerRegistration(PartnerProfileDraft draft) async {
    await _sessionStore.savePartnerDraft(_draftOwner, draft.toJson());
    if (mounted) {
      setState(() {
        _partnerRegistrationPending = true;
        _partnerVerificationStatus = 'pending';
        _partnerProfileStatus = 'pending';
      });
    }
    final accessToken = _accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      return 'Cadastro salvo neste aparelho. Entre na conta para enviar à análise.';
    }
    try {
      final response = await _syncGateway.submitPartnerProfile(
        accessToken: accessToken,
        profile: draft.toJson(),
      );
      await _sessionStore.savePartnerDraft(
        _draftOwner,
        draft.copyWith(submittedOnline: true).toJson(),
      );
      if (mounted) {
        setState(() {
          _partnerVerificationStatus =
              response['verificationStatus']?.toString() ?? 'pending';
          _partnerProfileStatus = response['status']?.toString() ?? 'pending';
        });
      }
      return response['message']?.toString() ??
          'Cadastro enviado para análise. O perfil ficará oculto até a aprovação.';
    } on SyncGatewayException {
      return 'Cadastro salvo localmente. Enviaremos para análise quando o servidor estiver disponível.';
    }
  }

  Future<void> _synchronizePartnerProfile() async {
    final accessToken = _accessToken;
    if (accessToken == null || accessToken.isEmpty) return;
    final rawDraft = await _sessionStore.readPartnerDraft(_draftOwner);
    final draft = rawDraft == null
        ? null
        : PartnerProfileDraft.fromJson(rawDraft);
    if (draft != null && !draft.submittedOnline) {
      try {
        await _syncGateway.submitPartnerProfile(
          accessToken: accessToken,
          profile: draft.toJson(),
        );
        await _sessionStore.savePartnerDraft(
          _draftOwner,
          draft.copyWith(submittedOnline: true).toJson(),
        );
      } on SyncGatewayException {
        return;
      }
    }
    try {
      final response = await _syncGateway.loadPartnerProfile(
        accessToken: accessToken,
      );
      final status = response['status']?.toString() ?? 'pending';
      final verification =
          response['verificationStatus']?.toString() ?? 'pending';
      if (!mounted) return;
      setState(() {
        _partnerProfileStatus = status;
        _partnerVerificationStatus = verification;
        _partnerRegistrationPending =
            !(status == 'active' && verification == 'approved');
      });
    } on SyncGatewayException {
      // A conta cliente sem perfil parceiro é um estado esperado.
    }
  }

  Future<String> _uploadPartnerDocument({
    required String documentType,
    required String fileName,
    required String mimeType,
    required List<int> bytes,
  }) async {
    final accessToken = _accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      return 'Entre na conta para enviar documentos para auditoria.';
    }
    try {
      await _syncGateway.uploadPartnerDocument(
        accessToken: accessToken,
        documentType: documentType,
        fileName: fileName,
        mimeType: mimeType,
        bytes: bytes,
      );
      return 'Documento enviado para auditoria.';
    } on SyncGatewayException catch (error) {
      return error.message;
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

  Future<void> _syncPrivateVeterinaryContacts() async {
    final accessToken = _accessToken;
    if (accessToken == null || !_profile.isFamily) return;
    try {
      final localContacts = await _database.loadVeterinaryContacts();
      for (final contact in localContacts) {
        await _syncGateway.upsertPrivateVeterinaryContact(
          accessToken: accessToken,
          contact: {
            'name': contact.name,
            'kind': contact.kind,
            'specialty': contact.specialty,
            'phone': contact.phone,
            'whatsapp': contact.whatsapp,
            'address': contact.address,
            'city': contact.city,
            'state': contact.state,
            'notes': contact.notes,
            'latitude': contact.latitude,
            'longitude': contact.longitude,
          },
        );
      }
      final remoteContacts = await _syncGateway.loadPrivateVeterinaryContacts(
        accessToken: accessToken,
      );
      final localKeys = localContacts
          .map(
            (contact) => _veterinaryContactKey(
              contact.name,
              contact.phone,
              contact.whatsapp,
            ),
          )
          .toSet();
      for (final contact in remoteContacts) {
        final name = contact['name']?.toString() ?? '';
        final phone = contact['phone']?.toString() ?? '';
        final whatsapp = contact['whatsapp']?.toString() ?? '';
        if (name.trim().isEmpty ||
            localKeys.contains(_veterinaryContactKey(name, phone, whatsapp))) {
          continue;
        }
        await _database.importVeterinaryContact(
          name: name,
          kind: contact['kind']?.toString() ?? 'Veterinário',
          specialty: contact['specialty']?.toString() ?? '',
          phone: phone,
          whatsapp: whatsapp,
          address: contact['address']?.toString() ?? '',
          city: contact['city']?.toString() ?? '',
          state: contact['state']?.toString() ?? '',
          notes: contact['notes']?.toString() ?? '',
          latitude: (contact['latitude'] as num?)?.toDouble(),
          longitude: (contact['longitude'] as num?)?.toDouble(),
        );
      }
      if (mounted) await _loadData();
    } on SyncGatewayException {
      // Mantém o cadastro local quando a sincronização não estiver disponível.
    }
  }

  String _veterinaryContactKey(String name, String phone, String whatsapp) => [
    name,
    phone,
    whatsapp,
  ].map((value) => value.trim().toLowerCase()).join('|');

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
      await _syncPrivateVeterinaryContacts();
      await _loadData();
      if (!mounted) return;
      final count = acknowledgement?.acknowledgedOperationIds.length ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count == 0
                ? 'Nenhuma alteração pendente para sincronizar.'
                : count == 1
                ? 'Sincronização concluída: 1 operação.'
                : 'Sincronização concluída: $count operações.',
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

  Future<void> _showNotificationSettings() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Notificações'),
        content: const Text(
          'O AuMiau usa notificações locais para lembrar vacinas, medicamentos, '
          'rotinas e o vencimento do plano Family. Elas funcionam no aparelho '
          'e não dependem de uma conta online.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await NotificationService.instance.requestPermission();
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              _showProductMessage('Permissão de notificações atualizada.');
            },
            child: const Text('Permitir notificações'),
          ),
          FilledButton(
            onPressed: () async {
              await NotificationService.instance.showTestNotification();
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              _showProductMessage('Notificação de teste enviada.');
            },
            child: const Text('Enviar teste'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPrivacyAndData() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Privacidade e dados'),
        content: const SingleChildScrollView(
          child: Text(
            'No Free Offline, os dados ficam somente neste aparelho.\n\n'
            'No Family, os dados podem ser sincronizados com a conta para '
            'permitir backup e acesso seguro. O endereço e a localização só '
            'são usados para atendimento veterinário quando você autoriza.\n\n'
            'Você pode salvar uma cópia dos dados a qualquer momento pelo '
            'backup. Não compartilhe seu arquivo de backup com terceiros.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              unawaited(_saveBackup());
            },
            child: const Text('Salvar meus dados'),
          ),
        ],
      ),
    );
  }

  Future<void> _showHelp() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ajuda AuMiau'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Como sincronizar meus dados?',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text('Entre na sua conta e toque em “Entrar e sincronizar”.'),
              SizedBox(height: 12),
              Text(
                'Como contratar o Family?',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text('Abra o plano no Perfil e pague pelo QR Code Pix.'),
              SizedBox(height: 12),
              Text(
                'Precisa falar conosco?',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text('Nossa equipe atende pelo WhatsApp de suporte.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              unawaited(_openWhatsAppSupport());
            },
            icon: const Icon(Icons.chat_outlined),
            label: const Text('Falar no WhatsApp'),
          ),
        ],
      ),
    );
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
      await _sessionStore.clearPartnerDraft(_draftOwner);
      _accessToken = null;
      await _switchDatabaseForAccount(null);
      await _loadData();
      await NotificationService.instance.scheduleFamilyExpiryWarning(
        validUntil: null,
      );
    }
    if (!mounted) return;
    setState(() {
      _authScreen = _AuthScreen.welcome;
      _showAuthGate = true;
      _showProfileChooser = false;
      _activeMode = _AppMode.client;
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
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(dialogContext).pop(false);
            },
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

    if (_showProfileChooser) {
      return _ProfileModeChooserPage(
        email: _profile.email,
        onSelect: _selectAppMode,
        onLogout: _logout,
      );
    }

    if (_activeMode == _AppMode.partner) {
      return PartnerWorkspacePage(
        email: _profile.email,
        initialRegistrationPending: _partnerRegistrationPending,
        verificationStatus: _partnerVerificationStatus,
        profileStatus: _partnerProfileStatus,
        onRegistrationSubmitted: _submitPartnerRegistration,
        onUploadDocument: _uploadPartnerDocument,
        onLoadAppointments: _loadPartnerAppointments,
        onUpdateAppointmentStatus: _updatePartnerAppointment,
        onSwitchToClient: () => _selectAppMode(_AppMode.client),
        onLogout: _logout,
        onOpenDeveloper: _openDeveloperInfo,
        onOpenHelp: _showHelp,
        onOpenPrivacy: _showPrivacyAndData,
      );
    }

    final pages = [
      TodayPage(
        today: _today,
        profileName: _profile.name,
        isFamily: _profile.isFamily,
        pets: _pets,
        reminders: _reminders,
        onComplete: _completePersistentReminder,
        onAddReminder: _openAddReminder,
        onEditReminder: _editReminder,
        onDeleteReminder: _deleteReminder,
        onOpenContent: _openContentLibrary,
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
      PartnerDirectoryPage(
        appointments: _appointments,
        veterinaryContacts: _veterinaryContacts,
        onSchedule: _openScheduleAppointment,
        onCheckIn: _checkInAppointment,
        onCancelAppointment: _cancelAppointment,
        onRefreshAppointments: _loadRemoteAppointments,
        onAddVeterinaryContact: _openAddVeterinaryContact,
        onDeleteVeterinaryContact: _deleteVeterinaryContact,
        onLoadPartners: _loadRemotePartners,
      ),
      ProfilePage(
        profile: _profile,
        petCount: _pets.length,
        onOpenSubscription: _showSubscriptionOptions,
        onOpenNotifications: _showNotificationSettings,
        onOpenPrivacy: _showPrivacyAndData,
        onOpenHelp: _showHelp,
        onOpenDeveloper: _openDeveloperInfo,
        onEditAddress: _profile.isFamily ? _openAddressEditor : null,
        pets: _pets,
        familyInvitations: _familyInvitations,
        onInviteFamily: _profile.isFamily ? _openFamilyInvitation : null,
        pendingSyncCount: _pendingSyncCount,
        onEdit: _editProfile,
        onSaveBackup: _saveBackup,
        onShareBackup: _shareBackup,
        onRestoreBackup: _restoreBackup,
        onSync: _syncNow,
        onLogout: _logout,
        onSwitchToPartner: () => _selectAppMode(_AppMode.partner),
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
            icon: Icon(Icons.location_searching_outlined),
            selectedIcon: Icon(Icons.location_searching),
            label: 'Atendimento',
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

class _ProfileModeChooserPage extends StatelessWidget {
  const _ProfileModeChooserPage({
    required this.email,
    required this.onSelect,
    required this.onLogout,
  });

  final String email;
  final ValueChanged<_AppMode> onSelect;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _paper,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
        children: [
          const _AuthBrand(showTagline: true),
          const SizedBox(height: 26),
          Text(
            'Como você deseja usar o AuMiau?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email.isEmpty
                ? 'Escolha um perfil para continuar.'
                : 'Conta conectada: $email',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted),
          ),
          const SizedBox(height: 24),
          _ModeCard(
            icon: Icons.pets_outlined,
            title: 'Cliente AuMiau',
            description: 'Pets, saúde, rotina, atendimento e Family.',
            color: _forest,
            onTap: () => onSelect(_AppMode.client),
          ),
          const SizedBox(height: 14),
          _ModeCard(
            icon: Icons.business_outlined,
            title: 'Parceiro AuMiau',
            description: 'Clínica ou profissional com cadastro e verificação.',
            color: const Color(0xFF7C63B5),
            onTap: () => onSelect(_AppMode.partner),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_outlined),
            label: const Text('Sair da conta'),
          ),
        ],
      ),
    ),
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withValues(alpha: .12),
              foregroundColor: color,
              child: Icon(icon),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: _muted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    ),
  );
}

class PartnerWorkspacePage extends StatefulWidget {
  const PartnerWorkspacePage({
    super.key,
    required this.email,
    this.initialRegistrationPending = false,
    this.verificationStatus = 'not_submitted',
    this.profileStatus = 'pending',
    required this.onRegistrationSubmitted,
    this.onUploadDocument,
    this.onLoadAppointments,
    this.onUpdateAppointmentStatus,
    required this.onSwitchToClient,
    required this.onLogout,
    required this.onOpenDeveloper,
    required this.onOpenHelp,
    required this.onOpenPrivacy,
  });

  final String email;
  final bool initialRegistrationPending;
  final String verificationStatus;
  final String profileStatus;
  final dynamic onRegistrationSubmitted;
  final Future<String> Function({
    required String documentType,
    required String fileName,
    required String mimeType,
    required List<int> bytes,
  })?
  onUploadDocument;
  final Future<List<Appointment>> Function()? onLoadAppointments;
  final Future<String> Function(Appointment appointment, String status)?
  onUpdateAppointmentStatus;
  final VoidCallback onSwitchToClient;
  final Future<void> Function() onLogout;
  final VoidCallback onOpenDeveloper;
  final VoidCallback onOpenHelp;
  final VoidCallback onOpenPrivacy;

  @override
  State<PartnerWorkspacePage> createState() => _PartnerWorkspacePageState();
}

class _PartnerWorkspacePageState extends State<PartnerWorkspacePage> {
  int _selectedIndex = 0;
  List<Appointment> _appointments = [];
  bool _loadingAppointments = false;
  String? _appointmentsError;
  late bool _registrationPending = widget.initialRegistrationPending;
  late String _verificationStatus = widget.verificationStatus;
  late String _profileStatus = widget.profileStatus;

  bool get _partnerApproved =>
      _profileStatus == 'active' && _verificationStatus == 'approved';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_refreshAppointments());
    });
  }

  @override
  void didUpdateWidget(covariant PartnerWorkspacePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRegistrationPending !=
            widget.initialRegistrationPending ||
        oldWidget.verificationStatus != widget.verificationStatus ||
        oldWidget.profileStatus != widget.profileStatus) {
      _registrationPending = widget.initialRegistrationPending;
      _verificationStatus = widget.verificationStatus;
      _profileStatus = widget.profileStatus;
    }
  }

  Future<void> _openPartnerRegistration() async {
    final name = TextEditingController();
    final document = TextEditingController();
    final responsible = TextEditingController();
    final crmv = TextEditingController();
    final phone = TextEditingController();
    final address = TextEditingController();
    String? documentError;
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Cadastro profissional'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Informe os dados para análise. O perfil só será publicado após verificação.',
                  style: TextStyle(color: _muted),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Nome público'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: document,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final formatted = BrazilDocuments.formatCpfCnpj(value);
                    if (formatted == value) return;
                    document.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(
                        offset: formatted.length,
                      ),
                    );
                    if (documentError != null) {
                      setDialogState(() => documentError = null);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'CPF ou CNPJ',
                    hintText: '000.000.000-00 ou 00.000.000/0000-00',
                    errorText: documentError,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: responsible,
                  decoration: const InputDecoration(
                    labelText: 'Responsável profissional',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: crmv,
                  decoration: const InputDecoration(
                    labelText: 'CRMV/UF e número',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefone/WhatsApp',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: address,
                  decoration: const InputDecoration(
                    labelText: 'Endereço completo',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final validationError = BrazilDocuments.errorFor(document.text);
                if (validationError != null) {
                  setDialogState(() => documentError = validationError);
                  return;
                }
                if (name.text.trim().isEmpty ||
                    responsible.text.trim().isEmpty ||
                    crmv.text.trim().isEmpty) {
                  return;
                }
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Enviar para análise'),
            ),
          ],
        ),
      ),
    );
    // Aguarda a desmontagem da rota e do teclado antes de liberar os
    // controladores, evitando dependentes do diálogo durante o pop.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    name.dispose();
    document.dispose();
    responsible.dispose();
    crmv.dispose();
    phone.dispose();
    address.dispose();
    if (submitted != true || !mounted) return;
    setState(() => _registrationPending = true);
    final digits = document.text.replaceAll(RegExp(r'\D'), '');
    final draft = PartnerProfileDraft(
      businessName: name.text,
      partnerType: 'clinic',
      document: document.text,
      documentType: digits.length == 11 ? 'cpf' : 'cnpj',
      responsibleName: responsible.text,
      responsibleCpf: '',
      crmvUf: '',
      crmvNumber: crmv.text,
      artNumber: '',
      phone: phone.text,
      whatsapp: phone.text,
      address: address.text,
      postalCode: '',
      city: '',
      state: '',
      latitude: null,
      longitude: null,
      services: const [],
      acceptsUrgency: false,
      termsAccepted: true,
    );
    final messenger = ScaffoldMessenger.of(context);
    final result =
        widget.onRegistrationSubmitted
            is Future<String> Function(PartnerProfileDraft)
        ? await widget.onRegistrationSubmitted(draft)
        : await widget.onRegistrationSubmitted();
    final message = result is String
        ? result
        : 'Cadastro enviado para análise. O perfil permanecerá oculto até a verificação.';
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _refreshAppointments() async {
    final loader = widget.onLoadAppointments;
    if (loader == null || _loadingAppointments) return;
    setState(() {
      _loadingAppointments = true;
      _appointmentsError = null;
    });
    try {
      final appointments = await loader();
      if (!mounted) return;
      setState(() => _appointments = appointments);
    } on SyncGatewayException catch (error) {
      if (!mounted) return;
      setState(() {
        _appointmentsError = switch (error.statusCode) {
          404 => 'A agenda não foi encontrada para este perfil.',
          409 => error.message,
          429 => 'Muitas atualizações. Aguarde um instante e tente novamente.',
          _ => error.message,
        };
      });
    } finally {
      if (mounted) setState(() => _loadingAppointments = false);
    }
  }

  Future<void> _changeAppointmentStatus(
    Appointment appointment,
    String status,
  ) async {
    final updater = widget.onUpdateAppointmentStatus;
    if (updater == null) return;
    final message = await updater(appointment, status);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    await _refreshAppointments();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_buildHome(), _buildAgenda(), _buildProfile()];
    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        title: const Text('AuMiau Parceiro'),
        actions: [
          IconButton(
            tooltip: 'Trocar para Cliente',
            onPressed: widget.onSwitchToClient,
            icon: const Icon(Icons.swap_horiz),
          ),
          IconButton(
            tooltip: 'Sair da conta',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: pages[_selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) unawaited(_refreshAppointments());
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Future<void> _openDocumentUpload() async {
    final documentType = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tipo de documento'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Selecione o tipo que será enviado para análise.'),
            SizedBox(height: 12),
            _DocumentTypeOption(
              value: 'documento_responsavel',
              label: 'Documento de identidade do responsável',
            ),
            _DocumentTypeOption(
              value: 'documento_fiscal',
              label: 'CPF/CNPJ ou comprovante fiscal',
            ),
            _DocumentTypeOption(
              value: 'registro_crmv',
              label: 'Registro profissional no CRMV',
            ),
          ],
        ),
      ),
    );
    if (documentType == null || !mounted) return;
    final selection = await FilePicker.pickFiles(withData: true);
    if (selection == null || selection.files.isEmpty || !mounted) return;
    final file = selection.files.single;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível ler o arquivo selecionado.'),
        ),
      );
      return;
    }
    final handler = widget.onUploadDocument;
    if (handler == null) return;
    final message = await handler(
      documentType: documentType,
      fileName: file.name,
      mimeType: 'application/octet-stream',
      bytes: bytes,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildHome() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
    children: [
      Text(
        'Olá, parceiro',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: _ink,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 4),
      Text(widget.email, style: const TextStyle(color: _muted)),
      const SizedBox(height: 18),
      if (_partnerApproved)
        const Card(
          color: Color(0xFFE7F5EA),
          child: ListTile(
            leading: Icon(Icons.verified, color: _success),
            title: Text(
              'PERFIL APROVADO',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            subtitle: Text(
              'Seu estabelecimento poderá aparecer para clientes após a ativação da assinatura.',
            ),
          ),
        ),
      if (_partnerApproved) const SizedBox(height: 12),
      Card(
        color: _partnerApproved
            ? const Color(0xFFE7F5EA)
            : (_registrationPending ? const Color(0xFFFFF6DF) : _forest),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _registrationPending
                    ? 'CADASTRO EM ANÁLISE'
                    : 'CONTA DE PARCEIRO NECESSÁRIA',
                style: TextStyle(
                  color: _partnerApproved || _registrationPending
                      ? _forestDark
                      : _mango,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _registrationPending
                    ? 'Seu perfil ficará oculto para clientes até a conferência dos documentos.'
                    : 'Complete o cadastro profissional para publicar serviços e atender clientes.',
                style: TextStyle(
                  color: _partnerApproved || _registrationPending
                      ? _ink
                      : Colors.white,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      if (!_registrationPending && !_partnerApproved)
        FilledButton.icon(
          onPressed: _openPartnerRegistration,
          icon: const Icon(Icons.assignment_ind_outlined),
          label: const Text('Criar cadastro profissional'),
        ),
      const SizedBox(height: 14),
      _partnerInfoCard(
        Icons.event_available_outlined,
        'Agenda',
        'Solicitações, horários e check-in em um só lugar.',
        () => setState(() => _selectedIndex = 1),
      ),
      const SizedBox(height: 12),
      _partnerInfoCard(
        Icons.verified_user_outlined,
        'Verificação profissional',
        'CPF/CNPJ, responsável, CRMV e documentos para auditoria.',
        _openPartnerRegistration,
      ),
    ],
  );

  Widget _buildAgenda() => RefreshIndicator(
    onRefresh: _refreshAppointments,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Agenda e solicitações',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Atualizar agenda',
              onPressed: _loadingAppointments ? null : _refreshAppointments,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        if (_loadingAppointments) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(),
        ],
        if (_appointmentsError != null) ...[
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFFFFE8E8),
            child: ListTile(
              leading: const Icon(Icons.error_outline, color: _danger),
              title: Text(_appointmentsError!),
              trailing: TextButton(
                onPressed: _refreshAppointments,
                child: const Text('Tentar novamente'),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (!_loadingAppointments && _appointments.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nenhuma solicitação recebida',
                    style: TextStyle(fontWeight: FontWeight.w800, color: _ink),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _partnerApproved
                        ? 'Novos pedidos de clientes aparecerão aqui.'
                        : 'A agenda será liberada quando o cadastro e a assinatura estiverem ativos.',
                    style: const TextStyle(color: _muted),
                  ),
                ],
              ),
            ),
          ),
        ..._appointments.map(_partnerAppointmentCard),
      ],
    ),
  );

  Widget _partnerAppointmentCard(Appointment appointment) {
    final actions = <Widget>[];
    if (appointment.status == 'requested') {
      actions.addAll([
        FilledButton(
          onPressed: () => _changeAppointmentStatus(appointment, 'confirmed'),
          child: const Text('Confirmar'),
        ),
        OutlinedButton(
          onPressed: () => _changeAppointmentStatus(appointment, 'cancelled'),
          child: const Text('Cancelar'),
        ),
      ]);
    } else if (appointment.status == 'confirmed') {
      actions.addAll([
        FilledButton(
          onPressed: () => _changeAppointmentStatus(appointment, 'completed'),
          child: const Text('Concluir'),
        ),
        OutlinedButton(
          onPressed: () => _changeAppointmentStatus(appointment, 'cancelled'),
          child: const Text('Cancelar'),
        ),
      ]);
    } else if (appointment.status == 'checked_in') {
      actions.add(
        FilledButton(
          onPressed: () => _changeAppointmentStatus(appointment, 'completed'),
          child: const Text('Concluir atendimento'),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appointment.service,
                    style: const TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                Chip(label: Text(_appointmentStatusLabel(appointment.status))),
              ],
            ),
            Text(
              '${appointment.petName ?? 'Pet'} · ${appointment.clientName ?? appointment.clientEmail ?? 'Cliente'}',
              style: const TextStyle(color: _ink),
            ),
            const SizedBox(height: 4),
            Text(
              _formatAppointmentDateTime(appointment.scheduledAt),
              style: const TextStyle(color: _muted),
            ),
            if (appointment.notes?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text(appointment.notes!, style: const TextStyle(color: _muted)),
            ],
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfile() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
    children: [
      Text(
        'Perfil profissional',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: _ink,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 16),
      _partnerInfoCard(
        Icons.privacy_tip_outlined,
        'Privacidade e dados',
        'Consentimentos, documentos e segurança.',
        widget.onOpenPrivacy,
      ),
      const SizedBox(height: 10),
      _partnerInfoCard(
        Icons.help_outline,
        'Ajuda e suporte',
        'Fale com a equipe AuMiau.',
        widget.onOpenHelp,
      ),
      const SizedBox(height: 10),
      _partnerInfoCard(
        Icons.business_center_outlined,
        'Desenvolvedor',
        'C.A. Informática • AuMiau',
        widget.onOpenDeveloper,
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: _openDocumentUpload,
        icon: const Icon(Icons.upload_file_outlined),
        label: const Text('Enviar documento para auditoria'),
      ),
      const SizedBox(height: 18),
      OutlinedButton.icon(
        onPressed: widget.onSwitchToClient,
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Trocar para Cliente AuMiau'),
      ),
    ],
  );

  Widget _partnerInfoCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => Card(
    child: ListTile(
      onTap: onTap,
      leading: Icon(icon, color: _forest),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}

class _DocumentTypeOption extends StatelessWidget {
  const _DocumentTypeOption({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.description_outlined),
    title: Text(label),
    onTap: () => Navigator.of(context).pop(value),
  );
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
              child: LayoutBuilder(
                builder: (context, viewport) {
                  const verticalPadding = 20.0;
                  final minimumContentHeight =
                      viewport.maxHeight > verticalPadding * 2
                      ? viewport.maxHeight - (verticalPadding * 2)
                      : 0.0;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      verticalPadding,
                      18,
                      verticalPadding,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 520,
                          minHeight: minimumContentHeight,
                        ),
                        child: _buildScreen(context),
                      ),
                    ),
                  );
                },
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
        const SizedBox(height: 22),
        const _AuthTrustFooter(),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _AuthTrustFooter extends StatelessWidget {
  const _AuthTrustFooter();

  Future<void> _showTrustDetails(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.verified_user_outlined, color: _forest, size: 34),
      title: const Text('Confiança e transparência'),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seus dados são transmitidos por conexão segura e tratados conforme a finalidade dos recursos do AuMiau.',
            ),
            SizedBox(height: 12),
            Text(
              'Os pagamentos do AuMiau Family são processados pelo Mercado Pago via Pix. O AuMiau não armazena dados bancários do usuário.',
            ),
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),
            Text(
              'Desenvolvido por C.A. Informática',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 4),
            Text('CNPJ: 04.368.187/0001-31'),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Entendi'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label:
        'Dados protegidos. Pagamentos processados pelo Mercado Pago. Desenvolvido por C.A. Informática. Toque para saber mais.',
    child: InkWell(
      onTap: () => _showTrustDetails(context),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified_user_outlined, size: 20, color: _forest),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dados protegidos',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pagamentos processados pelo Mercado Pago',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 10,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Desenvolvido por',
                  style: TextStyle(color: _muted, fontSize: 9),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/branding/ca_informatica_logo.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      semanticLabel: 'Logo da C.A. Informática',
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'C.A. Informática',
                      style: TextStyle(
                        color: _forest,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
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
    this.onOpenContent,
    this.isFamily = false,
  });

  final DateTime today;
  final String profileName;
  final List<Pet> pets;
  final List<Reminder> reminders;
  final void Function(Reminder) onComplete;
  final VoidCallback onAddReminder;
  final void Function(Reminder) onEditReminder;
  final void Function(Reminder) onDeleteReminder;
  final VoidCallback? onOpenContent;
  final bool isFamily;

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
    final greetingName = _firstAndLastName(profileName);
    final hasGreetingName =
        greetingName.isNotEmpty && !greetingName.contains('@');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        _TopHeader(today: today, isFamily: isFamily),
        const SizedBox(height: 22),
        Text(
          !hasGreetingName ? 'Cuide de quem ama' : 'Oi, $greetingName! 👋',
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
        if (onOpenContent != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.menu_book_outlined, color: _forest),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conteúdos para você',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: _ink,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Orientações práticas para rotina, prevenção e bem-estar dos seus pets.',
                          style: TextStyle(color: _muted, height: 1.35),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: onOpenContent,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Abrir conteúdos'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class ContentLibrarySheet extends StatelessWidget {
  const ContentLibrarySheet({super.key});

  static const articles = <Map<String, String>>[
    {
      'category': 'Prevenção',
      'title': 'Como manter a carteira de vacinação em dia',
      'summary':
          'Confira como organizar doses, reforços e comprovantes para a próxima consulta.',
    },
    {
      'category': 'Rotina',
      'title': 'Peso e escore corporal: o que observar',
      'summary':
          'Acompanhe mudanças graduais e registre sinais para conversar com o profissional.',
    },
    {
      'category': 'Bem-estar',
      'title': 'Sinais de alerta que pedem atendimento',
      'summary':
          'Em urgências, procure imediatamente um serviço veterinário; o app não substitui avaliação clínica.',
    },
  ];

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const ContentLibrarySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biblioteca AuMiau',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Conteúdo educativo não substitui orientação de um médico-veterinário.',
              style: TextStyle(color: _muted, height: 1.35),
            ),
            const SizedBox(height: 14),
            ...articles.map(
              (article) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: const Icon(Icons.article_outlined, color: _forest),
                  title: Text(
                    article['title']!,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${article['category']} · ${article['summary']}',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
          title: 'Seus dados ficam protegidos',
          text:
              'O AuMiau funciona offline e sincroniza seus pets com segurança quando sua conta está conectada.',
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

class PartnerDirectoryPage extends StatefulWidget {
  const PartnerDirectoryPage({
    super.key,
    this.appointments = const [],
    this.veterinaryContacts = const [],
    this.onSchedule,
    this.onCheckIn,
    this.onCancelAppointment,
    this.onRefreshAppointments,
    this.onAddVeterinaryContact,
    this.onDeleteVeterinaryContact,
    this.onLoadPartners,
  });

  final List<Appointment> appointments;
  final List<PrivateVeterinaryContact> veterinaryContacts;
  final Future<void> Function(PartnerClinic partner)? onSchedule;
  final Future<void> Function(Appointment appointment)? onCheckIn;
  final Future<void> Function(Appointment appointment)? onCancelAppointment;
  final Future<void> Function()? onRefreshAppointments;
  final VoidCallback? onAddVeterinaryContact;
  final Future<void> Function(PrivateVeterinaryContact contact)?
  onDeleteVeterinaryContact;
  final Future<List<PartnerClinic>> Function({
    double? latitude,
    double? longitude,
    bool urgency,
    String? service,
  })?
  onLoadPartners;

  @override
  State<PartnerDirectoryPage> createState() => _PartnerDirectoryPageState();
}

class _PartnerDirectoryPageState extends State<PartnerDirectoryPage> {
  final _searchController = TextEditingController();
  double? _latitude;
  double? _longitude;
  bool _urgencyOnly = false;
  bool _locating = false;
  String? _locationMessage;
  List<PartnerClinic> _remotePartners = [];
  bool _loadingPartners = false;
  String? _partnerLoadMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_loadRemotePartners());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _locationMessage = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(
          () => _locationMessage =
              'Ative a localização do aparelho para ordenar por proximidade.',
        );
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(
          () => _locationMessage =
              'Permissão não concedida. Você ainda pode pesquisar por cidade.',
        );
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationMessage =
            'Localização usada somente para ordenar os resultados.';
      });
      await _loadRemotePartners();
    } catch (_) {
      setState(
        () => _locationMessage =
            'Não foi possível obter a localização. Pesquise por cidade.',
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _loadRemotePartners() async {
    final loader = widget.onLoadPartners;
    if (loader == null) return;
    if (mounted) {
      setState(() {
        _loadingPartners = true;
        _partnerLoadMessage = null;
      });
    }
    try {
      final partners = await loader(
        latitude: _latitude,
        longitude: _longitude,
        urgency: _urgencyOnly,
        service: _searchController.text,
      );
      if (!mounted) return;
      setState(() => _remotePartners = partners);
    } on SyncGatewayException catch (error) {
      if (!mounted) return;
      setState(() => _partnerLoadMessage = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _partnerLoadMessage =
            'Não foi possível carregar os parceiros agora.',
      );
    } finally {
      if (mounted) setState(() => _loadingPartners = false);
    }
  }

  Future<void> _openWhatsApp({
    required String name,
    required String phone,
  }) async {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10 || digits.length == 11) digits = '55$digits';
    if (digits.length < 12) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este contato não possui WhatsApp.')),
        );
      }
      return;
    }
    final uri = Uri.https('wa.me', '/$digits', {
      'text':
          'Olá! Encontrei $name no AuMiau e gostaria de falar sobre atendimento veterinário.',
    });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  Future<void> _openContactMaps(PrivateVeterinaryContact contact) async {
    final query = contact.latitude != null && contact.longitude != null
        ? '${contact.latitude},${contact.longitude}'
        : [
            contact.name,
            contact.address,
            contact.city,
            contact.state,
          ].where((value) => value.trim().isNotEmpty).join(', ');
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openMaps(PartnerClinic partner) async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '${partner.latitude},${partner.longitude}',
    });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final partners =
        _remotePartners.where((partner) {
          if (_urgencyOnly && !partner.acceptsUrgency) return false;
          if (query.isEmpty) return true;
          final searchable = [
            partner.name,
            partner.kind,
            partner.address,
            partner.city,
            partner.state,
            ...partner.services,
          ].join(' ').toLowerCase();
          return searchable.contains(query);
        }).toList()..sort((a, b) {
          if (_latitude == null || _longitude == null) return 0;
          return a
              .distanceFrom(_latitude!, _longitude!)
              .compareTo(b.distanceFrom(_latitude!, _longitude!));
        });
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        Text(
          'Encontrar atendimento',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Encontre clínicas e profissionais parceiros do AuMiau por cidade ou proximidade.',
          style: TextStyle(color: _muted, fontSize: 15, height: 1.35),
        ),
        const SizedBox(height: 18),
        Card(
          color: _forest,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.health_and_safety_outlined, color: _mango),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Em uma urgência ou emergência, procure atendimento veterinário imediato. O AuMiau não substitui avaliação profissional.',
                    style: TextStyle(color: Colors.white, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                'Meus profissionais',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: widget.onAddVeterinaryContact,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text('Cadastrar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.veterinaryContacts.isEmpty)
          Card(
            child: ListTile(
              leading: const Icon(Icons.contacts_outlined, color: _forest),
              title: const Text('Nenhum profissional privado'),
              subtitle: const Text(
                'Cadastre seu veterinário ou clínica de confiança. Este cadastro fica somente para você.',
              ),
              onTap: widget.onAddVeterinaryContact,
            ),
          )
        else
          ...widget.veterinaryContacts.map(
            (contact) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _VeterinaryContactCard(
                contact: contact,
                onOpenWhatsApp: () => _openWhatsApp(
                  name: contact.name,
                  phone: contact.whatsapp.isNotEmpty
                      ? contact.whatsapp
                      : contact.phone,
                ),
                onOpenMaps: () => _openContactMaps(contact),
                onDelete: widget.onDeleteVeterinaryContact == null
                    ? null
                    : () => widget.onDeleteVeterinaryContact!(contact),
              ),
            ),
          ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                'Meus atendimentos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Atualizar atendimentos',
              onPressed: widget.onRefreshAppointments,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.appointments.isEmpty)
          const Card(
            child: ListTile(
              leading: Icon(Icons.event_busy_outlined),
              title: Text('Nenhum atendimento solicitado'),
              subtitle: Text('Escolha um parceiro abaixo para agendar.'),
            ),
          )
        else ...[
          ...widget.appointments
              .take(3)
              .map(
                (appointment) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.event_available_outlined,
                            color: _forest,
                          ),
                          title: Text(appointment.service),
                          subtitle: Text(
                            '${appointment.partnerName} · ${_formatAppointmentDateTime(appointment.scheduledAt)}',
                          ),
                          trailing: Chip(
                            label: Text(
                              _appointmentStatusLabel(appointment.status),
                            ),
                          ),
                        ),
                        if (appointment.status == 'confirmed')
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.icon(
                                onPressed: widget.onCheckIn == null
                                    ? null
                                    : () => widget.onCheckIn!(appointment),
                                icon: const Icon(Icons.how_to_reg_outlined),
                                label: const Text('Fazer check-in'),
                              ),
                              OutlinedButton(
                                onPressed: widget.onCancelAppointment == null
                                    ? null
                                    : () => widget.onCancelAppointment!(
                                        appointment,
                                      ),
                                child: const Text('Cancelar'),
                              ),
                            ],
                          )
                        else if (appointment.status == 'requested')
                          OutlinedButton(
                            onPressed: widget.onCancelAppointment == null
                                ? null
                                : () =>
                                      widget.onCancelAppointment!(appointment),
                            child: const Text('Cancelar solicitação'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'Pesquisar clínica, profissional ou cidade',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: Icon(Icons.tune),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _locating ? null : _useCurrentLocation,
                        icon: Icon(
                          _locating ? Icons.sync : Icons.my_location_outlined,
                        ),
                        label: Text(
                          _locating ? 'Obtendo...' : 'Usar minha localização',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Abrir pesquisa no Maps',
                      onPressed: () async {
                        final query = _latitude == null
                            ? 'clínica veterinária perto de mim'
                            : 'clínica veterinária perto de $_latitude,$_longitude';
                        final uri = Uri.https(
                          'www.google.com',
                          '/maps/search/',
                          {'api': '1', 'query': query},
                        );
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      icon: const Icon(Icons.map_outlined, color: _forest),
                    ),
                  ],
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _urgencyOnly,
                  onChanged: (value) {
                    setState(() => _urgencyOnly = value);
                    unawaited(_loadRemotePartners());
                  },
                  title: const Text('Mostrar apenas atendimento rápido'),
                  subtitle: const Text(
                    'A disponibilidade precisa ser confirmada com o parceiro.',
                  ),
                ),
                if (_locationMessage != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _locationMessage!,
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          color: const Color(0xFFFFF7E6),
          child: const Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              'Parceiros oficiais do AuMiau são cadastrados e validados pelo painel. Eles são diferentes dos profissionais privados cadastrados por você.',
              style: TextStyle(color: _ink, height: 1.35),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (_loadingPartners) const LinearProgressIndicator(minHeight: 3),
        if (_partnerLoadMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _partnerLoadMessage!,
            style: const TextStyle(color: _muted, fontSize: 12),
          ),
        ],
        if (partners.isEmpty)
          const _EmptyState(
            icon: Icons.location_off_outlined,
            title: 'Nenhum parceiro oficial encontrado',
            subtitle:
                'Ainda não há parceiros publicados na sua região. Você pode cadastrar seu veterinário em Meus profissionais.',
          )
        else
          ...partners.map(
            (partner) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PartnerCard(
                partner: partner,
                distanceKm: _latitude == null || _longitude == null
                    ? null
                    : partner.distanceFrom(_latitude!, _longitude!),
                onOpenMaps: () => _openMaps(partner),
                onOpenWhatsApp: () => _openWhatsApp(
                  name: partner.name,
                  phone: partner.whatsapp.isNotEmpty
                      ? partner.whatsapp
                      : partner.phone,
                ),
                onSchedule: widget.onSchedule == null
                    ? null
                    : () => widget.onSchedule!(partner),
              ),
            ),
          ),
      ],
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({
    required this.partner,
    required this.distanceKm,
    required this.onOpenMaps,
    this.onOpenWhatsApp,
    this.onSchedule,
  });

  final PartnerClinic partner;
  final double? distanceKm;
  final VoidCallback onOpenMaps;
  final VoidCallback? onOpenWhatsApp;
  final VoidCallback? onSchedule;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE7F1EC),
                  foregroundColor: _forest,
                  child: Icon(Icons.local_hospital_outlined),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(partner.kind, style: const TextStyle(color: _muted)),
                    ],
                  ),
                ),
                if (partner.acceptsUrgency)
                  const Chip(
                    label: Text('Rápido'),
                    avatar: Icon(Icons.bolt, size: 16),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              partner.address,
              style: const TextStyle(color: _ink, height: 1.3),
            ),
            if (distanceKm != null) ...[
              const SizedBox(height: 4),
              Text(
                distanceKm! < 1
                    ? '${(distanceKm! * 1000).round()} m da sua localização'
                    : '${distanceKm!.toStringAsFixed(1)} km da sua localização',
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: partner.services
                  .map((service) => Chip(label: Text(service)))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenMaps,
                    icon: const Icon(Icons.directions_outlined),
                    label: const Text('Abrir rota'),
                  ),
                ),
                if (onOpenWhatsApp != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onOpenWhatsApp,
                      icon: const Icon(Icons.chat_outlined),
                      label: const Text('WhatsApp'),
                    ),
                  ),
                ],
                if (onSchedule != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onSchedule,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Agendar'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VeterinaryContactCard extends StatelessWidget {
  const _VeterinaryContactCard({
    required this.contact,
    required this.onOpenWhatsApp,
    required this.onOpenMaps,
    this.onDelete,
  });

  final PrivateVeterinaryContact contact;
  final VoidCallback onOpenWhatsApp;
  final VoidCallback onOpenMaps;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final location = [
      contact.address,
      contact.city,
      contact.state,
    ].where((value) => value.trim().isNotEmpty).join(', ');
    final subtitle = [
      contact.kind,
      contact.specialty,
    ].where((value) => value.trim().isNotEmpty).join(' · ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFFFF0C7),
                  foregroundColor: _forest,
                  child: Icon(Icons.person_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _ink,
                          fontSize: 16,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(subtitle, style: const TextStyle(color: _muted)),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    tooltip: 'Excluir contato privado',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            if (location.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(location, style: const TextStyle(color: _ink)),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenMaps,
                    icon: const Icon(Icons.directions_outlined),
                    label: const Text('Abrir rota'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onOpenWhatsApp,
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('WhatsApp'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    this.profile,
    this.petCount = 2,
    this.onOpenSubscription,
    this.onOpenNotifications,
    this.onOpenPrivacy,
    this.onOpenHelp,
    this.onOpenDeveloper,
    this.onEditAddress,
    this.pets = const [],
    this.familyInvitations = const [],
    this.onInviteFamily,
    this.pendingSyncCount = 0,
    this.onEdit,
    this.onSaveBackup,
    this.onShareBackup,
    this.onRestoreBackup,
    this.onSync,
    this.onLogout,
    this.onSwitchToPartner,
    this.syncing = false,
  });

  final LocalProfile? profile;
  final int petCount;
  final VoidCallback? onOpenSubscription;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenPrivacy;
  final VoidCallback? onOpenHelp;
  final VoidCallback? onOpenDeveloper;
  final VoidCallback? onEditAddress;
  final List<Pet> pets;
  final List<FamilyInvitation> familyInvitations;
  final VoidCallback? onInviteFamily;
  final int pendingSyncCount;
  final VoidCallback? onEdit;
  final VoidCallback? onSaveBackup;
  final VoidCallback? onShareBackup;
  final VoidCallback? onRestoreBackup;
  final VoidCallback? onSync;
  final VoidCallback? onLogout;
  final VoidCallback? onSwitchToPartner;
  final bool syncing;

  @override
  Widget build(BuildContext context) {
    final currentProfile = profile ?? LocalProfile.defaultProfile();
    final initials = currentProfile.name.trim().isEmpty
        ? 'A'
        : currentProfile.name.trim().substring(0, 1).toUpperCase();
    final familyValidUntil = currentProfile.familyValidUntil?.toLocal();
    final familyExpiryLabel = familyValidUntil == null
        ? null
        : '${familyValidUntil.day.toString().padLeft(2, '0')}/'
              '${familyValidUntil.month.toString().padLeft(2, '0')}/'
              '${familyValidUntil.year}';
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
                      : familyExpiryLabel == null
                      ? 'Sua conta Family está ativa. Seus dados podem ser sincronizados com segurança.'
                      : 'Sua conta Family está ativa até $familyExpiryLabel. Seus dados podem ser sincronizados com segurança.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: currentProfile.isFreeOffline
                      ? onOpenSubscription ?? () => _showComingSoon(context)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: currentProfile.isFreeOffline
                        ? _mango
                        : Colors.white24,
                    foregroundColor: currentProfile.isFreeOffline
                        ? _forestDark
                        : Colors.white70,
                    disabledBackgroundColor: Colors.white24,
                    disabledForegroundColor: Colors.white70,
                  ),
                  child: Text(
                    currentProfile.isFreeOffline
                        ? 'Conhecer Plano Família'
                        : 'Assinatura Family ativa',
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
        if (onInviteFamily != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.group_outlined, color: _forest),
                      const SizedBox(width: 10),
                      Text(
                        'Família e cuidadores',
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
                    'Convide uma pessoa de confiança e defina o que ela poderá visualizar ou registrar para cada pet.',
                    style: TextStyle(color: _muted, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  if (familyInvitations.isEmpty)
                    const Text(
                      'Nenhum convite pendente.',
                      style: TextStyle(color: _muted),
                    )
                  else
                    ...familyInvitations
                        .take(3)
                        .map(
                          (invitation) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.mail_outline,
                              color: _forest,
                            ),
                            title: Text(invitation.email),
                            subtitle: Text(
                              '${pets.any((pet) => pet.id == invitation.petId) ? pets.firstWhere((pet) => pet.id == invitation.petId).name : 'Pet'} · ${invitation.role} · ${invitation.status}',
                            ),
                          ),
                        ),
                  OutlinedButton.icon(
                    onPressed: onInviteFamily,
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Convidar familiar ou cuidador'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (onSwitchToPartner != null) ...[
          Card(
            child: _SettingsTile(
              icon: Icons.business_center_outlined,
              title: 'Usar como Parceiro',
              subtitle: 'Acesse o cadastro profissional e a agenda.',
              onTap: onSwitchToPartner,
            ),
          ),
          const SizedBox(height: 16),
        ],
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
                            : pendingSyncCount == 1
                            ? '1 alteração aguardando sincronização.'
                            : '$pendingSyncCount alterações aguardando sincronização.',
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
            children: [
              _SettingsTile(
                icon: Icons.notifications_none,
                title: 'Notificações',
                subtitle: 'Lembretes locais e preferências',
                onTap: onOpenNotifications,
              ),
              _SettingsTile(
                icon: Icons.security_outlined,
                title: 'Privacidade e dados',
                subtitle: 'Uso, backup e segurança dos dados',
                onTap: onOpenPrivacy,
              ),
              _SettingsTile(
                icon: Icons.help_outline,
                title: 'Ajuda',
                subtitle: 'Fale com o suporte AuMiau',
                onTap: onOpenHelp,
              ),
              _SettingsTile(
                icon: Icons.business_outlined,
                title: 'Desenvolvedor',
                subtitle: 'C.A. Informática • AuMiau',
                onTap: onOpenDeveloper,
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
  const _TopHeader({required this.today, this.isFamily = false});
  final DateTime today;
  final bool isFamily;

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
          child: Text(
            isFamily ? 'FAMILY ATIVO' : 'PLANO GRATUITO',
            style: const TextStyle(
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
                  backgroundImage: pet.photoData == null
                      ? null
                      : MemoryImage(base64Decode(pet.photoData!)),
                  child: pet.photoData == null
                      ? Text(pet.emoji, style: const TextStyle(fontSize: 31))
                      : null,
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
                      if (pet.birthDate != null ||
                          pet.sex.isNotEmpty ||
                          pet.color.isNotEmpty)
                        Text(
                          [
                            if (pet.birthDate != null)
                              'Nasc. ${_formatFullDate(pet.birthDate!)}',
                            if (pet.sex.isNotEmpty) pet.sex,
                            if (pet.color.isNotEmpty) pet.color,
                          ].join(' · '),
                          style: const TextStyle(color: _muted, fontSize: 12),
                        ),
                      if (pet.hasPedigree || pet.microchip?.isNotEmpty == true)
                        Text(
                          [
                            if (pet.hasPedigree) 'Pedigree',
                            if (pet.microchip?.isNotEmpty == true) 'Microchip',
                          ].join(' · '),
                          style: const TextStyle(
                            color: _forest,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (pet.size.isNotEmpty ||
                          pet.reproductiveStatus.isNotEmpty ||
                          pet.bodyConditionScore != null)
                        Text(
                          [
                            if (pet.size.isNotEmpty) 'Porte: ${pet.size}',
                            if (pet.reproductiveStatus.isNotEmpty)
                              pet.reproductiveStatus,
                            if (pet.bodyConditionScore != null)
                              'Escore ${pet.bodyConditionScore!.toStringAsFixed(1)}',
                          ].join(' · '),
                          style: const TextStyle(color: _muted, fontSize: 12),
                        ),
                      if (pet.characteristics.isNotEmpty)
                        Text(
                          pet.characteristics,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _muted, fontSize: 12),
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
                      if (pet.clinicReference.isNotEmpty ||
                          pet.veterinarianReference.isNotEmpty)
                        Text(
                          [
                            if (pet.clinicReference.isNotEmpty)
                              'Clínica: ${pet.clinicReference}',
                            if (pet.veterinarianReference.isNotEmpty)
                              'Vet.: ${pet.veterinarianReference}',
                          ].join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _forest, fontSize: 12),
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
    this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
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

String _firstAndLastName(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.length < 2 || parts.any((part) => part.contains('@'))) return '';
  return '${parts.first} ${parts.last}';
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

String _formatFullDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

String _formatAppointmentDateTime(DateTime date) =>
    '${_formatFullDate(date)} às '
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';

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
