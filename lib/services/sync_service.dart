import 'dart:convert';

import '../data/app_database.dart';
import 'sync_gateway.dart';

class SyncOperationData {
  const SyncOperationData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.occurredAt,
    required this.payload,
  });

  final int id;
  final String entityType;
  final int? entityId;
  final String operation;
  final DateTime occurredAt;
  final String payload;

  Map<String, dynamic> toJson() => {
    'id': id,
    'entityType': entityType,
    'entityId': entityId,
    'operation': operation,
    'occurredAt': occurredAt.toUtc().toIso8601String(),
    'payload': payload,
  };
}

class SyncBatch {
  const SyncBatch({
    required this.contractVersion,
    required this.generatedAt,
    required this.baseRevision,
    required this.snapshot,
    required this.operations,
  });

  final String contractVersion;
  final DateTime generatedAt;
  final int baseRevision;
  final Map<String, dynamic> snapshot;
  final List<SyncOperationData> operations;

  List<int> get operationIds => operations.map((item) => item.id).toList();

  Map<String, dynamic> toJson() => {
    'contractVersion': contractVersion,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'baseRevision': baseRevision,
    'snapshot': snapshot,
    'operations': operations.map((item) => item.toJson()).toList(),
  };
}

class SyncService {
  SyncService(this.database);

  final AppDatabase database;

  Future<SyncBatch> buildPendingBatch() async {
    final operations = await database.loadPendingSyncOperations();
    final snapshot = await database.exportSnapshot(
      includeGranularClinicalEntities: false,
    );
    final revision = await database.loadSyncRevision();
    return SyncBatch(
      contractVersion: 'v2',
      generatedAt: DateTime.now().toUtc(),
      baseRevision: revision,
      snapshot: snapshot,
      operations: operations
          .map(
            (operation) => SyncOperationData(
              id: operation.id,
              entityType: operation.entityType,
              entityId: operation.entityId,
              operation: operation.operation,
              occurredAt: operation.occurredAt,
              payload: operation.payload,
            ),
          )
          .toList(),
    );
  }

  Future<void> acknowledge(SyncBatch batch) {
    return database.markSyncOperationsAsSynced(batch.operationIds);
  }

  Future<SyncBatchAck?> synchronize({
    required SyncGateway gateway,
    required String accessToken,
  }) async {
    final granularAcknowledgements = <EntitySyncAck>[
      ...await _synchronizePets(gateway: gateway, accessToken: accessToken),
    ];
    for (final entityType in const ['vaccine', 'weight', 'medication']) {
      granularAcknowledgements.addAll(
        await _synchronizeClinicalEntity(
          entityType: entityType,
          gateway: gateway,
          accessToken: accessToken,
        ),
      );
    }
    final batch = await buildPendingBatch();
    if (batch.operations.isEmpty) {
      if (granularAcknowledgements.isNotEmpty) {
        return SyncBatchAck(
          acknowledgedOperationIds: granularAcknowledgements
              .map((item) => item.operationId)
              .toList(),
          revision: await database.loadSyncRevision(),
        );
      }
      return pullLatest(gateway: gateway, accessToken: accessToken);
    }
    final acknowledgement = await gateway.pushBatch(
      payload: batch.toJson(),
      accessToken: accessToken,
    );
    await database.markSyncOperationsAsSynced(
      acknowledgement.acknowledgedOperationIds,
    );
    await database.saveSyncRevision(acknowledgement.revision);
    return acknowledgement;
  }

  Future<SyncBatchAck?> pullLatest({
    required SyncGateway gateway,
    required String accessToken,
  }) async {
    final remote = await gateway.pullSnapshot(accessToken: accessToken);
    final localRevision = await database.loadSyncRevision();
    SyncBatchAck? result;
    if (remote.snapshot != null && remote.revision > localRevision) {
      await database.restoreSnapshot(
        remote.snapshot!,
        recordSyncOperation: false,
      );
      await database.saveSyncRevision(remote.revision);
      result = SyncBatchAck(
        acknowledgedOperationIds: const [],
        revision: remote.revision,
      );
    }
    await _pullPets(gateway: gateway, accessToken: accessToken);
    await _pullClinicalEntities(gateway: gateway, accessToken: accessToken);
    return result;
  }

