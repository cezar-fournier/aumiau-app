import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'account_scope.dart';

part 'app_database.g.dart';

class Pets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get species => text().withLength(min: 1, max: 40)();
  TextColumn get breed => text().withLength(min: 1, max: 120)();
  TextColumn get emoji => text().withDefault(const Constant('🐾'))();
  RealColumn get weight => real().withDefault(const Constant(0.0))();
  TextColumn get allergies => text().withDefault(const Constant(''))();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get sex => text().withDefault(const Constant(''))();
  TextColumn get color => text().withDefault(const Constant(''))();
  TextColumn get characteristics => text().withDefault(const Constant(''))();
  BoolColumn get hasPedigree => boolean().withDefault(const Constant(false))();
  TextColumn get pedigreeNumber => text().nullable()();
  TextColumn get microchip => text().nullable()();
  TextColumn get size => text().withDefault(const Constant(''))();
  TextColumn get reproductiveStatus => text().withDefault(const Constant(''))();
  RealColumn get bodyConditionScore => real().nullable()();
  TextColumn get clinicReference => text().withDefault(const Constant(''))();
  TextColumn get veterinarianReference =>
      text().withDefault(const Constant(''))();
  TextColumn get documentNotes => text().withDefault(const Constant(''))();
  TextColumn get photoData => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncId => text().withDefault(const Constant(''))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
}

