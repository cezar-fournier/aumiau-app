import 'package:aumiau_app/main.dart';
import 'package:aumiau_app/data/app_database.dart' hide Appointment, Pet;
import 'package:aumiau_app/data/account_scope.dart';
import 'package:aumiau_app/domain/product_plan.dart';
import 'package:aumiau_app/domain/partner_directory.dart';
import 'package:aumiau_app/domain/brazil_documents.dart';
import 'package:aumiau_app/services/pdf_service.dart';
import 'package:aumiau_app/services/pix_service.dart';
import 'package:aumiau_app/services/sync_service.dart';
import 'package:aumiau_app/services/sync_gateway.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:aumiau_app/services/update_service.dart';

void main() {
  test('novo pet aceita registros clínicos na sessão atual', () {
    final pet = Pet(
      name: 'Teste',
      species: 'Cão',
      breed: 'SRD',
      emoji: '🐾',
      weight: 0,
    );

    pet.vaccines.add(
      VaccineRecord(petId: 1, name: 'V4', appliedAt: DateTime.utc(2026, 8, 1)),
    );
    pet.weights.add(
      WeightRecord(petId: 1, weight: 4.5, measuredAt: DateTime.utc(2026, 8, 1)),
    );

    expect(pet.vaccines, hasLength(1));
    expect(pet.weights, hasLength(1));
  });

  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('gera armazenamento local estável e distinto para cada conta', () {
    final client = accountDatabaseName(' Cezar+Cliente@Gmail.com ');
    final sameClient = accountDatabaseName('cezar+cliente@gmail.com');
    final partner = accountDatabaseName('cezar+parceiro@gmail.com');

    expect(client, sameClient);
    expect(client, isNot(partner));
    expect(client, isNot(contains('gmail')));
    expect(
      accountPartnerDraftKey('cezar+cliente@gmail.com'),
      contains(client.substring(15)),
    );
  });

  test('bancos de contas distintas não compartilham dados locais', () async {
    final client = AppDatabase.fromExecutor(
      NativeDatabase.memory(),
      seedDemoData: false,
    );
    final partner = AppDatabase.fromExecutor(
      NativeDatabase.memory(),
      seedDemoData: false,
    );

    await client.saveProfile(
      name: 'Cliente de validação',
      email: 'cezar+cliente@gmail.com',
    );
    await client.addPet(
      name: 'Negão',
      species: 'Cão',
      breed: 'SRD',
      emoji: '🐾',
    );
    await partner.saveProfile(
      name: 'Parceiro operacional',
      email: 'cezar+parceiro@gmail.com',
    );

    expect((await client.loadPets()).single.name, 'Negão');
    expect(await partner.loadPets(), isEmpty);
    expect((await partner.loadProfile())?.email, 'cezar+parceiro@gmail.com');

    await client.close();
    await partner.close();
  });

  test('formata e valida CPF e CNPJ do cadastro Parceiro', () {
    expect(BrazilDocuments.formatCpfCnpj('41633032272'), '416.330.322-72');
    expect(
      BrazilDocuments.formatCpfCnpj('04368187000131'),
      '04.368.187/0001-31',
    );
    expect(BrazilDocuments.isValidCpf('416.330.322-72'), isTrue);
    expect(BrazilDocuments.isValidCnpj('04.368.187/0001-31'), isTrue);
    expect(BrazilDocuments.errorFor('111.111.111-11'), isNot(equals(null)));
    expect(BrazilDocuments.errorFor(''), isNot(equals(null)));
  });

  test('catálogo comercial aplica limites do Free Offline', () {
    final plan = ProductCatalog.freeOffline;

    expect(plan.isFreeOffline, isTrue);
    expect(plan.canAddPet(0), isTrue);
    expect(plan.canAddPet(1), isFalse);
    expect(plan.canAddReminder(0), isTrue);
    expect(plan.canAddReminder(1), isFalse);
    expect(ProductCatalog.fromCode('family_monthly').isFamily, isTrue);
  });

  test('gera payload Pix com chave CNPJ e CRC', () {
    final payload = PixService.buildPayload(
      amount: 8,
      txid: 'AUMIAUY1234567890',
    );

    expect(payload, startsWith('000201'));
    expect(payload, contains(PixService.merchantKey));
    expect(payload, contains('C A INFORMATICA'));
    expect(
      payload.substring(payload.length - 4),
      matches(RegExp(r'^[0-9A-F]{4}$')),
    );
  });

  test('banco comercial inicia vazio sem seed demonstrativo', () async {
    final database = AppDatabase.fromExecutor(
      NativeDatabase.memory(),
      seedDemoData: false,
    );

    expect(await database.loadPets(), isEmpty);
    expect(await database.loadReminders(), isEmpty);
    expect(await database.loadProfile(), equals(null));
    await database.close();
  });

  test('persiste validade do plano Family para uso offline', () async {
    final database = AppDatabase.fromExecutor(
      NativeDatabase.memory(),
      seedDemoData: false,
    );
    final validUntil = DateTime(2026, 8, 17);
    await database.saveProfile(
      name: 'César Fonseca',
      email: 'cesar@example.com',
      plan: ProductCatalog.family.code,
      familyValidUntil: validUntil,
      preserveFamilyValidUntil: false,
    );

    final profile = await database.loadProfile();
    expect(profile?.plan, ProductCatalog.family.code);
    expect(profile?.familyValidUntil, validUntil);
    await database.close();
  });

  test(
    'atualização de plano recebida do servidor não cria novo upload',
    () async {
      final database = AppDatabase.fromExecutor(
        NativeDatabase.memory(),
        seedDemoData: false,
      );
      await database.saveProfile(
        name: 'Conta sincronizada',
        email: 'conta@aumiau.app',
        recordSyncOperation: false,
      );

      expect(await database.loadPendingSyncOperations(), isEmpty);
      await database.close();
    },
  );

  test('salva pet, vacina e reagendamento no banco local', () async {
    final database = AppDatabase.fromExecutor(NativeDatabase.memory());
    final pets = await database.loadPets();
    final thor = pets.firstWhere((pet) => pet.name == 'Thor');

    final petId = await database.addPet(
      name: 'Nina',
      species: 'Gata',
      breed: 'SRD',
      emoji: '🐱',
      birthDate: DateTime(2022, 4, 10),
      sex: 'Fêmea',
      color: 'Tigrada',
      characteristics: 'Dócil e curiosa',
      hasPedigree: true,
      pedigreeNumber: 'PED-123',
      microchip: '123456789',
      size: 'Pequeno',
      reproductiveStatus: 'Castrado(a)',
      bodyConditionScore: 5.5,
      clinicReference: 'Clínica Amigo Fiel',
      veterinarianReference: 'Dra. Marina',
      documentNotes: 'Carteira física conferida',
      photoData: 'AQID',
      weight: 4.2,
      allergies: 'Frango',
    );
    final vaccineId = await database.addVaccine(
      petId: thor.id,
      name: 'Gripe canina',
      appliedAt: DateTime(2026, 7, 14),
      nextDoseAt: DateTime(2027, 7, 14),
    );
    final weightId = await database.addWeight(
      petId: thor.id,
      weight: 18.6,
      measuredAt: DateTime(2026, 7, 15),
      note: 'Consulta',
    );
    final preventiveId = await database.addPreventive(
      petId: petId,
      category: 'Antiparasitário',
      product: 'Produto de teste',
      appliedAt: DateTime(2026, 7, 16),
      nextDueAt: DateTime(2026, 10, 16),
    );
    final medicationId = await database.addMedicationPlan(
      petId: petId,
      name: 'Suplemento de teste',
      dosage: '1 comprimido',
      schedule: 'A cada 12 horas',
      startAt: DateTime(2026, 7, 16),
    );
    final invitationId = await database.addFamilyInvitation(
      petId: petId,
      email: 'cuidador@example.com',
      role: 'Cuidador',
      permissions: 'saude_rotina',
      expiresAt: DateTime(2026, 7, 23),
    );
    final appointmentId = await database.addAppointment(
      petId: petId,
      partnerName: 'Clínica de teste',
      service: 'Consulta',
      scheduledAt: DateTime(2026, 7, 20, 10),
    );

    final reminders = await database.loadReminders();
    final reminder = reminders.first;
    final nextDate = reminder.dueAt.add(Duration(days: reminder.intervalDays));
    await database.updateReminderTitle(reminder.id, 'Rotina atualizada');
    await database.completeReminder(reminder.id, nextDate);

    expect((await database.loadPets()).any((pet) => pet.id == petId), isTrue);
    final nina = (await database.loadPets()).firstWhere(
      (pet) => pet.id == petId,
    );
    expect(nina.birthDate, DateTime(2022, 4, 10));
    expect(nina.sex, 'Fêmea');
    expect(nina.color, 'Tigrada');
    expect(nina.characteristics, 'Dócil e curiosa');
    expect(nina.hasPedigree, isTrue);
    expect(nina.pedigreeNumber, 'PED-123');
    expect(nina.microchip, '123456789');
    expect(nina.size, 'Pequeno');
    expect(nina.reproductiveStatus, 'Castrado(a)');
    expect(nina.bodyConditionScore, 5.5);
    expect(nina.clinicReference, 'Clínica Amigo Fiel');
    expect(nina.veterinarianReference, 'Dra. Marina');
    expect(nina.documentNotes, 'Carteira física conferida');
    expect(nina.photoData, 'AQID');
    expect(nina.weight, 4.2);
    expect(nina.allergies, 'Frango');
    expect(
      (await database.loadPreventiveRecords()).any(
        (record) => record.id == preventiveId,
      ),
      isTrue,
    );
    expect(
      (await database.loadMedicationPlans()).any(
        (plan) => plan.id == medicationId,
      ),
      isTrue,
    );
    await database.markMedicationTaken(medicationId);
    expect(
      (await database.loadMedicationPlans())
          .firstWhere((plan) => plan.id == medicationId)
          .lastTakenAt,
      isNot(equals(null)),
    );
    expect(
      (await database.loadFamilyInvitations()).any(
        (invitation) => invitation.id == invitationId,
      ),
      isTrue,
    );
    expect(
      (await database.loadAppointments()).any(
        (appointment) => appointment.id == appointmentId,
      ),
      isTrue,
    );
    await database.updateAppointmentStatus(appointmentId, 'check_in');
    expect(
      (await database.loadAppointments())
          .firstWhere((appointment) => appointment.id == appointmentId)
          .status,
      'check_in',
    );
    expect(
      (await database.loadVaccines()).any(
        (vaccine) => vaccine.name == 'Gripe canina',
      ),
      isTrue,
    );
    expect(
      (await database.loadReminders())
          .firstWhere((item) => item.id == reminder.id)
          .dueAt,
      nextDate,
    );

    expect(
      (await database.loadReminders())
          .firstWhere((item) => item.id == reminder.id)
          .title,
      'Rotina atualizada',
    );
    expect(
      (await database.loadWeights()).any((weight) => weight.id == weightId),
      isTrue,
    );

    await database.deleteVaccine(vaccineId);
    expect(
      (await database.loadVaccines()).any((vaccine) => vaccine.id == vaccineId),
      isFalse,
    );

    await database.deletePet(petId);
    expect((await database.loadPets()).any((pet) => pet.id == petId), isFalse);

    await database.close();
  });

  test('busca parceiros por urgência e ordena por proximidade', () {
    final partners = PartnerDirectory.search(
      urgencyOnly: true,
      latitude: -3.1190,
      longitude: -60.0217,
    );

    expect(partners, hasLength(1));
    expect(partners.single.acceptsUrgency, isTrue);
    expect(partners.single.distanceFrom(-3.1190, -60.0217), lessThan(0.01));
  });

  test('gera PDF real do histórico', () async {
    final bytes = await PdfService.buildHealthHistoryPdf(
      pets: const [
        PdfPetData(
          name: 'Thor',
          species: 'Cão',
          breed: 'Vira-lata',
          weight: 18.2,
          vaccines: [],
          weights: [],
        ),
      ],
      timeline: const [
        PdfTimelineData(
          title: 'Peso registrado',
          subtitle: 'Thor',
          date: '15/07',
        ),
      ],
    );

    expect(bytes.take(4).toList(), [37, 80, 68, 70]);
    expect(bytes.length, greaterThan(500));
  });

  test('exporta e restaura backup local com fila de sincronização', () async {
    final source = AppDatabase.fromExecutor(NativeDatabase.memory());
    await source.saveProfile(name: 'Cezar AuMiau', email: 'cezar@aumiau.app');
    final petId = await source.addPet(
      name: 'Nina',
      species: 'Gata',
      breed: 'SRD',
      emoji: '🐱',
    );
    await source.addVaccine(
      petId: petId,
      name: 'V4',
      appliedAt: DateTime.utc(2026, 8, 1),
    );
    await source.addWeight(
      petId: petId,
      weight: 4.2,
      measuredAt: DateTime.utc(2026, 8, 1),
    );
    await source.addMedicationPlan(
      petId: petId,
      name: 'Medicamento',
      dosage: '1 comprimido',
      schedule: 'Uma vez ao dia',
      startAt: DateTime.utc(2026, 8, 1),
    );
    final snapshot = await source.exportSnapshot();

    expect(
      (snapshot['vaccines'] as List).any(
        (item) => (item as Map)['name'] == 'V4' && item['petId'] == petId,
      ),
      isTrue,
    );
    expect(
      (snapshot['weights'] as List).any(
        (item) => (item as Map)['weight'] == 4.2 && item['petId'] == petId,
      ),
      isTrue,
    );
    expect(
      (snapshot['medications'] as List).any(
        (item) =>
            (item as Map)['name'] == 'Medicamento' && item['petId'] == petId,
      ),
      isTrue,
    );

    final target = AppDatabase.fromExecutor(NativeDatabase.memory());
    await target.restoreSnapshot(snapshot);
    final profile = await target.loadProfile();

    expect(profile?.name, 'Cezar AuMiau');
    expect(profile?.email, 'cezar@aumiau.app');
    expect((await target.loadPets()).any((pet) => pet.name == 'Nina'), isTrue);
    expect(
      (await target.loadVaccines()).any(
        (item) => item.name == 'V4' && item.petId == petId,
      ),
      isTrue,
    );
    expect(
      (await target.loadWeights()).any(
        (item) => item.weight == 4.2 && item.petId == petId,
      ),
      isTrue,
    );
    expect(
      (await target.loadMedicationPlans()).any(
        (item) => item.name == 'Medicamento' && item.petId == petId,
      ),
      isTrue,
    );
    expect(
      (await target.loadPendingSyncOperations()).single.operation,
      'restore',
    );

    await source.close();
    await target.close();
  });

  test('monta lote de sincronização e confirma operações locais', () async {
    final database = AppDatabase.fromExecutor(NativeDatabase.memory());
    final petId = await database.addPet(
      name: 'Nina',
      species: 'Gata',
      breed: 'SRD',
      emoji: '🐱',
    );
    final service = SyncService(database);
    final batch = await service.buildPendingBatch();

    expect(batch.contractVersion, 'v2');
    expect(batch.baseRevision, 0);
    expect(batch.toJson()['generatedAt'], endsWith('Z'));
    expect(
      (batch.toJson()['operations'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .first['occurredAt'],
      endsWith('Z'),
    );
    expect(batch.snapshot['format'], 'aumiau-backup');
    expect(batch.snapshot.containsKey('vaccines'), isFalse);
    expect(batch.snapshot.containsKey('weights'), isFalse);
    expect(batch.snapshot.containsKey('medications'), isFalse);
    expect(batch.operations.any((item) => item.entityId == petId), isTrue);

    await service.acknowledge(batch);
    expect(await database.loadPendingSyncOperations(), isEmpty);
    await database.close();
  });

  test('sincroniza com gateway injetado e confirma o token', () async {
    final database = AppDatabase.fromExecutor(NativeDatabase.memory());
    await database.addPet(
      name: 'Nina',
      species: 'Gata',
      breed: 'SRD',
      emoji: '🐱',
    );
    final gateway = _FakeSyncGateway();
    final service = SyncService(database);

    final acknowledgement = await service.synchronize(
      gateway: gateway,
      accessToken: 'token-de-teste',
    );

    expect(acknowledgement?.acknowledgedOperationIds, isNotEmpty);
    expect(gateway.receivedToken, 'token-de-teste');
    expect(gateway.receivedEntityChanges, hasLength(1));
    expect(gateway.receivedEntityChanges.single['entityType'], 'pet');
    expect(
      (gateway.receivedEntityChanges.single['payload'] as Map)['name'],
      'Nina',
    );
    expect(await database.loadSyncRevision(), 0);
    expect(await database.loadPendingSyncOperations(), isEmpty);
    await database.close();
  });

  test('restaura snapshot remoto quando o banco local está vazio', () async {
    final source = AppDatabase.fromExecutor(
      NativeDatabase.memory(),
      seedDemoData: false,
    );
    await source.saveProfile(name: 'Conta remota', email: 'conta@aumiau.app');
    await source.addPet(
      name: 'Nina',
      species: 'Gata',
      breed: 'SRD',
      emoji: '🐾',
    );
    final remoteSnapshot = await source.exportSnapshot();

    final target = AppDatabase.fromExecutor(
      NativeDatabase.memory(),
      seedDemoData: false,
    );
    final gateway = _FakeSyncGateway(
      remoteSnapshot: RemoteSnapshot(snapshot: remoteSnapshot, revision: 7),
    );
    await SyncService(
      target,
    ).pullLatest(gateway: gateway, accessToken: 'token-de-teste');

    expect((await target.loadPets()).single.name, 'Nina');
    expect(await target.loadSyncRevision(), 7);
    expect(await target.loadPendingSyncOperations(), isEmpty);

    await source.close();
    await target.close();
  });

  test(
    'mescla pets criados em aparelhos diferentes sem colisão local',
    () async {
      final gateway = _FakeSyncGateway();
      final firstDevice = AppDatabase.fromExecutor(
        NativeDatabase.memory(),
        seedDemoData: false,
      );
      final secondDevice = AppDatabase.fromExecutor(
        NativeDatabase.memory(),
        seedDemoData: false,
      );

      await firstDevice.addPet(
        name: 'Nina',
        species: 'Gata',
        breed: 'SRD',
        emoji: '🐾',
      );
      await SyncService(
        firstDevice,
      ).synchronize(gateway: gateway, accessToken: 'token');
      await SyncService(
        secondDevice,
      ).synchronize(gateway: gateway, accessToken: 'token');

      await secondDevice.addPet(
        name: 'Thor',
        species: 'Cão',
        breed: 'SRD',
        emoji: '🐾',
      );
      await SyncService(
        secondDevice,
      ).synchronize(gateway: gateway, accessToken: 'token');
      await SyncService(
        firstDevice,
      ).synchronize(gateway: gateway, accessToken: 'token');

      expect((await firstDevice.loadPets()).map((pet) => pet.name).toSet(), {
        'Nina',
        'Thor',
      });
      expect((await secondDevice.loadPets()).map((pet) => pet.name).toSet(), {
        'Nina',
        'Thor',
      });

      await firstDevice.close();
      await secondDevice.close();
    },
  );

  test('compacta várias alterações offline do mesmo pet', () async {
    final database = AppDatabase.fromExecutor(
      NativeDatabase.memory(),
      seedDemoData: false,
    );
    final gateway = _FakeSyncGateway();
    final petId = await database.addPet(
      name: 'Nome inicial',
      species: 'Cão',
      breed: 'SRD',
      emoji: '🐾',
    );
    await database.updatePetName(petId, 'Nome intermediário');
    await database.updatePetName(petId, 'Nome definitivo');

    final acknowledgement = await SyncService(
      database,
    ).synchronize(gateway: gateway, accessToken: 'token');

    expect(gateway.receivedEntityChanges, hasLength(1));
    expect(
      (gateway.receivedEntityChanges.single['payload'] as Map)['name'],
      'Nome definitivo',
    );
    expect(acknowledgement?.acknowledgedOperationIds, hasLength(1));
    expect(await database.loadPendingSyncOperations(), isEmpty);

    await database.close();
  });

  test('atualiza e remove a foto do pet com sincronização', () async {
    final database = AppDatabase.fromExecutor(
      NativeDatabase.memory(),
      seedDemoData: false,
    );
    final gateway = _FakeSyncGateway();
    final petId = await database.addPet(
      name: 'Nina',
      species: 'Gata',
      breed: 'SRD',
      emoji: '🐱',
      photoData: 'AQID',
    );

    await database.updatePetProfile(petId, name: 'Nina', photoData: 'BAUG');
    expect((await database.loadPets()).single.photoData, 'BAUG');

    await SyncService(
      database,
    ).synchronize(gateway: gateway, accessToken: 'token');
    expect(
      (gateway.receivedEntityChanges.single['payload'] as Map)['photoData'],
      'BAUG',
    );

    await database.updatePetProfile(petId, name: 'Nina', photoData: null);
    expect((await database.loadPets()).single.photoData, equals(null));

    await database.close();
  });

  test('propaga exclusão de pet por tombstone', () async {
    final gateway = _FakeSyncGateway();
    final firstDevice = AppDatabase.fromExecutor(
      NativeDatabase.memory(),
      seedDemoData: false,
    );
    final secondDevice = AppDatabase.fromExecutor(
      NativeDatabase.memory(),
      seedDemoData: false,
    );
    final petId = await firstDevice.addPet(
      name: 'Nina',
      species: 'Gata',
      breed: 'SRD',
      emoji: '🐾',
    );
    await SyncService(
      firstDevice,
    ).synchronize(gateway: gateway, accessToken: 'token');
    await SyncService(
      secondDevice,
    ).synchronize(gateway: gateway, accessToken: 'token');

    await firstDevice.deletePet(petId);
    await SyncService(
      firstDevice,
    ).synchronize(gateway: gateway, accessToken: 'token');
    await SyncService(
      secondDevice,
    ).synchronize(gateway: gateway, accessToken: 'token');

    expect(await firstDevice.loadPets(), isEmpty);
    expect(await secondDevice.loadPets(), isEmpty);

    await firstDevice.close();
    await secondDevice.close();
  });

  test('mescla vacinas, pesos e medicamentos entre aparelhos', () async {
    final gateway = _FakeSyncGateway();
    final firstDevice = AppDatabase.fromExecutor(
      NativeDatabase.memory(),
      seedDemoData: false,
    );
    final secondDevice = AppDatabase.fromExecutor(
      NativeDatabase.memory(),
      seedDemoData: false,
    );
    final petId = await firstDevice.addPet(
      name: 'Luna',
      species: 'Gata',
      breed: 'SRD',
      emoji: '🐾',
    );
    await firstDevice.addVaccine(
      petId: petId,
      name: 'V4',
      appliedAt: DateTime.utc(2026, 8, 1),
      nextDoseAt: DateTime.utc(2027, 8, 1),
      clinicName: 'Clínica AuMiau',
    );
    await firstDevice.addWeight(
      petId: petId,
      weight: 4.7,
      measuredAt: DateTime.utc(2026, 8, 1),
      note: 'Peso estável',
    );
    final medicationId = await firstDevice.addMedicationPlan(
      petId: petId,
      name: 'Medicamento teste',
      dosage: '1 comprimido',
      schedule: 'A cada 12 horas',
      startAt: DateTime.utc(2026, 8, 1),
    );
    await SyncService(
      firstDevice,
    ).synchronize(gateway: gateway, accessToken: 'token');
    await SyncService(
      secondDevice,
    ).synchronize(gateway: gateway, accessToken: 'token');

    expect((await secondDevice.loadVaccines()).single.name, 'V4');
    expect((await secondDevice.loadWeights()).single.weight, 4.7);
    expect(
      (await secondDevice.loadMedicationPlans()).single.name,
      'Medicamento teste',
    );

    await firstDevice.markMedicationTaken(medicationId);
    await SyncService(
      firstDevice,
    ).synchronize(gateway: gateway, accessToken: 'token');
    await SyncService(
      secondDevice,
    ).synchronize(gateway: gateway, accessToken: 'token');
    expect(
      (await secondDevice.loadMedicationPlans()).single.lastTakenAt == null,
      isFalse,
    );

    await firstDevice.close();
    await secondDevice.close();
  });

  test('propaga tombstones das entidades clínicas', () async {
    final gateway = _FakeSyncGateway();
    final firstDevice = AppDatabase.fromExecutor(
      NativeDatabase.memory(),
      seedDemoData: false,
    );
    final secondDevice = AppDatabase.fromExecutor(
      NativeDatabase.memory(),
      seedDemoData: false,
    );
    final petId = await firstDevice.addPet(
      name: 'Bento',
      species: 'Cão',
      breed: 'SRD',
      emoji: '🐾',
    );
    final vaccineId = await firstDevice.addVaccine(
      petId: petId,
      name: 'Antirrábica',
      appliedAt: DateTime.utc(2026, 8, 1),
    );
    final weightId = await firstDevice.addWeight(
      petId: petId,
      weight: 12.3,
      measuredAt: DateTime.utc(2026, 8, 1),
    );
    final medicationId = await firstDevice.addMedicationPlan(
      petId: petId,
      name: 'Protetor',
      dosage: '5 ml',
      schedule: 'Uma vez ao dia',
      startAt: DateTime.utc(2026, 8, 1),
    );
    await SyncService(
      firstDevice,
    ).synchronize(gateway: gateway, accessToken: 'token');
    await SyncService(
      secondDevice,
    ).synchronize(gateway: gateway, accessToken: 'token');

    await firstDevice.deleteVaccine(vaccineId);
    await firstDevice.deleteWeight(weightId);
    await firstDevice.deleteMedicationPlan(medicationId);
    await SyncService(
      firstDevice,
    ).synchronize(gateway: gateway, accessToken: 'token');
    await SyncService(
      secondDevice,
    ).synchronize(gateway: gateway, accessToken: 'token');

    expect(await secondDevice.loadVaccines(), isEmpty);
    expect(await secondDevice.loadWeights(), isEmpty);
    expect(await secondDevice.loadMedicationPlans(), isEmpty);
    expect(
      gateway.remoteEntities
          .where(
            (entity) =>
                const {
                  'vaccine',
                  'weight',
                  'medication',
                }.contains(entity['entityType']) &&
                entity['deleted'] == true,
          )
          .length,
      3,
    );

    await firstDevice.close();
    await secondDevice.close();
  });

  testWidgets('exibe o dashboard inicial do AuMiau', (tester) async {
    final database = AppDatabase.fromExecutor(NativeDatabase.memory());
    await tester.pumpWidget(
      AumiauApp(database: database, enableUpdateChecks: false),
    );
    // A marca da autenticação possui animações contínuas; aguarde um quadro
    // estável de renderização em vez de esperar que a tela fique settled.
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Usar aplicativo offline'), findsOneWidget);
    await tester.ensureVisible(find.text('Usar aplicativo offline'));
    await tester.tap(find.text('Usar aplicativo offline'));
    await tester.pumpAndSettle();
    expect(find.text('Cliente AuMiau'), findsOneWidget);
    await tester.tap(find.text('Cliente AuMiau'));
    await tester.pumpAndSettle();

    expect(find.text('Oi, Cezar Fournier! 👋'), findsOneWidget);
    expect(find.text('Cuidados de hoje'), findsOneWidget);
    expect(find.text('Vermífugo do Thor'), findsOneWidget);

    await database.close();
  });

  testWidgets('exibe informações de confiança e do desenvolvedor', (
    tester,
  ) async {
    final database = AppDatabase.fromExecutor(NativeDatabase.memory());
    await tester.pumpWidget(
      AumiauApp(database: database, enableUpdateChecks: false),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Dados protegidos'), findsOneWidget);
    expect(find.text('Cezar Fournier'), findsOneWidget);
    expect(find.text('BETA'), findsOneWidget);
    await tester.ensureVisible(find.text('Dados protegidos'));
    await tester.tap(find.text('Dados protegidos'));
    await tester.pumpAndSettle();

    expect(find.text('Confiança e transparência'), findsOneWidget);
    expect(find.text('CNPJ: 04.368.187/0001-31'), findsOneWidget);
    expect(find.text('Entendi'), findsOneWidget);

    await database.close();
  });

  testWidgets('cancelar cadastro profissional fecha o diálogo sem crash', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PartnerWorkspacePage(
          email: 'cliente@exemplo.com',
          onRegistrationSubmitted: () {},
          onSwitchToClient: () {},
          onLogout: () async {},
          onOpenDeveloper: () {},
          onOpenHelp: () {},
          onOpenPrivacy: () {},
        ),
      ),
    );

    await tester.tap(find.text('Criar cadastro profissional'));
    await tester.pumpAndSettle();
    expect(find.text('Cadastro profissional'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Cadastro profissional'), findsNothing);
    expect(find.text('AuMiau Parceiro'), findsOneWidget);
  });

  testWidgets('atendimento concluído permite preparar receituário comum', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: PartnerWorkspacePage(
          email: 'parceiro@exemplo.com',
          verificationStatus: 'approved',
          profileStatus: 'active',
          onRegistrationSubmitted: () {},
          onLoadAppointments: () async => [
            Appointment(
              id: 42,
              petId: 7,
              petName: 'Amora',
              clientName: 'Responsável',
              partnerName: 'Clínica',
              service: 'Consulta veterinária',
              scheduledAt: DateTime(2026, 8, 3, 10),
              status: 'completed',
              createdAt: DateTime(2026, 8, 3, 9),
            ),
          ],
          onCreatePrescription: (_, _) async => 'Rascunho preparado.',
          onSwitchToClient: () {},
          onLogout: () async {},
          onOpenDeveloper: () {},
          onOpenHelp: () {},
          onOpenPrivacy: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agenda').last);
    await tester.pumpAndSettle();
    expect(find.text('Criar receituário'), findsOneWidget);
    await tester.tap(find.text('Criar receituário'));
    await tester.pumpAndSettle();
    expect(find.text('Novo receituário · Amora'), findsOneWidget);
    expect(
      find.textContaining('sem validade para dispensação'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Antimicrobianos e controlados'),
      findsOneWidget,
    );
  });

  testWidgets('Hoje usa primeiro e último nome do cadastro', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TodayPage(
          today: DateTime(2026, 7, 18),
          profileName: 'César Maria Fonseca',
          pets: const [],
          reminders: const [],
          onComplete: (_) {},
          onAddReminder: () {},
          onEditReminder: (_) {},
          onDeleteReminder: (_) {},
        ),
      ),
    );

    expect(find.text('Oi, César Fonseca! 👋'), findsOneWidget);
    expect(find.textContaining('@'), findsNothing);
  });

  testWidgets('Hoje identifica o Family ativo no banner', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TodayPage(
          today: DateTime(2026, 7, 18),
          profileName: 'César Fonseca',
          isFamily: true,
          pets: const [],
          reminders: const [],
          onComplete: (_) {},
          onAddReminder: () {},
          onEditReminder: (_) {},
          onDeleteReminder: (_) {},
        ),
      ),
    );

    expect(find.text('FAMILY ATIVO'), findsOneWidget);
    expect(find.text('PLANO GRATUITO'), findsNothing);
  });

  testWidgets('atalhos do perfil executam suas ações', (tester) async {
    var notificationsOpened = false;
    var updatesOpened = false;
    var privacyOpened = false;
    var helpOpened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePage(
          profile: LocalProfile(name: 'Cezar', email: 'cezar@example.com'),
          onOpenNotifications: () => notificationsOpened = true,
          onCheckUpdates: () => updatesOpened = true,
          onOpenPrivacy: () => privacyOpened = true,
          onOpenHelp: () => helpOpened = true,
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notificações'));
    await tester.tap(find.text('Atualizar aplicativo'));
    await tester.tap(find.text('Privacidade e dados'));
    await tester.tap(find.text('Ajuda'));

    expect(notificationsOpened, isTrue);
    expect(updatesOpened, isTrue);
    expect(privacyOpened, isTrue);
    expect(helpOpened, isTrue);
  });

  test('canal de atualização não usa mais GitHub Releases', () {
    const service = UpdateService();
    expect(service.usesGooglePlayUpdates, isFalse);
  });
}