  Future<List<EntitySyncAck>> _synchronizePets({
    required SyncGateway gateway,
    required String accessToken,
  }) async {
    final operations = await database.loadPendingPetSyncOperations();
    if (operations.isEmpty) {
      await _pullPets(gateway: gateway, accessToken: accessToken);
      return const [];
    }
    final parsedOperations = operations.map((operation) {
      final decoded = operation.payload.isEmpty
          ? const <String, dynamic>{}
          : Map<String, dynamic>.from(jsonDecode(operation.payload) as Map);
      return (operation: operation, decoded: decoded);
    }).toList();
    final latestByEntity =
        <String, ({SyncOperation operation, Map<String, dynamic> decoded})>{};
    for (final item in parsedOperations) {
      final syncId = item.decoded['syncId']?.toString() ?? '';
      if (syncId.isNotEmpty) latestByEntity[syncId] = item;
    }
    final changes = latestByEntity.entries.map((entry) {
      final item = entry.value;
      return {
        'operationId': item.operation.id,
        'entityType': 'pet',
        'entityId': entry.key,
        'baseVersion': item.decoded['baseVersion'] ?? 0,
        'deleted': item.decoded['deleted'] == true,
        'payload': item.decoded['data'],
        'changedAt': item.operation.occurredAt.toUtc().toIso8601String(),
      };
    }).toList();
    final acknowledgements = await gateway.pushEntities(
      changes: changes,
      accessToken: accessToken,
    );
    for (final acknowledgement in acknowledgements) {
      await database.applyPetSyncVersion(
        acknowledgement.entityId,
        acknowledgement.version,
      );
    }
    final acknowledgedEntities = acknowledgements
        .map((item) => item.entityId)
        .toSet();
    await database.markSyncOperationsAsSynced(
      parsedOperations
          .where(
            (item) => acknowledgedEntities.contains(
              item.decoded['syncId']?.toString(),
            ),
          )
          .map((item) => item.operation.id),
    );
    await _pullPets(gateway: gateway, accessToken: accessToken);
    return acknowledgements;
  }

  Future<void> _pullPets({
    required SyncGateway gateway,
    required String accessToken,
  }) async {
    final entities = await gateway.pullEntities(
      entityType: 'pet',
      accessToken: accessToken,
    );
    await database.applyRemotePets(entities);
  }

  Future<List<EntitySyncAck>> _synchronizeClinicalEntity({
    required String entityType,
    required SyncGateway gateway,
    required String accessToken,
  }) async {
    final operations = await database.loadPendingEntitySyncOperations(
      entityType,
    );
    if (operations.isEmpty) {
      await _pullClinicalEntity(
        entityType: entityType,
        gateway: gateway,
        accessToken: accessToken,
      );
      return const [];
    }
    final parsedOperations = operations.map((operation) {
      final decoded = operation.payload.isEmpty
          ? const <String, dynamic>{}
          : Map<String, dynamic>.from(jsonDecode(operation.payload) as Map);
      return (operation: operation, decoded: decoded);
    }).toList();
    final latestByEntity =
        <String, ({SyncOperation operation, Map<String, dynamic> decoded})>{};
    for (final item in parsedOperations) {
      final syncId = item.decoded['syncId']?.toString() ?? '';
      if (syncId.isNotEmpty) latestByEntity[syncId] = item;
    }
    final changes = latestByEntity.entries.map((entry) {
      final item = entry.value;
      return {
        'operationId': item.operation.id,
        'entityType': entityType,
        'entityId': entry.key,
        'baseVersion': item.decoded['baseVersion'] ?? 0,
        'deleted': item.decoded['deleted'] == true,
        'payload': item.decoded['data'],
        'changedAt': item.operation.occurredAt.toUtc().toIso8601String(),
      };
    }).toList();
    final acknowledgements = await gateway.pushEntities(
      changes: changes,
      accessToken: accessToken,
    );
    for (final acknowledgement in acknowledgements) {
      await database.applyEntitySyncVersion(
        entityType,
        acknowledgement.entityId,
        acknowledgement.version,
      );
    }
    final acknowledgedEntities = acknowledgements
        .map((item) => item.entityId)
        .toSet();
    await database.markSyncOperationsAsSynced(
      parsedOperations
          .where(
            (item) => acknowledgedEntities.contains(
              item.decoded['syncId']?.toString(),
            ),
          )
          .map((item) => item.operation.id),
    );
    await _pullClinicalEntity(
      entityType: entityType,
      gateway: gateway,
      accessToken: accessToken,
    );
    return acknowledgements;
  }

  Future<void> _pullClinicalEntities({
    required SyncGateway gateway,
    required String accessToken,
  }) async {
    for (final entityType in const ['vaccine', 'weight', 'medication']) {
      await _pullClinicalEntity(
        entityType: entityType,
        gateway: gateway,
        accessToken: accessToken,
      );
    }
  }

  Future<void> _pullClinicalEntity({
    required String entityType,
    required SyncGateway gateway,
    required String accessToken,
  }) async {
    final entities = await gateway.pullEntities(
      entityType: entityType,
      accessToken: accessToken,
    );
    await database.applyRemoteClinicalEntities(entityType, entities);
  }
}