class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 160)();
  IntColumn get petId => integer().references(Pets, #id)();
  TextColumn get petName => text().withLength(min: 1, max: 100)();
  TextColumn get icon => text().withDefault(const Constant('💊'))();
  TextColumn get category => text().withDefault(const Constant('Rotina'))();
  DateTimeColumn get dueAt => dateTime()();
  IntColumn get intervalDays => integer().withDefault(const Constant(30))();
  DateTimeColumn get lastCompletedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Vaccines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get petId => integer().references(Pets, #id)();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  DateTimeColumn get appliedAt => dateTime()();
  DateTimeColumn get nextDoseAt => dateTime().nullable()();
  TextColumn get clinicName => text().nullable()();
  TextColumn get batchNumber => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncId => text().withDefault(const Constant(''))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
}

class PreventiveRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get petId => integer().references(Pets, #id)();
  TextColumn get category => text().withLength(min: 1, max: 80)();
  TextColumn get product => text().withLength(min: 1, max: 140)();
  DateTimeColumn get appliedAt => dateTime()();
  DateTimeColumn get nextDueAt => dateTime().nullable()();
  TextColumn get provider => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class MedicationPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get petId => integer().references(Pets, #id)();
  TextColumn get name => text().withLength(min: 1, max: 140)();
  TextColumn get dosage => text().withLength(min: 1, max: 100)();
  TextColumn get schedule => text().withLength(min: 1, max: 120)();
  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastTakenAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncId => text().withDefault(const Constant(''))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
}

class FamilyInvitations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get petId => integer().references(Pets, #id)();
  TextColumn get email => text().withLength(min: 3, max: 180)();
  TextColumn get role => text().withLength(min: 1, max: 40)();
  TextColumn get permissions => text().withDefault(const Constant('saude'))();
  TextColumn get status => text().withDefault(const Constant('pendente'))();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Appointments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get petId => integer().references(Pets, #id)();
  TextColumn get partnerName => text().withLength(min: 1, max: 160)();
  TextColumn get service => text().withLength(min: 1, max: 120)();
  DateTimeColumn get scheduledAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('agendado'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class VeterinaryContacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 2, max: 160)();
  TextColumn get kind => text().withDefault(const Constant('Veterinário'))();
  TextColumn get specialty => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get whatsapp => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get city => text().withDefault(const Constant(''))();
  TextColumn get state => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class WeightEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get petId => integer().references(Pets, #id)();
  RealColumn get weight => real()();
  DateTimeColumn get measuredAt => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncId => text().withDefault(const Constant(''))();
  IntColumn get syncVersion => integer().withDefault(const Constant(0))();
}

class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().withLength(min: 3, max: 180)();
  TextColumn get plan => text().withDefault(const Constant('free_offline'))();
  DateTimeColumn get familyValidUntil => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class SyncOperations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text().withLength(min: 1, max: 40)();
  IntColumn get entityId => integer().nullable()();
  TextColumn get operation => text().withLength(min: 1, max: 20)();
  TextColumn get payload => text().withDefault(const Constant(''))();
  DateTimeColumn get occurredAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

class SyncStates extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get revision => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Pets,
    Reminders,
    Vaccines,
    PreventiveRecords,
    MedicationPlans,
    FamilyInvitations,
    Appointments,
    VeterinaryContacts,
    WeightEntries,
    UserProfiles,
    SyncOperations,
    SyncStates,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase({
    QueryExecutor? executor,
    this.seedDemoData = false,
    String databaseName = 'aumiau_app',
  }) : super(
         executor ??
             driftDatabase(
               name: databaseName,
               web: DriftWebOptions(
                 sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                 driftWorker: Uri.parse('drift_worker.dart.js'),
               ),
             ),
       );

  AppDatabase.fromExecutor(super.executor, {this.seedDemoData = true});

  factory AppDatabase.forAccount(String email) => AppDatabase(
    databaseName: accountDatabaseName(email),
    seedDemoData: false,
  );

  final bool seedDemoData;

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      if (seedDemoData) await _seed();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(weightEntries);
        final existingPets = await select(pets).get();
        await batch((batch) {
          batch.insertAll(
            weightEntries,
            existingPets
                .where((pet) => pet.weight > 0)
                .map(
                  (pet) => WeightEntriesCompanion.insert(
                    petId: pet.id,
                    weight: pet.weight,
                    measuredAt: pet.createdAt,
                    note: const Value('Registro inicial'),
                  ),
                )
                .toList(),
          );
        });
      }
      if (from < 3) {
        await m.createTable(userProfiles);
        await m.createTable(syncOperations);
        if (seedDemoData) {
          await into(userProfiles).insert(
            UserProfilesCompanion.insert(
              name: 'Cezar Fournier',
              email: 'cezar@exemplo.com',
            ),
          );
        }
      }
      if (from < 4) {
        await m.addColumn(pets, pets.birthDate);
        await m.addColumn(pets, pets.sex);
        await m.addColumn(pets, pets.color);
        await m.addColumn(pets, pets.characteristics);
        await m.addColumn(pets, pets.hasPedigree);
        await m.addColumn(pets, pets.pedigreeNumber);
        await m.addColumn(pets, pets.microchip);
      }
      if (from < 5) {
        await m.addColumn(pets, pets.size);
        await m.addColumn(pets, pets.reproductiveStatus);
        await m.addColumn(pets, pets.bodyConditionScore);
        await m.addColumn(pets, pets.clinicReference);
        await m.addColumn(pets, pets.veterinarianReference);
        await m.addColumn(pets, pets.documentNotes);
      }
      if (from < 6) {
        await m.addColumn(pets, pets.photoData);
      }
      if (from < 7) {
        await m.createTable(preventiveRecords);
        await m.createTable(medicationPlans);
        await m.createTable(familyInvitations);
      }
      if (from < 8) {
        await m.createTable(appointments);
      }
      if (from < 9) {
        await m.addColumn(userProfiles, userProfiles.familyValidUntil);
      }
      if (from < 10) {
        await m.createTable(veterinaryContacts);
      }
      if (from < 11) {
        await m.createTable(syncStates);
      }
      if (from < 12) {
        await m.addColumn(pets, pets.syncId);
        await m.addColumn(pets, pets.syncVersion);
        await customStatement(
          "UPDATE pets SET sync_id = lower(hex(randomblob(16))) WHERE sync_id = ''",
        );
      }
      if (from < 13) {
        await m.addColumn(vaccines, vaccines.syncId);
        await m.addColumn(vaccines, vaccines.syncVersion);
        await m.addColumn(weightEntries, weightEntries.syncId);
        await m.addColumn(weightEntries, weightEntries.syncVersion);
        await m.addColumn(medicationPlans, medicationPlans.syncId);
        await m.addColumn(medicationPlans, medicationPlans.syncVersion);
        await customStatement(
          "UPDATE vaccines SET sync_id = lower(hex(randomblob(16))) WHERE sync_id = ''",
        );
        await customStatement(
          "UPDATE weight_entries SET sync_id = lower(hex(randomblob(16))) WHERE sync_id = ''",
        );
        await customStatement(
          "UPDATE medication_plans SET sync_id = lower(hex(randomblob(16))) WHERE sync_id = ''",
        );
      }
    },
  );

  Future<void> _seed() async {
    final today = DateTime.now();
    await into(userProfiles).insert(
      UserProfilesCompanion.insert(
        name: 'Cezar Fournier',
        email: 'cezar@exemplo.com',
      ),
    );
    final thorId = await into(pets).insert(
      PetsCompanion.insert(
        name: 'Thor',
        species: 'Cão',
        breed: 'Vira-lata',
        emoji: const Value('🐶'),
        weight: const Value(18.2),
        allergies: const Value('Alergia a picada de pulga'),
      ),
    );
    final melId = await into(pets).insert(
      PetsCompanion.insert(
        name: 'Mel',
        species: 'Gata',
        breed: 'SRD',
        emoji: const Value('🐱'),
        weight: const Value(3.9),
      ),
    );

    await batch((batch) {
      batch.insertAll(vaccines, [
        VaccinesCompanion.insert(
          petId: thorId,
          name: 'V10',
          appliedAt: today.subtract(const Duration(days: 300)),
          nextDoseAt: Value(today.add(const Duration(days: 65))),
          clinicName: const Value('Clínica Amigo Fiel'),
        ),
        VaccinesCompanion.insert(
          petId: thorId,
          name: 'Antirrábica',
          appliedAt: today.subtract(const Duration(days: 370)),
          nextDoseAt: Value(today.subtract(const Duration(days: 5))),
          clinicName: const Value('Campanha municipal'),
        ),
        VaccinesCompanion.insert(
          petId: melId,
          name: 'V4 Felina',
          appliedAt: today.subtract(const Duration(days: 200)),
          nextDoseAt: Value(today.add(const Duration(days: 165))),
          clinicName: const Value('PetVida'),
        ),
        VaccinesCompanion.insert(
          petId: melId,
          name: 'Antirrábica',
          appliedAt: today.subtract(const Duration(days: 200)),
          nextDoseAt: Value(today.add(const Duration(days: 12))),
          clinicName: const Value('PetVida'),
        ),
      ]);
      batch.insertAll(reminders, [
        RemindersCompanion.insert(
          title: 'Vermífugo do Thor',
          petId: thorId,
          petName: 'Thor',
          icon: const Value('💊'),
          category: const Value('Rotina'),
          dueAt: today,
          intervalDays: const Value(90),
        ),
        RemindersCompanion.insert(
          title: 'Antipulgas do Thor',
          petId: thorId,
          petName: 'Thor',
          icon: const Value('🪲'),
          category: const Value('Rotina'),
          dueAt: today,
          intervalDays: const Value(30),
        ),
        RemindersCompanion.insert(
          title: 'Vermífugo da Mel',
          petId: melId,
          petName: 'Mel',
          icon: const Value('💊'),
          category: const Value('Rotina'),
          dueAt: today.add(const Duration(days: 3)),
          intervalDays: const Value(90),
        ),
        RemindersCompanion.insert(
          title: 'Banho do Thor',
          petId: thorId,
          petName: 'Thor',
          icon: const Value('🛁'),
          category: const Value('Banho'),
          dueAt: today.add(const Duration(days: 5)),
          intervalDays: const Value(15),
        ),
      ]);
      batch.insertAll(weightEntries, [
        WeightEntriesCompanion.insert(
          petId: thorId,
          weight: 18.2,
          measuredAt: today.subtract(const Duration(days: 7)),
          note: const Value('Consulta de rotina'),
        ),
        WeightEntriesCompanion.insert(
          petId: melId,
          weight: 3.9,
          measuredAt: today.subtract(const Duration(days: 1)),
          note: const Value('Acompanhamento em casa'),
        ),
      ]);
    });
  }

  Future<List<Pet>> loadPets() => select(pets).get();

  Future<List<Reminder>> loadReminders() => select(reminders).get();

  Future<List<Vaccine>> loadVaccines() => select(vaccines).get();

  Future<List<PreventiveRecord>> loadPreventiveRecords() => (select(
    preventiveRecords,
  )..orderBy([(row) => OrderingTerm.desc(row.appliedAt)])).get();

  Future<List<MedicationPlan>> loadMedicationPlans() => (select(
    medicationPlans,
  )..orderBy([(row) => OrderingTerm.desc(row.startAt)])).get();

  Future<List<FamilyInvitation>> loadFamilyInvitations() => (select(
    familyInvitations,
  )..orderBy([(row) => OrderingTerm.desc(row.createdAt)])).get();

  Future<List<Appointment>> loadAppointments() => (select(
    appointments,
  )..orderBy([(row) => OrderingTerm.asc(row.scheduledAt)])).get();

  Future<List<VeterinaryContact>> loadVeterinaryContacts() => (select(
    veterinaryContacts,
  )..orderBy([(row) => OrderingTerm.asc(row.name)])).get();

  Future<List<WeightEntry>> loadWeights() => (select(
    weightEntries,
  )..orderBy([(row) => OrderingTerm.desc(row.measuredAt)])).get();

  Future<UserProfile?> loadProfile() =>
      (select(userProfiles)..limit(1)).getSingleOrNull();

  Future<List<SyncOperation>> loadPendingSyncOperations() =>
      (select(syncOperations)
            ..where((row) => row.syncedAt.isNull())
            ..orderBy([(row) => OrderingTerm.asc(row.occurredAt)]))
          .get();

  Future<void> markSyncOperationsAsSynced(Iterable<int> ids) async {
    final operationIds = ids.toList();
    if (operationIds.isEmpty) return;
    await (update(syncOperations)..where((row) => row.id.isIn(operationIds)))
        .write(SyncOperationsCompanion(syncedAt: Value(DateTime.now())));
  }

  Future<int> loadSyncRevision() async =>
      (await (select(
        syncStates,
      )..where((row) => row.id.equals(1))).getSingleOrNull())?.revision ??
      0;

  Future<void> saveSyncRevision(int revision) async {
    await into(syncStates).insertOnConflictUpdate(
      SyncStatesCompanion.insert(
        id: const Value(1),
        revision: Value(revision),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> saveProfile({
    required String name,
    required String email,
    String? plan,
    DateTime? familyValidUntil,
    bool preserveFamilyValidUntil = true,
    bool recordSyncOperation = true,
  }) async {
    final profile = await loadProfile();
    if (profile == null) {
      final id = await into(userProfiles).insert(
        UserProfilesCompanion.insert(
          name: name,
          email: email,
          plan: Value(plan ?? 'free_offline'),
          familyValidUntil: Value(familyValidUntil),
        ),
      );
      if (recordSyncOperation) {
        await _recordSync('profile', id, 'upsert');
      }
      return;
    }
    await (update(
      userProfiles,
    )..where((row) => row.id.equals(profile.id))).write(
      UserProfilesCompanion(
        name: Value(name),
        email: Value(email),
        plan: plan == null ? const Value.absent() : Value(plan),
        familyValidUntil: preserveFamilyValidUntil
            ? const Value.absent()
            : Value(familyValidUntil),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (recordSyncOperation) {
      await _recordSync('profile', profile.id, 'upsert');
    }
  }

  Future<int> addPet({
    required String name,
    required String species,
    required String breed,
    required String emoji,
    DateTime? birthDate,
    String sex = '',
    String color = '',
    String characteristics = '',
    bool hasPedigree = false,
    String? pedigreeNumber,
    String? microchip,
    String size = '',
    String reproductiveStatus = '',
    double? bodyConditionScore,
    String clinicReference = '',
    String veterinarianReference = '',
    String documentNotes = '',
    String? photoData,
    double weight = 0,
    String allergies = '',
  }) async {
    final id = await into(pets).insert(
      PetsCompanion.insert(
        name: name,
        species: species,
        breed: breed,
        emoji: Value(emoji),
        birthDate: Value(birthDate),
        sex: Value(sex),
        color: Value(color),
        characteristics: Value(characteristics),
        hasPedigree: Value(hasPedigree),
        pedigreeNumber: Value(pedigreeNumber),
        microchip: Value(microchip),
        size: Value(size),
        reproductiveStatus: Value(reproductiveStatus),
        bodyConditionScore: Value(bodyConditionScore),
        clinicReference: Value(clinicReference),
        veterinarianReference: Value(veterinarianReference),
        documentNotes: Value(documentNotes),
        photoData: Value(photoData),
        weight: Value(weight),
        allergies: Value(allergies),
        syncId: Value(_newSyncId()),
      ),
    );
    await _recordPetSync(id, 'create');
    return id;
  }

  Future<int> addReminder({
    required String title,
    required int petId,
    required String petName,
    required String icon,
    required String category,
    required DateTime dueAt,
    int intervalDays = 30,
  }) async {
    final id = await into(reminders).insert(
      RemindersCompanion.insert(
        title: title,
        petId: petId,
        petName: petName,
        icon: Value(icon),
        category: Value(category),
        dueAt: dueAt,
        intervalDays: Value(intervalDays),
      ),
    );
    await _recordSync('reminder', id, 'create');
    return id;
  }

  Future<int> addVaccine({
    required int petId,
    required String name,
    required DateTime appliedAt,
    DateTime? nextDoseAt,
    String? clinicName,
  }) async {
    final id = await into(vaccines).insert(
      VaccinesCompanion.insert(
        petId: petId,
        name: name,
        appliedAt: appliedAt,
        nextDoseAt: Value(nextDoseAt),
        clinicName: Value(clinicName),
        syncId: Value(_newSyncId()),
      ),
    );
    await _recordVaccineSync(id, 'create');
    return id;
  }

  Future<int> addWeight({
    required int petId,
    required double weight,
    required DateTime measuredAt,
    String? note,
  }) async {
    final id = await into(weightEntries).insert(
      WeightEntriesCompanion.insert(
        petId: petId,
        weight: weight,
        measuredAt: measuredAt,
        note: Value(note),
        syncId: Value(_newSyncId()),
      ),
    );
    await _recordWeightSync(id, 'create');
    return id;
  }

  Future<int> addPreventive({
    required int petId,
    required String category,
    required String product,
    required DateTime appliedAt,
    DateTime? nextDueAt,
    String? provider,
    String? notes,
  }) async {
    final id = await into(preventiveRecords).insert(
      PreventiveRecordsCompanion.insert(
        petId: petId,
        category: category,
        product: product,
        appliedAt: appliedAt,
        nextDueAt: Value(nextDueAt),
        provider: Value(provider),
        notes: Value(notes),
      ),
    );
    await _recordSync('preventive', id, 'create');
    return id;
  }

  Future<int> addMedicationPlan({
    required int petId,
    required String name,
    required String dosage,
    required String schedule,
    required DateTime startAt,
    DateTime? endAt,
    String? notes,
  }) async {
    final id = await into(medicationPlans).insert(
      MedicationPlansCompanion.insert(
        petId: petId,
        name: name,
        dosage: dosage,
        schedule: schedule,
        startAt: startAt,
        endAt: Value(endAt),
        notes: Value(notes),
        syncId: Value(_newSyncId()),
      ),
    );
    await _recordMedicationSync(id, 'create');
    return id;
  }

  Future<void> markMedicationTaken(int id) async {
    await (update(medicationPlans)..where((row) => row.id.equals(id))).write(
      MedicationPlansCompanion(lastTakenAt: Value(DateTime.now())),
    );
    await _recordMedicationSync(id, 'update');
  }

  Future<int> addFamilyInvitation({
    required int petId,
    required String email,
    required String role,
    required String permissions,
    required DateTime expiresAt,
  }) async {
    final id = await into(familyInvitations).insert(
      FamilyInvitationsCompanion.insert(
        petId: petId,
        email: email,
        role: role,
        permissions: Value(permissions),
        expiresAt: expiresAt,
      ),
    );
    await _recordSync('family_invitation', id, 'create');
    return id;
  }

  Future<int> addAppointment({
    required int petId,
    required String partnerName,
    required String service,
    required DateTime scheduledAt,
    String? notes,
  }) async {
    final id = await into(appointments).insert(
      AppointmentsCompanion.insert(
        petId: petId,
        partnerName: partnerName,
        service: service,
        scheduledAt: scheduledAt,
        notes: Value(notes),
      ),
    );
    await _recordSync('appointment', id, 'create');
    return id;
  }

  Future<void> updateAppointmentStatus(int id, String status) async {
    await (update(appointments)..where((row) => row.id.equals(id))).write(
      AppointmentsCompanion(status: Value(status)),
    );
    await _recordSync('appointment', id, 'status');
  }

  Future<int> addVeterinaryContact({
    required String name,
    required String kind,
    String specialty = '',
    String phone = '',
    String whatsapp = '',
    String address = '',
    String city = '',
    String state = '',
    String notes = '',
    double? latitude,
    double? longitude,
  }) async {
    final id = await into(veterinaryContacts).insert(
      VeterinaryContactsCompanion.insert(
        name: name.trim(),
        kind: Value(kind.trim().isEmpty ? 'Veterinário' : kind.trim()),
        specialty: Value(specialty.trim()),
        phone: Value(phone.trim()),
        whatsapp: Value(whatsapp.trim()),
        address: Value(address.trim()),
        city: Value(city.trim()),
        state: Value(state.trim()),
        notes: Value(notes.trim()),
        latitude: Value(latitude),
        longitude: Value(longitude),
      ),
    );
    await _recordSync('veterinary_contact', id, 'create');
    return id;
  }

  Future<void> deleteVeterinaryContact(int id) async {
    await (delete(veterinaryContacts)..where((row) => row.id.equals(id))).go();
    await _recordSync('veterinary_contact', id, 'delete');
  }

  Future<int> importVeterinaryContact({
    required String name,
    required String kind,
    String specialty = '',
    String phone = '',
    String whatsapp = '',
    String address = '',
    String city = '',
    String state = '',
    String notes = '',
    double? latitude,
    double? longitude,
  }) {
    return into(veterinaryContacts).insert(
      VeterinaryContactsCompanion.insert(
        name: name.trim(),
        kind: Value(kind.trim().isEmpty ? 'Veterinário' : kind.trim()),
        specialty: Value(specialty.trim()),
        phone: Value(phone.trim()),
        whatsapp: Value(whatsapp.trim()),
        address: Value(address.trim()),
        city: Value(city.trim()),
        state: Value(state.trim()),
        notes: Value(notes.trim()),
        latitude: Value(latitude),
        longitude: Value(longitude),
      ),
    );
  }

  Future<void> updateReminderTitle(int id, String title) async {
    await (update(reminders)..where((row) => row.id.equals(id))).write(
      RemindersCompanion(title: Value(title)),
    );
    await _recordSync('reminder', id, 'update');
  }

  Future<void> updatePetName(int id, String name) async {
    await (update(pets)..where((row) => row.id.equals(id))).write(
      PetsCompanion(name: Value(name)),
    );
    await _recordPetSync(id, 'update');
  }

  Future<void> updateReminderPetName(int petId, String petName) async {
    await (update(reminders)..where((row) => row.petId.equals(petId))).write(
      RemindersCompanion(petName: Value(petName)),
    );
    await _recordPetSync(petId, 'update');
  }

  Future<void> deleteReminder(int id) async {
    await (delete(reminders)..where((row) => row.id.equals(id))).go();
    await _recordSync('reminder', id, 'delete');
  }

  Future<void> deleteVaccine(int id) async {
    final vaccine = await (select(
      vaccines,
    )..where((row) => row.id.equals(id))).getSingle();
    await (delete(vaccines)..where((row) => row.id.equals(id))).go();
    await _recordEntityTombstone(
      entityType: 'vaccine',
      entityId: id,
      syncId: vaccine.syncId,
      baseVersion: vaccine.syncVersion,
    );
  }

  Future<void> deleteWeight(int id) async {
    final entry = await (select(
      weightEntries,
    )..where((row) => row.id.equals(id))).getSingle();
    await (delete(weightEntries)..where((row) => row.id.equals(id))).go();
    await _recordEntityTombstone(
      entityType: 'weight',
      entityId: id,
      syncId: entry.syncId,
      baseVersion: entry.syncVersion,
    );
  }

  Future<void> deleteMedicationPlan(int id) async {
    final medication = await (select(
      medicationPlans,
    )..where((row) => row.id.equals(id))).getSingle();
    await (delete(medicationPlans)..where((row) => row.id.equals(id))).go();
    await _recordEntityTombstone(
      entityType: 'medication',
      entityId: id,
      syncId: medication.syncId,
      baseVersion: medication.syncVersion,
    );
  }

  Future<void> deletePet(int id) async {
    final pet = await (select(
      pets,
    )..where((row) => row.id.equals(id))).getSingle();
    final petVaccines = await (select(
      vaccines,
    )..where((row) => row.petId.equals(id))).get();
    final petWeights = await (select(
      weightEntries,
    )..where((row) => row.petId.equals(id))).get();
    final petMedications = await (select(
      medicationPlans,
    )..where((row) => row.petId.equals(id))).get();
    await transaction(() async {
      for (final vaccine in petVaccines) {
        await _recordEntityTombstone(
          entityType: 'vaccine',
          entityId: vaccine.id,
          syncId: vaccine.syncId,
          baseVersion: vaccine.syncVersion,
        );
      }
      for (final entry in petWeights) {
        await _recordEntityTombstone(
          entityType: 'weight',
          entityId: entry.id,
          syncId: entry.syncId,
          baseVersion: entry.syncVersion,
        );
      }
      for (final medication in petMedications) {
        await _recordEntityTombstone(
          entityType: 'medication',
          entityId: medication.id,
          syncId: medication.syncId,
          baseVersion: medication.syncVersion,
        );
      }
      await (delete(reminders)..where((row) => row.petId.equals(id))).go();
      await (delete(vaccines)..where((row) => row.petId.equals(id))).go();
      await (delete(
        preventiveRecords,
      )..where((row) => row.petId.equals(id))).go();
      await (delete(
        medicationPlans,
      )..where((row) => row.petId.equals(id))).go();
      await (delete(
        familyInvitations,
      )..where((row) => row.petId.equals(id))).go();
      await (delete(appointments)..where((row) => row.petId.equals(id))).go();
      await (delete(weightEntries)..where((row) => row.petId.equals(id))).go();
      await (delete(pets)..where((row) => row.id.equals(id))).go();
    });
    await _recordSync(
      'pet',
      id,
      'delete',
      payload: {
        'syncId': pet.syncId,
        'baseVersion': pet.syncVersion,
        'deleted': true,
      },
    );
  }

  Future<void> completeReminder(int id, DateTime nextDueAt) async {
    await (update(reminders)..where((row) => row.id.equals(id))).write(
      RemindersCompanion(
        dueAt: Value(nextDueAt),
        lastCompletedAt: Value(DateTime.now()),
      ),
    );
    await _recordSync('reminder', id, 'complete');
  }

  Future<Map<String, dynamic>> exportSnapshot({
    bool includeGranularClinicalEntities = true,
  }) async {
    final profile = await loadProfile();
    final databasePets = await loadPets();
    final databaseReminders = await loadReminders();
    final databaseVaccines = await loadVaccines();
    final databasePreventives = await loadPreventiveRecords();
    final databaseMedications = await loadMedicationPlans();
    final databaseInvitations = await loadFamilyInvitations();
    final databaseAppointments = await loadAppointments();
    final databaseVeterinaryContacts = await loadVeterinaryContacts();
    final databaseWeights = await loadWeights();

    return {
      'format': 'aumiau-backup',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': profile == null
          ? null
          : {
              'id': profile.id,
              'name': profile.name,
              'email': profile.email,
              'plan': profile.plan,
              'familyValidUntil': profile.familyValidUntil?.toIso8601String(),
              'updatedAt': profile.updatedAt.toIso8601String(),
            },
      'pets': databasePets
          .map(
            (pet) => {
              'id': pet.id,
              'name': pet.name,
              'species': pet.species,
              'breed': pet.breed,
              'emoji': pet.emoji,
              'weight': pet.weight,
              'allergies': pet.allergies,
              'birthDate': pet.birthDate?.toIso8601String(),
              'sex': pet.sex,
              'color': pet.color,
              'characteristics': pet.characteristics,
              'hasPedigree': pet.hasPedigree,
              'pedigreeNumber': pet.pedigreeNumber,
              'microchip': pet.microchip,
              'size': pet.size,
              'reproductiveStatus': pet.reproductiveStatus,
              'bodyConditionScore': pet.bodyConditionScore,
              'clinicReference': pet.clinicReference,
              'veterinarianReference': pet.veterinarianReference,
              'documentNotes': pet.documentNotes,
              'photoData': pet.photoData,
              'createdAt': pet.createdAt.toIso8601String(),
              'syncId': pet.syncId,
              'syncVersion': pet.syncVersion,
            },
          )
          .toList(),
      'reminders': databaseReminders
          .map(
            (reminder) => {
              'id': reminder.id,
              'title': reminder.title,
              'petId': reminder.petId,
              'petName': reminder.petName,
              'icon': reminder.icon,
              'category': reminder.category,
              'dueAt': reminder.dueAt.toIso8601String(),
              'intervalDays': reminder.intervalDays,
              'lastCompletedAt': reminder.lastCompletedAt?.toIso8601String(),
              'createdAt': reminder.createdAt.toIso8601String(),
            },
          )
          .toList(),
      if (includeGranularClinicalEntities)
        'vaccines': databaseVaccines
            .map(
              (vaccine) => {
                'id': vaccine.id,
                'petId': vaccine.petId,
                'name': vaccine.name,
                'appliedAt': vaccine.appliedAt.toIso8601String(),
                'nextDoseAt': vaccine.nextDoseAt?.toIso8601String(),
                'clinicName': vaccine.clinicName,
                'batchNumber': vaccine.batchNumber,
                'createdAt': vaccine.createdAt.toIso8601String(),
                'syncId': vaccine.syncId,
                'syncVersion': vaccine.syncVersion,
              },
            )
            .toList(),
      'preventives': databasePreventives
          .map(
            (record) => {
              'id': record.id,
              'petId': record.petId,
              'category': record.category,
              'product': record.product,
              'appliedAt': record.appliedAt.toIso8601String(),
              'nextDueAt': record.nextDueAt?.toIso8601String(),
              'provider': record.provider,
              'notes': record.notes,
              'createdAt': record.createdAt.toIso8601String(),
            },
          )
          .toList(),
      if (includeGranularClinicalEntities)
        'medications': databaseMedications
            .map(
              (medication) => {
                'id': medication.id,
                'petId': medication.petId,
                'name': medication.name,
                'dosage': medication.dosage,
                'schedule': medication.schedule,
                'startAt': medication.startAt.toIso8601String(),
                'endAt': medication.endAt?.toIso8601String(),
                'active': medication.active,
                'lastTakenAt': medication.lastTakenAt?.toIso8601String(),
                'notes': medication.notes,
                'createdAt': medication.createdAt.toIso8601String(),
                'syncId': medication.syncId,
                'syncVersion': medication.syncVersion,
              },
            )
            .toList(),
      'familyInvitations': databaseInvitations
          .map(
            (invitation) => {
              'id': invitation.id,
              'petId': invitation.petId,
              'email': invitation.email,
              'role': invitation.role,
              'permissions': invitation.permissions,
              'status': invitation.status,
              'expiresAt': invitation.expiresAt.toIso8601String(),
              'createdAt': invitation.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'appointments': databaseAppointments
          .map(
            (appointment) => {
              'id': appointment.id,
              'petId': appointment.petId,
              'partnerName': appointment.partnerName,
              'service': appointment.service,
              'scheduledAt': appointment.scheduledAt.toIso8601String(),
              'status': appointment.status,
              'notes': appointment.notes,
              'createdAt': appointment.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'veterinaryContacts': databaseVeterinaryContacts
          .map(
            (contact) => {
              'id': contact.id,
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
              'createdAt': contact.createdAt.toIso8601String(),
              'updatedAt': contact.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      if (includeGranularClinicalEntities)
        'weights': databaseWeights
            .map(
              (weight) => {
                'id': weight.id,
                'petId': weight.petId,
                'weight': weight.weight,
                'measuredAt': weight.measuredAt.toIso8601String(),
                'note': weight.note,
                'createdAt': weight.createdAt.toIso8601String(),
                'syncId': weight.syncId,
                'syncVersion': weight.syncVersion,
              },
            )
            .toList(),
    };
  }

  Future<void> restoreSnapshot(
    Map<String, dynamic> snapshot, {
    bool recordSyncOperation = true,
  }) async {
    if (snapshot['format'] != 'aumiau-backup' || snapshot['version'] != 1) {
      throw const FormatException('Arquivo de backup incompatível.');
    }
    final petsData = _mapList(snapshot['pets']);
    final remindersData = _mapList(snapshot['reminders']);
    final vaccinesData = _optionalMapList(snapshot['vaccines']);
    final preventivesData = _optionalMapList(snapshot['preventives']);
    final medicationsData = _optionalMapList(snapshot['medications']);
    final invitationsData = _optionalMapList(snapshot['familyInvitations']);
    final appointmentsData = _optionalMapList(snapshot['appointments']);
    final veterinaryContactsData = _optionalMapList(
      snapshot['veterinaryContacts'],
    );
    final weightsData = _optionalMapList(snapshot['weights']);
    final profileData = snapshot['profile'] is Map
        ? Map<String, dynamic>.from(snapshot['profile'] as Map)
        : null;

    await transaction(() async {
      await delete(syncOperations).go();
      await delete(weightEntries).go();
      await delete(vaccines).go();
      await delete(preventiveRecords).go();
      await delete(medicationPlans).go();
      await delete(familyInvitations).go();
      await delete(appointments).go();
      await delete(veterinaryContacts).go();
      await delete(reminders).go();
      await delete(pets).go();
      await delete(userProfiles).go();

      if (profileData != null) {
        await into(userProfiles).insert(
          UserProfilesCompanion.insert(
            id: Value(_int(profileData['id'])),
            name: _string(profileData['name']),
            email: _string(profileData['email']),
            plan: Value(_string(profileData['plan'], fallback: 'free_offline')),
            familyValidUntil: Value(
              _nullableDate(profileData['familyValidUntil']),
            ),
            updatedAt: Value(_date(profileData['updatedAt'])),
          ),
        );
      }

      await batch((batch) {
        batch.insertAll(
          pets,
          petsData
              .map(
                (pet) => PetsCompanion.insert(
                  id: Value(_int(pet['id'])),
                  name: _string(pet['name']),
                  species: _string(pet['species']),
                  breed: _string(pet['breed']),
                  emoji: Value(_string(pet['emoji'], fallback: '🐾')),
                  weight: Value(_double(pet['weight'])),
                  allergies: Value(_string(pet['allergies'])),
                  birthDate: Value(_nullableDate(pet['birthDate'])),
                  sex: Value(_string(pet['sex'])),
                  color: Value(_string(pet['color'])),
                  characteristics: Value(_string(pet['characteristics'])),
                  hasPedigree: Value(_bool(pet['hasPedigree'])),
                  pedigreeNumber: Value(_nullableString(pet['pedigreeNumber'])),
                  microchip: Value(_nullableString(pet['microchip'])),
                  size: Value(_string(pet['size'])),
                  reproductiveStatus: Value(_string(pet['reproductiveStatus'])),
                  bodyConditionScore: Value(
                    _nullableDouble(pet['bodyConditionScore']),
                  ),
                  clinicReference: Value(_string(pet['clinicReference'])),
                  veterinarianReference: Value(
                    _string(pet['veterinarianReference']),
                  ),
                  documentNotes: Value(_string(pet['documentNotes'])),
                  photoData: Value(_nullableString(pet['photoData'])),
                  createdAt: Value(_date(pet['createdAt'])),
                  syncId: Value(_string(pet['syncId'], fallback: _newSyncId())),
                  syncVersion: Value(_int(pet['syncVersion'])),
                ),
              )
              .toList(),
        );
        batch.insertAll(
          reminders,
          remindersData
              .map(
                (reminder) => RemindersCompanion.insert(
                  id: Value(_int(reminder['id'])),
                  title: _string(reminder['title']),
                  petId: _int(reminder['petId']),
                  petName: _string(reminder['petName']),
                  icon: Value(_string(reminder['icon'], fallback: '💊')),
                  category: Value(
                    _string(reminder['category'], fallback: 'Rotina'),
                  ),
                  dueAt: _date(reminder['dueAt']),
                  intervalDays: Value(_int(reminder['intervalDays'])),
                  lastCompletedAt: Value(
                    _nullableDate(reminder['lastCompletedAt']),
                  ),
                  createdAt: Value(_date(reminder['createdAt'])),
                ),
              )
              .toList(),
        );
        batch.insertAll(
          vaccines,
          vaccinesData
              .map(
                (vaccine) => VaccinesCompanion.insert(
                  id: Value(_int(vaccine['id'])),
                  petId: _int(vaccine['petId']),
                  name: _string(vaccine['name']),
                  appliedAt: _date(vaccine['appliedAt']),
                  nextDoseAt: Value(_nullableDate(vaccine['nextDoseAt'])),
                  clinicName: Value(_nullableString(vaccine['clinicName'])),
                  batchNumber: Value(_nullableString(vaccine['batchNumber'])),
                  createdAt: Value(_date(vaccine['createdAt'])),
                  syncId: Value(
                    _string(vaccine['syncId'], fallback: _newSyncId()),
                  ),
                  syncVersion: Value(_int(vaccine['syncVersion'])),
                ),
              )
              .toList(),
        );
        batch.insertAll(
          veterinaryContacts,
          veterinaryContactsData
              .map(
                (contact) => VeterinaryContactsCompanion.insert(
                  id: Value(_int(contact['id'])),
                  name: _string(contact['name']),
                  kind: Value(
                    _string(contact['kind'], fallback: 'Veterinário'),
                  ),
                  specialty: Value(_string(contact['specialty'])),
                  phone: Value(_string(contact['phone'])),
                  whatsapp: Value(_string(contact['whatsapp'])),
                  address: Value(_string(contact['address'])),
                  city: Value(_string(contact['city'])),
                  state: Value(_string(contact['state'])),
                  notes: Value(_string(contact['notes'])),
                  latitude: Value(_nullableDouble(contact['latitude'])),
                  longitude: Value(_nullableDouble(contact['longitude'])),
                  createdAt: Value(_date(contact['createdAt'])),
                  updatedAt: Value(_date(contact['updatedAt'])),
                ),
              )
              .toList(),
        );
        batch.insertAll(
          preventiveRecords,
          preventivesData
              .map(
                (record) => PreventiveRecordsCompanion.insert(
                  id: Value(_int(record['id'])),
                  petId: _int(record['petId']),
                  category: _string(record['category']),
                  product: _string(record['product']),
                  appliedAt: _date(record['appliedAt']),
                  nextDueAt: Value(_nullableDate(record['nextDueAt'])),
                  provider: Value(_nullableString(record['provider'])),
                  notes: Value(_nullableString(record['notes'])),
                  createdAt: Value(_date(record['createdAt'])),
                ),
              )
              .toList(),
        );
        batch.insertAll(
          medicationPlans,
          medicationsData
              .map(
                (medication) => MedicationPlansCompanion.insert(
                  id: Value(_int(medication['id'])),
                  petId: _int(medication['petId']),
                  name: _string(medication['name']),
                  dosage: _string(medication['dosage']),
                  schedule: _string(medication['schedule']),
                  startAt: _date(medication['startAt']),
                  endAt: Value(_nullableDate(medication['endAt'])),
                  active: Value(medication['active'] != false),
                  lastTakenAt: Value(_nullableDate(medication['lastTakenAt'])),
                  notes: Value(_nullableString(medication['notes'])),
                  createdAt: Value(_date(medication['createdAt'])),
                  syncId: Value(
                    _string(medication['syncId'], fallback: _newSyncId()),
                  ),
                  syncVersion: Value(_int(medication['syncVersion'])),
                ),
              )
              .toList(),
        );
        batch.insertAll(
          familyInvitations,
          invitationsData
              .map(
                (invitation) => FamilyInvitationsCompanion.insert(
                  id: Value(_int(invitation['id'])),
                  petId: _int(invitation['petId']),
                  email: _string(invitation['email']),
                  role: _string(invitation['role'], fallback: 'Cuidador'),
                  permissions: Value(
                    _string(invitation['permissions'], fallback: 'saude'),
                  ),
                  status: Value(
                    _string(invitation['status'], fallback: 'pendente'),
                  ),
                  expiresAt: _date(invitation['expiresAt']),
                  createdAt: Value(_date(invitation['createdAt'])),
                ),
              )
              .toList(),
        );
        batch.insertAll(
          appointments,
          appointmentsData
              .map(
                (appointment) => AppointmentsCompanion.insert(
                  id: Value(_int(appointment['id'])),
                  petId: _int(appointment['petId']),
                  partnerName: _string(appointment['partnerName']),
                  service: _string(appointment['service']),
                  scheduledAt: _date(appointment['scheduledAt']),
                  status: Value(
                    _string(appointment['status'], fallback: 'agendado'),
                  ),
                  notes: Value(_nullableString(appointment['notes'])),
                  createdAt: Value(_date(appointment['createdAt'])),
                ),
              )
              .toList(),
        );
        batch.insertAll(
          weightEntries,
          weightsData
              .map(
                (weight) => WeightEntriesCompanion.insert(
                  id: Value(_int(weight['id'])),
                  petId: _int(weight['petId']),
                  weight: _double(weight['weight']),
                  measuredAt: _date(weight['measuredAt']),
                  note: Value(_nullableString(weight['note'])),
                  createdAt: Value(_date(weight['createdAt'])),
                  syncId: Value(
                    _string(weight['syncId'], fallback: _newSyncId()),
                  ),
                  syncVersion: Value(_int(weight['syncVersion'])),
                ),
              )
              .toList(),
        );
      });
      if (recordSyncOperation) {
        await into(syncOperations).insert(
          SyncOperationsCompanion.insert(
            entityType: 'snapshot',
            operation: 'restore',
            payload: Value(jsonEncode({'version': snapshot['version']})),
          ),
        );
      }
    });
  }

  Future<void> _recordPetSync(int id, String operation) async {
    final pet = await (select(
      pets,
    )..where((row) => row.id.equals(id))).getSingle();
    await _recordSync(
      'pet',
      id,
      operation,
      payload: {
        'syncId': pet.syncId,
        'baseVersion': pet.syncVersion,
        'deleted': false,
        'data': {
          'name': pet.name,
          'species': pet.species,
          'breed': pet.breed,
          'emoji': pet.emoji,
          'weight': pet.weight,
          'allergies': pet.allergies,
          'birthDate': pet.birthDate?.toUtc().toIso8601String(),
          'sex': pet.sex,
          'color': pet.color,
          'characteristics': pet.characteristics,
          'hasPedigree': pet.hasPedigree,
          'pedigreeNumber': pet.pedigreeNumber,
          'microchip': pet.microchip,
          'size': pet.size,
          'reproductiveStatus': pet.reproductiveStatus,
          'bodyConditionScore': pet.bodyConditionScore,
          'clinicReference': pet.clinicReference,
          'veterinarianReference': pet.veterinarianReference,
          'documentNotes': pet.documentNotes,
          'photoData': pet.photoData,
          'createdAt': pet.createdAt.toUtc().toIso8601String(),
        },
      },
    );
  }

  Future<void> _recordVaccineSync(int id, String operation) async {
    final vaccine = await (select(
      vaccines,
    )..where((row) => row.id.equals(id))).getSingle();
    final pet = await (select(
      pets,
    )..where((row) => row.id.equals(vaccine.petId))).getSingle();
    await _recordSync(
      'vaccine',
      id,
      operation,
      payload: {
        'syncId': vaccine.syncId,
        'baseVersion': vaccine.syncVersion,
        'deleted': false,
        'data': {
          'petSyncId': pet.syncId,
          'name': vaccine.name,
          'appliedAt': vaccine.appliedAt.toUtc().toIso8601String(),
          'nextDoseAt': vaccine.nextDoseAt?.toUtc().toIso8601String(),
          'clinicName': vaccine.clinicName,
          'batchNumber': vaccine.batchNumber,
          'createdAt': vaccine.createdAt.toUtc().toIso8601String(),
        },
      },
    );
  }

  Future<void> _recordWeightSync(int id, String operation) async {
    final entry = await (select(
      weightEntries,
    )..where((row) => row.id.equals(id))).getSingle();
    final pet = await (select(
      pets,
    )..where((row) => row.id.equals(entry.petId))).getSingle();
    await _recordSync(
      'weight',
      id,
      operation,
      payload: {
        'syncId': entry.syncId,
        'baseVersion': entry.syncVersion,
        'deleted': false,
        'data': {
          'petSyncId': pet.syncId,
          'weight': entry.weight,
          'measuredAt': entry.measuredAt.toUtc().toIso8601String(),
          'note': entry.note,
          'createdAt': entry.createdAt.toUtc().toIso8601String(),
        },
      },
    );
  }

  Future<void> _recordMedicationSync(int id, String operation) async {
    final medication = await (select(
      medicationPlans,
    )..where((row) => row.id.equals(id))).getSingle();
    final pet = await (select(
      pets,
    )..where((row) => row.id.equals(medication.petId))).getSingle();
    await _recordSync(
      'medication',
      id,
      operation,
      payload: {
        'syncId': medication.syncId,
        'baseVersion': medication.syncVersion,
        'deleted': false,
        'data': {
          'petSyncId': pet.syncId,
          'name': medication.name,
          'dosage': medication.dosage,
          'schedule': medication.schedule,
          'startAt': medication.startAt.toUtc().toIso8601String(),
          'endAt': medication.endAt?.toUtc().toIso8601String(),
          'active': medication.active,
          'lastTakenAt': medication.lastTakenAt?.toUtc().toIso8601String(),
          'notes': medication.notes,
          'createdAt': medication.createdAt.toUtc().toIso8601String(),
        },
      },
    );
  }

  Future<void> _recordEntityTombstone({
    required String entityType,
    required int entityId,
    required String syncId,
    required int baseVersion,
  }) => _recordSync(
    entityType,
    entityId,
    'delete',
    payload: {'syncId': syncId, 'baseVersion': baseVersion, 'deleted': true},
  );

  Future<List<SyncOperation>> loadPendingPetSyncOperations() =>
      (select(syncOperations)
            ..where(
              (row) => row.syncedAt.isNull() & row.entityType.equals('pet'),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.occurredAt)]))
          .get();

  Future<void> applyPetSyncVersion(String syncId, int version) async {
    await (update(pets)..where((row) => row.syncId.equals(syncId))).write(
      PetsCompanion(syncVersion: Value(version)),
    );
  }

  Future<void> applyRemotePets(List<Map<String, dynamic>> entities) async {
    await transaction(() async {
      for (final entity in entities) {
        final syncId = _string(entity['entityId']);
        final version = _int(entity['version']);
        final existing = await (select(
          pets,
        )..where((row) => row.syncId.equals(syncId))).getSingleOrNull();
        if (entity['deleted'] == true) {
          if (existing != null && existing.syncVersion < version) {
            await (delete(
              reminders,
            )..where((row) => row.petId.equals(existing.id))).go();
            await (delete(
              vaccines,
            )..where((row) => row.petId.equals(existing.id))).go();
            await (delete(
              preventiveRecords,
            )..where((row) => row.petId.equals(existing.id))).go();
            await (delete(
              medicationPlans,
            )..where((row) => row.petId.equals(existing.id))).go();
            await (delete(
              familyInvitations,
            )..where((row) => row.petId.equals(existing.id))).go();
            await (delete(
              appointments,
            )..where((row) => row.petId.equals(existing.id))).go();
            await (delete(
              weightEntries,
            )..where((row) => row.petId.equals(existing.id))).go();
            await (delete(
              pets,
            )..where((row) => row.id.equals(existing.id))).go();
          }
          continue;
        }
        final data = entity['payload'] is Map
            ? Map<String, dynamic>.from(entity['payload'] as Map)
            : const <String, dynamic>{};
        if (existing != null && existing.syncVersion >= version) continue;
        final companion = PetsCompanion.insert(
          id: existing == null ? const Value.absent() : Value(existing.id),
          name: _string(data['name']),
          species: _string(data['species']),
          breed: _string(data['breed']),
          emoji: Value(_string(data['emoji'], fallback: '🐾')),
          weight: Value(_double(data['weight'])),
          allergies: Value(_string(data['allergies'])),
          birthDate: Value(_nullableDate(data['birthDate'])),
          sex: Value(_string(data['sex'])),
          color: Value(_string(data['color'])),
          characteristics: Value(_string(data['characteristics'])),
          hasPedigree: Value(_bool(data['hasPedigree'])),
          pedigreeNumber: Value(_nullableString(data['pedigreeNumber'])),
          microchip: Value(_nullableString(data['microchip'])),
          size: Value(_string(data['size'])),
          reproductiveStatus: Value(_string(data['reproductiveStatus'])),
          bodyConditionScore: Value(
            _nullableDouble(data['bodyConditionScore']),
          ),
          clinicReference: Value(_string(data['clinicReference'])),
          veterinarianReference: Value(_string(data['veterinarianReference'])),
          documentNotes: Value(_string(data['documentNotes'])),
          photoData: Value(_nullableString(data['photoData'])),
          createdAt: Value(_date(data['createdAt'])),
          syncId: Value(syncId),
          syncVersion: Value(version),
        );
        if (existing == null) {
          await into(pets).insert(companion);
        } else {
          await into(pets).insertOnConflictUpdate(companion);
        }
      }
    });
  }

  Future<List<SyncOperation>> loadPendingEntitySyncOperations(
    String entityType,
  ) =>
      (select(syncOperations)
            ..where(
              (row) =>
                  row.syncedAt.isNull() & row.entityType.equals(entityType),
            )
            ..orderBy([(row) => OrderingTerm.asc(row.occurredAt)]))
          .get();

  Future<void> applyEntitySyncVersion(
    String entityType,
    String syncId,
    int version,
  ) async {
    switch (entityType) {
      case 'vaccine':
        await (update(vaccines)..where((row) => row.syncId.equals(syncId)))
            .write(VaccinesCompanion(syncVersion: Value(version)));
      case 'weight':
        await (update(weightEntries)..where((row) => row.syncId.equals(syncId)))
            .write(WeightEntriesCompanion(syncVersion: Value(version)));
      case 'medication':
        await (update(medicationPlans)
              ..where((row) => row.syncId.equals(syncId)))
            .write(MedicationPlansCompanion(syncVersion: Value(version)));
      default:
        throw ArgumentError.value(entityType, 'entityType');
    }
  }

  Future<void> applyRemoteClinicalEntities(
    String entityType,
    List<Map<String, dynamic>> entities,
  ) async {
    await transaction(() async {
      for (final entity in entities) {
        final syncId = _string(entity['entityId']);
        final version = _int(entity['version']);
        final deleted = entity['deleted'] == true;
        final data = entity['payload'] is Map
            ? Map<String, dynamic>.from(entity['payload'] as Map)
            : const <String, dynamic>{};
        switch (entityType) {
          case 'vaccine':
            final existing = await (select(
              vaccines,
            )..where((row) => row.syncId.equals(syncId))).getSingleOrNull();
            if (deleted) {
              if (existing != null && existing.syncVersion < version) {
                await (delete(
                  vaccines,
                )..where((row) => row.id.equals(existing.id))).go();
              }
              continue;
            }
            if (existing != null && existing.syncVersion >= version) continue;
            final pet = await _petBySyncId(data['petSyncId']);
            if (pet == null) continue;
            final companion = VaccinesCompanion.insert(
              id: existing == null ? const Value.absent() : Value(existing.id),
              petId: pet.id,
              name: _string(data['name']),
              appliedAt: _date(data['appliedAt']),
              nextDoseAt: Value(_nullableDate(data['nextDoseAt'])),
              clinicName: Value(_nullableString(data['clinicName'])),
              batchNumber: Value(_nullableString(data['batchNumber'])),
              createdAt: Value(_date(data['createdAt'])),
              syncId: Value(syncId),
              syncVersion: Value(version),
            );
            await into(vaccines).insertOnConflictUpdate(companion);
          case 'weight':
            final existing = await (select(
              weightEntries,
            )..where((row) => row.syncId.equals(syncId))).getSingleOrNull();
            if (deleted) {
              if (existing != null && existing.syncVersion < version) {
                await (delete(
                  weightEntries,
                )..where((row) => row.id.equals(existing.id))).go();
              }
              continue;
            }
            if (existing != null && existing.syncVersion >= version) continue;
            final pet = await _petBySyncId(data['petSyncId']);
            if (pet == null) continue;
            final companion = WeightEntriesCompanion.insert(
              id: existing == null ? const Value.absent() : Value(existing.id),
              petId: pet.id,
              weight: _double(data['weight']),
              measuredAt: _date(data['measuredAt']),
              note: Value(_nullableString(data['note'])),
              createdAt: Value(_date(data['createdAt'])),
              syncId: Value(syncId),
              syncVersion: Value(version),
            );
            await into(weightEntries).insertOnConflictUpdate(companion);
          case 'medication':
            final existing = await (select(
              medicationPlans,
            )..where((row) => row.syncId.equals(syncId))).getSingleOrNull();
            if (deleted) {
              if (existing != null && existing.syncVersion < version) {
                await (delete(
                  medicationPlans,
                )..where((row) => row.id.equals(existing.id))).go();
              }
              continue;
            }
            if (existing != null && existing.syncVersion >= version) continue;
            final pet = await _petBySyncId(data['petSyncId']);
            if (pet == null) continue;
            final companion = MedicationPlansCompanion.insert(
              id: existing == null ? const Value.absent() : Value(existing.id),
              petId: pet.id,
              name: _string(data['name']),
              dosage: _string(data['dosage']),
              schedule: _string(data['schedule']),
              startAt: _date(data['startAt']),
              endAt: Value(_nullableDate(data['endAt'])),
              active: Value(data['active'] != false),
              lastTakenAt: Value(_nullableDate(data['lastTakenAt'])),
              notes: Value(_nullableString(data['notes'])),
              createdAt: Value(_date(data['createdAt'])),
              syncId: Value(syncId),
              syncVersion: Value(version),
            );
            await into(medicationPlans).insertOnConflictUpdate(companion);
          default:
            throw ArgumentError.value(entityType, 'entityType');
        }
      }
    });
  }

  Future<Pet?> _petBySyncId(Object? value) {
    final syncId = _string(value);
    return (select(
      pets,
    )..where((row) => row.syncId.equals(syncId))).getSingleOrNull();
  }

  Future<void> _recordSync(
    String entityType,
    int entityId,
    String operation, {
    Map<String, dynamic>? payload,
  }) {
    return into(syncOperations).insert(
      SyncOperationsCompanion.insert(
        entityType: entityType,
        entityId: Value(entityId),
        operation: operation,
        payload: Value(payload == null ? '' : jsonEncode(payload)),
      ),
    );
  }
}

String _newSyncId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is! List) {
    throw const FormatException('Backup sem uma lista de dados válida.');
  }
  return value.map((item) => Map<String, dynamic>.from(item as Map)).toList();
}

List<Map<String, dynamic>> _optionalMapList(Object? value) {
  if (value == null) return <Map<String, dynamic>>[];
  return _mapList(value);
}

String _string(Object? value, {String fallback = ''}) =>
    value is String && value.isNotEmpty ? value : fallback;

String? _nullableString(Object? value) => value is String ? value : null;

int _int(Object? value) => (value as num).toInt();

double _double(Object? value) => (value as num).toDouble();

double? _nullableDouble(Object? value) =>
    value is num ? value.toDouble() : null;

bool _bool(Object? value) => value == true;

DateTime _date(Object? value) => DateTime.parse(value as String);

DateTime? _nullableDate(Object? value) =>
    value is String && value.isNotEmpty ? DateTime.parse(value) : null;
