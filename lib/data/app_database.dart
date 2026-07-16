import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Pets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get species => text().withLength(min: 1, max: 40)();
  TextColumn get breed => text().withLength(min: 1, max: 120)();
  TextColumn get emoji => text().withDefault(const Constant('🐾'))();
  RealColumn get weight => real().withDefault(const Constant(0.0))();
  TextColumn get allergies => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
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
}

class WeightEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get petId => integer().references(Pets, #id)();
  RealColumn get weight => real()();
  DateTimeColumn get measuredAt => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().withLength(min: 3, max: 180)();
  TextColumn get plan => text().withDefault(const Constant('free_offline'))();
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

@DriftDatabase(
  tables: [
    Pets,
    Reminders,
    Vaccines,
    WeightEntries,
    UserProfiles,
    SyncOperations,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor, this.seedDemoData = false})
    : super(
        executor ??
            driftDatabase(
              name: 'aumiau_app',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.dart.js'),
              ),
            ),
      );

  AppDatabase.fromExecutor(super.executor, {this.seedDemoData = true});

  final bool seedDemoData;

  @override
  int get schemaVersion => 3;

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

  Future<void> saveProfile({
    required String name,
    required String email,
    String? plan,
  }) async {
    final profile = await loadProfile();
    if (profile == null) {
      final id = await into(userProfiles).insert(
        UserProfilesCompanion.insert(
          name: name,
          email: email,
          plan: Value(plan ?? 'free_offline'),
        ),
      );
      await _recordSync('profile', id, 'upsert');
      return;
    }
    await (update(
      userProfiles,
    )..where((row) => row.id.equals(profile.id))).write(
      UserProfilesCompanion(
        name: Value(name),
        email: Value(email),
        plan: plan == null ? const Value.absent() : Value(plan),
        updatedAt: Value(DateTime.now()),
      ),
    );
    await _recordSync('profile', profile.id, 'upsert');
  }

  Future<int> addPet({
    required String name,
    required String species,
    required String breed,
    required String emoji,
  }) async {
    final id = await into(pets).insert(
      PetsCompanion.insert(
        name: name,
        species: species,
        breed: breed,
        emoji: Value(emoji),
      ),
    );
    await _recordSync('pet', id, 'create');
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
      ),
    );
    await _recordSync('vaccine', id, 'create');
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
      ),
    );
    await _recordSync('weight', id, 'create');
    return id;
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
    await _recordSync('pet', id, 'update');
  }

  Future<void> updateReminderPetName(int petId, String petName) async {
    await (update(reminders)..where((row) => row.petId.equals(petId))).write(
      RemindersCompanion(petName: Value(petName)),
    );
    await _recordSync('pet', petId, 'update');
  }

  Future<void> deleteReminder(int id) async {
    await (delete(reminders)..where((row) => row.id.equals(id))).go();
    await _recordSync('reminder', id, 'delete');
  }

  Future<void> deleteVaccine(int id) async {
    await (delete(vaccines)..where((row) => row.id.equals(id))).go();
    await _recordSync('vaccine', id, 'delete');
  }

  Future<void> deletePet(int id) async {
    await transaction(() async {
      await (delete(reminders)..where((row) => row.petId.equals(id))).go();
      await (delete(vaccines)..where((row) => row.petId.equals(id))).go();
      await (delete(weightEntries)..where((row) => row.petId.equals(id))).go();
      await (delete(pets)..where((row) => row.id.equals(id))).go();
    });
    await _recordSync('pet', id, 'delete');
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

  Future<Map<String, dynamic>> exportSnapshot() async {
    final profile = await loadProfile();
    final databasePets = await loadPets();
    final databaseReminders = await loadReminders();
    final databaseVaccines = await loadVaccines();
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
              'createdAt': pet.createdAt.toIso8601String(),
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
            },
          )
          .toList(),
      'weights': databaseWeights
          .map(
            (weight) => {
              'id': weight.id,
              'petId': weight.petId,
              'weight': weight.weight,
              'measuredAt': weight.measuredAt.toIso8601String(),
              'note': weight.note,
              'createdAt': weight.createdAt.toIso8601String(),
            },
          )
          .toList(),
    };
  }

  Future<void> restoreSnapshot(Map<String, dynamic> snapshot) async {
    if (snapshot['format'] != 'aumiau-backup' || snapshot['version'] != 1) {
      throw const FormatException('Arquivo de backup incompatível.');
    }
    final petsData = _mapList(snapshot['pets']);
    final remindersData = _mapList(snapshot['reminders']);
    final vaccinesData = _mapList(snapshot['vaccines']);
    final weightsData = _mapList(snapshot['weights']);
    final profileData = snapshot['profile'] is Map
        ? Map<String, dynamic>.from(snapshot['profile'] as Map)
        : null;

    await transaction(() async {
      await delete(syncOperations).go();
      await delete(weightEntries).go();
      await delete(vaccines).go();
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
                  createdAt: Value(_date(pet['createdAt'])),
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
                ),
              )
              .toList(),
        );
      });
      await into(syncOperations).insert(
        SyncOperationsCompanion.insert(
          entityType: 'snapshot',
          operation: 'restore',
          payload: Value(jsonEncode({'version': snapshot['version']})),
        ),
      );
    });
  }

  Future<void> _recordSync(String entityType, int entityId, String operation) {
    return into(syncOperations).insert(
      SyncOperationsCompanion.insert(
        entityType: entityType,
        entityId: Value(entityId),
        operation: operation,
      ),
    );
  }
}

List<Map<String, dynamic>> _mapList(Object? value) {
  if (value is! List) {
    throw const FormatException('Backup sem uma lista de dados válida.');
  }
  return value.map((item) => Map<String, dynamic>.from(item as Map)).toList();
}

String _string(Object? value, {String fallback = ''}) =>
    value is String && value.isNotEmpty ? value : fallback;

String? _nullableString(Object? value) => value is String ? value : null;

int _int(Object? value) => (value as num).toInt();

double _double(Object? value) => (value as num).toDouble();

DateTime _date(Object? value) => DateTime.parse(value as String);

DateTime? _nullableDate(Object? value) =>
    value is String && value.isNotEmpty ? DateTime.parse(value) : null;
