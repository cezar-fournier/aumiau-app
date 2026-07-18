import 'package:aumiau_app/main.dart';
import 'package:aumiau_app/data/app_database.dart';
import 'package:aumiau_app/domain/product_plan.dart';
import 'package:aumiau_app/domain/partner_directory.dart';
import 'package:aumiau_app/services/pdf_service.dart';
import 'package:aumiau_app/services/pix_service.dart';
import 'package:aumiau_app/services/sync_service.dart';
import 'package:aumiau_app/services/sync_gateway.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aumiau_app/services/update_service.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

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
    await source.addPet(
      name: 'Nina',
      species: 'Gata',
      breed: 'SRD',
      emoji: '🐱',
    );
    final snapshot = await source.exportSnapshot();

    final target = AppDatabase.fromExecutor(NativeDatabase.memory());
    await target.restoreSnapshot(snapshot);
    final profile = await target.loadProfile();

    expect(profile?.name, 'Cezar AuMiau');
    expect(profile?.email, 'cezar@aumiau.app');
    expect((await target.loadPets()).any((pet) => pet.name == 'Nina'), isTrue);
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

    expect(batch.contractVersion, 'v1');
    expect(batch.snapshot['format'], 'aumiau-backup');
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
    expect(gateway.receivedPayload?['contractVersion'], 'v1');
    expect(await database.loadPendingSyncOperations(), isEmpty);
    await database.close();
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

    expect(find.text('Oi, Cezar Fournier! 👋'), findsOneWidget);
    expect(find.text('Cuidados de hoje'), findsOneWidget);
    expect(find.text('Vermífugo do Thor'), findsOneWidget);

    await database.close();
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
    var privacyOpened = false;
    var helpOpened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePage(
          profile: LocalProfile(name: 'Cezar', email: 'cezar@example.com'),
          onOpenNotifications: () => notificationsOpened = true,
          onOpenPrivacy: () => privacyOpened = true,
          onOpenHelp: () => helpOpened = true,
        ),
      ),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notificações'));
    await tester.tap(find.text('Privacidade e dados'));
    await tester.tap(find.text('Ajuda'));

    expect(notificationsOpened, isTrue);
    expect(privacyOpened, isTrue);
    expect(helpOpened, isTrue);
  });

  test('identifica nova versão publicada no GitHub', () {
    final service = UpdateService(client: _FakeHttpClient());
    expect(
      service.parseRelease({
        'tag_name': 'v0.3.6',
        'html_url':
            'https://github.com/cezar-fournier/aumiau-app/releases/tag/v0.3.6',
        'assets': const [],
      }),
      equals(null),
    );
    final update = service.parseRelease({
      'tag_name': 'v9.2.0',
      'html_url':
          'https://github.com/cezar-fournier/aumiau-app/releases/tag/v9.2.0',
      'body': 'Melhorias',
      'assets': [
        {
          'name': 'aumiau-v9.2.0.apk',
          'browser_download_url':
              'https://github.com/cezar-fournier/aumiau-app/releases/download/v9.2.0/aumiau.apk',
        },
      ],
    });

    expect(update?.version, '9.2.0');
    expect(update?.downloadUrl, contains('.apk'));
    expect(UpdateService.compareVersions('1.2.0', '1.1.9'), greaterThan(0));
  });
}

class _FakeHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(const Stream.empty(), 200);
  }
}

class _FakeSyncGateway implements SyncGateway {
  Map<String, dynamic>? receivedPayload;
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
    );
  }
}
