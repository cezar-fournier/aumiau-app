import 'package:aumiau_app/main.dart';
import 'package:aumiau_app/data/app_database.dart';
import 'package:aumiau_app/services/pdf_service.dart';
import 'package:aumiau_app/services/sync_service.dart';
import 'package:aumiau_app/services/sync_gateway.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:aumiau_app/services/update_service.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('salva pet, vacina e reagendamento no banco local', () async {
    final database = AppDatabase.fromExecutor(NativeDatabase.memory());
    final pets = await database.loadPets();
    final thor = pets.firstWhere((pet) => pet.name == 'Thor');

    final petId = await database.addPet(
      name: 'Nina',
      species: 'Gata',
      breed: 'SRD',
      emoji: '🐱',
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

    final reminders = await database.loadReminders();
    final reminder = reminders.first;
    final nextDate = reminder.dueAt.add(Duration(days: reminder.intervalDays));
    await database.updateReminderTitle(reminder.id, 'Rotina atualizada');
    await database.completeReminder(reminder.id, nextDate);

    expect((await database.loadPets()).any((pet) => pet.id == petId), isTrue);
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
    await tester.pumpAndSettle();

    expect(find.text('Oi, Cezar! 👋'), findsOneWidget);
    expect(find.text('Cuidados de hoje'), findsOneWidget);
    expect(find.text('Vermífugo do Thor'), findsOneWidget);

    await database.close();
  });

  test('identifica nova versão publicada no GitHub', () {
    final service = UpdateService(client: _FakeHttpClient());
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