class _FakeSyncGateway implements SyncGateway {
  _FakeSyncGateway({this.remoteSnapshot});

  final RemoteSnapshot? remoteSnapshot;
  Map<String, dynamic>? receivedPayload;
  List<Map<String, dynamic>> receivedEntityChanges = [];
  final List<Map<String, dynamic>> remoteEntities = [];
  String? receivedToken;

  @override
  Future<RegistrationResult> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? birthDate,
    required bool termsAccepted,
  }) async {
    return const RegistrationResult(
      email: 'teste@aumiau.app',
      message: 'Conta criada.',
      session: SyncAuthSession(accessToken: 'fake-access-token'),
    );
  }

  @override
  Future<SyncAuthSession> verifyEmail({
    required String email,
    required String token,
  }) async {
    return const SyncAuthSession(accessToken: 'fake-access-token');
  }

  @override
  Future<SyncAuthSession> signIn({
    required String email,
    required String password,
  }) async {
    return const SyncAuthSession(accessToken: 'fake-access-token');
  }

  @override
  Future<SyncAuthSession> refreshSession({required String refreshToken}) async {
    return const SyncAuthSession(accessToken: 'refreshed-access-token');
  }

  @override
  Future<String> requestPasswordReset({required String email}) async {
    return 'Token enviado.';
  }

  @override
  Future<String> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    return 'Senha atualizada.';
  }

  @override
  Future<void> logout({required String accessToken}) async {}

  @override
  Future<void> deleteAccount({
    required String accessToken,
    required String password,
    required String confirmation,
  }) async {}

  @override
  Future<RemoteSnapshot> pullSnapshot({required String accessToken}) async =>
      remoteSnapshot ?? const RemoteSnapshot(snapshot: null, revision: 0);

  @override
  Future<List<EntitySyncAck>> pushEntities({
    required List<Map<String, dynamic>> changes,
    required String accessToken,
  }) async {
    receivedToken = accessToken;
    receivedEntityChanges = changes;
    final versions = <String, int>{};
    for (final change in changes) {
      final existing = remoteEntities.cast<Map<String, dynamic>?>().firstWhere(
        (item) => item?['entityId'] == change['entityId'],
        orElse: () => null,
      );
      final version = ((existing?['version'] as num?)?.toInt() ?? 0) + 1;
      versions[change['entityId'] as String] = version;
      remoteEntities.removeWhere(
        (item) => item['entityId'] == change['entityId'],
      );
      remoteEntities.add({
        'entityType': change['entityType'],
        'entityId': change['entityId'],
        'version': version,
        'deleted': change['deleted'],
        'payload': change['payload'],
      });
    }
    return changes
        .map(
          (change) => EntitySyncAck(
            operationId: change['operationId'] as int,
            entityId: change['entityId'] as String,
            version: versions[change['entityId']]!,
          ),
        )
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> pullEntities({
    required String entityType,
    required String accessToken,
  }) async =>
      remoteEntities.where((item) => item['entityType'] == entityType).toList();

  @override
  Future<SyncBatchAck> pushBatch({
    required Map<String, dynamic> payload,
    required String accessToken,
  }) async {
    receivedPayload = payload;
    receivedToken = accessToken;
    final operations = payload['operations'] as List<dynamic>;
    return SyncBatchAck(
      acknowledgedOperationIds: operations
          .map((item) => (item as Map<String, dynamic>)['id'] as int)
          .toList(),
      revision: 1,
    );
  }
}
