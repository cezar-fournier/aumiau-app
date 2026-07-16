import '../data/app_database.dart';
import 'sync_gateway.dart';

class SyncOperationData {
  const SyncOperationData({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.occurredAt,
  });

  final int id;
  final String entityType;
  final int? entityId;
  final String operation;
  final DateTime occurredAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'entityType': entityType,
    'entityId': entityId,
    'operation': operation,
    'occurredAt': occurredAt.toIso8601String(),
  };
}

class SyncBatch {
  const SyncBatch({
    required this.contractVersion,
    required this.generatedAt,
    required this.snapshot,
    required this.operations,
  });

  final String contractVersion;
  final DateTime generatedAt;
  final Map<String, dynamic> snapshot;
  final List<SyncOperationData> operations;

  List<int> get operationIds => operations.map((item) => item.id).toList();

  Map<String, dynamic> toJson() => {
    'contractVersion': contractVersion,
    'generatedAt': generatedAt.toIso8601String(),
    'snapshot': snapshot,
    'operations': operations.map((item) => item.toJson()).toList(),
  };
}

class SyncService {
  SyncService(this.database);

  final AppDatabase database;

  Future<SyncBatch> buildPendingBatch() async {
    final operations = await database.loadPendingSyncOperations();
    final snapshot = await database.exportSnapshot();
    return SyncBatch(
      contractVersion: 'v1',
      generatedAt: DateTime.now(),
      snapshot: snapshot,
      operations: operations
          .map(
            (operation) => SyncOperationData(
              id: operation.id,
              entityType: operation.entityType,
              entityId: operation.entityId,
              operation: operation.operation,
              occurredAt: operation.occurredAt,
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
    final batch = await buildPendingBatch();
    if (batch.operations.isEmpty) return null;
    final acknowledgement = await gateway.pushBatch(
      payload: batch.toJson(),
      accessToken: accessToken,
    );
    await database.markSyncOperationsAsSynced(
      acknowledgement.acknowledgedOperationIds,
    );
    return acknowledgement;
  }
}
