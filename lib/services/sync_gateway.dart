import 'dart:convert';

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../domain/partner_directory.dart';

class SyncAuthSession {
  const SyncAuthSession({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
}

class RegistrationResult {
  const RegistrationResult({
    required this.email,
    required this.message,
    this.session,
    this.verificationRequired = false,
  });

  final String email;
  final String message;
  final SyncAuthSession? session;
  final bool verificationRequired;
}

class SyncBatchAck {
  const SyncBatchAck({
    required this.acknowledgedOperationIds,
    required this.revision,
    this.serverTime,
  });

  final List<int> acknowledgedOperationIds;
  final int revision;
  final DateTime? serverTime;
}

class RemoteSnapshot {
  const RemoteSnapshot({required this.snapshot, required this.revision});

  final Map<String, dynamic>? snapshot;
  final int revision;
}

class EntitySyncAck {
  const EntitySyncAck({
    required this.operationId,
    required this.entityId,
    required this.version,
  });

  final int operationId;
  final String entityId;
  final int version;
}

class SyncGatewayException implements Exception {
  const SyncGatewayException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'SyncGatewayException(${statusCode ?? 'network'}): $message';
}

abstract interface class SyncGateway {
  Future<RegistrationResult> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? birthDate,
    required bool termsAccepted,
  });

  Future<SyncAuthSession> verifyEmail({
    required String email,
    required String token,
  });

  Future<SyncAuthSession> signIn({
    required String email,
    required String password,
  });

  Future<SyncAuthSession> refreshSession({required String refreshToken});

  Future<String> requestPasswordReset({required String email});

  Future<String> confirmPasswordReset({
    required String token,
    required String newPassword,
  });

  Future<void> logout({required String accessToken});

  Future<SyncBatchAck> pushBatch({
    required Map<String, dynamic> payload,
    required String accessToken,
  });

  Future<RemoteSnapshot> pullSnapshot({required String accessToken});

  Future<List<EntitySyncAck>> pushEntities({
    required List<Map<String, dynamic>> changes,
    required String accessToken,
  });

  Future<List<Map<String, dynamic>>> pullEntities({
    required String entityType,
    required String accessToken,
  });
}

class HttpSyncGateway implements SyncGateway {
  HttpSyncGateway({
    required this.baseUri,
    http.Client? client,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client();

  final Uri baseUri;
  final http.Client _client;
  final Duration timeout;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<RegistrationResult> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? birthDate,
    required bool termsAccepted,
  }) async {
    final response = await _post(
      'auth/register',
      body: {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'birthDate': birthDate,
        'termsAccepted': termsAccepted,
      },
    );
    final data = _decodeObject(response);
    final session = data['accessToken'] is String
        ? _decodeSession(response)
        : null;
    return RegistrationResult(
      email: data['email'] is String ? data['email'] as String : email,
      message: data['message'] is String
          ? data['message'] as String
          : 'Conta criada com sucesso.',
      session: session,
      verificationRequired: data['status'] == 'verification_required',
    );
  }

  @override
  Future<SyncAuthSession> verifyEmail({
    required String email,
    required String token,
  }) async {
    final response = await _post(
      'auth/verify-email',
      body: {'email': email, 'token': token},
    );
    return _decodeSession(response);
  }

  @override
  Future<SyncAuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _post(
      'auth/login',
      body: {'email': email, 'password': password},
    );
    return _decodeSession(response);
  }

  @override
  Future<SyncAuthSession> refreshSession({required String refreshToken}) async {
    final response = await _post(
      'auth/refresh',
      body: {'refreshToken': refreshToken},
    );
    return _decodeSession(response);
  }

  @override
  Future<String> requestPasswordReset({required String email}) async {
    final response = await _post(
      'auth/password-reset/request',
      body: {'email': email},
    );
    return _decodeMessage(response);
  }

  @override
  Future<String> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    final response = await _post(
      'auth/password-reset/confirm',
      body: {'token': token, 'newPassword': newPassword},
    );
    return _decodeMessage(response);
  }

  @override
  Future<void> logout({required String accessToken}) async {
    await _post('auth/logout', body: const {}, accessToken: accessToken);
  }

  Future<Map<String, dynamic>> submitPartnerProfile({
    required String accessToken,
    required Map<String, dynamic> profile,
  }) async {
    final data = _decodeObject(
      await _post(
        'partner/profile/request',
        body: profile,
        accessToken: accessToken,
      ),
    );
    return data;
  }

  Future<Map<String, dynamic>> loadPartnerProfile({
    required String accessToken,
  }) async {
    return _decodeObject(
      await _get('partner/profile', accessToken: accessToken),
    );
  }

  Future<Map<String, dynamic>> loadPartnerDocuments({
    required String accessToken,
  }) async {
    return _decodeObject(
      await _get('partner/documents', accessToken: accessToken),
    );
  }

  Future<Map<String, dynamic>> uploadPartnerDocument({
    required String accessToken,
    required String documentType,
    required String fileName,
    required String mimeType,
    required List<int> bytes,
  }) async {
    return _decodeObject(
      await _post(
        'partner/documents',
        accessToken: accessToken,
        body: {
          'documentType': documentType,
          'fileName': fileName,
          'mimeType': mimeType,
          'contentBase64': base64Encode(bytes),
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> loadAppointments({
    required String accessToken,
  }) async {
    final data = _decodeObject(
      await _get('appointments', accessToken: accessToken),
    );
    return _decodeObjectList(data['appointments']);
  }

  Future<Map<String, dynamic>> createAppointment({
    required String accessToken,
    required int partnerId,
    required String petId,
    required String petName,
    required String service,
    required DateTime scheduledAt,
    String notes = '',
  }) async => _decodeObject(
    await _post(
      'appointments',
      accessToken: accessToken,
      body: {
        'partnerId': partnerId,
        'petId': petId,
        'petName': petName,
        'service': service,
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
        'notes': notes,
      },
    ),
  );

  Future<Map<String, dynamic>> updateAppointmentStatus({
    required String accessToken,
    required int appointmentId,
    required String status,
  }) async => _decodeObject(
    await _patch(
      'appointments/$appointmentId/status',
      accessToken: accessToken,
      body: {'status': status},
    ),
  );

  Future<List<Map<String, dynamic>>> loadPartnerAppointments({
    required String accessToken,
  }) async {
    final data = _decodeObject(
      await _get('partner/appointments', accessToken: accessToken),
    );
    return _decodeObjectList(data['appointments']);
  }

  Future<Map<String, dynamic>> updatePartnerAppointmentStatus({
    required String accessToken,
    required int appointmentId,
    required String status,
  }) async => _decodeObject(
    await _patch(
      'partner/appointments/$appointmentId/status',
      accessToken: accessToken,
      body: {'status': status},
    ),
  );

  Future<Map<String, dynamic>> createPrescription({
    required String accessToken,
    required Map<String, dynamic> prescription,
  }) async => _decodeObject(
    await _post(
      'partner/prescriptions',
      accessToken: accessToken,
      body: prescription,
    ),
  );

  Future<Map<String, dynamic>> preparePrescription({
    required String accessToken,
    required int prescriptionId,
  }) async => _decodeObject(
    await _post(
      'partner/prescriptions/$prescriptionId/prepare',
      accessToken: accessToken,
      body: const {},
    ),
  );

  Future<List<Map<String, dynamic>>> loadPrescriptions({
    required String accessToken,
    bool partner = false,
  }) async {
    final data = _decodeObject(
      await _get(
        partner ? 'partner/prescriptions' : 'prescriptions',
        accessToken: accessToken,
      ),
    );
    return _decodeObjectList(data['prescriptions']);
  }

  Future<Uint8List> downloadPrescription({
    required String accessToken,
    required int prescriptionId,
    bool partner = false,
  }) async {
    final uri = baseUri.resolve(
      partner
          ? 'partner/prescriptions/$prescriptionId/content'
          : 'prescriptions/$prescriptionId/content',
    );
    final response = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SyncGatewayException(
        _errorMessage(response),
        statusCode: response.statusCode,
      );
    }
    return response.bodyBytes;
  }

  Future<Map<String, dynamic>> loadAccountStatus({
    required String accessToken,
  }) async {
    final response = await _get('account/status', accessToken: accessToken);
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>?> loadAccountAddress({
    required String accessToken,
  }) async {
    final response = await _get('account/address', accessToken: accessToken);
    final data = _decodeObject(response);
    return data['address'] is Map
        ? Map<String, dynamic>.from(data['address'] as Map)
        : null;
  }

  Future<void> saveAccountAddress({
    required String accessToken,
    required Map<String, dynamic> address,
  }) async {
    await _put('account/address', body: address, accessToken: accessToken);
  }

  Future<List<Map<String, dynamic>>> loadPrivateVeterinaryContacts({
    required String accessToken,
  }) async {
    final data = _decodeObject(
      await _get('account/veterinary-contacts', accessToken: accessToken),
    );
    final contacts = data['contacts'];
    if (contacts is! List) return const [];
    return contacts
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<Map<String, dynamic>> upsertPrivateVeterinaryContact({
    required String accessToken,
    required Map<String, dynamic> contact,
  }) async {
    final data = _decodeObject(
      await _post(
        'account/veterinary-contacts',
        body: contact,
        accessToken: accessToken,
      ),
    );
    final result = data['contact'];
    return result is Map ? Map<String, dynamic>.from(result) : data;
  }

  Future<Map<String, dynamic>> loadBillingCatalog() async {
    final response = await _get('billing/catalog');
    return _decodeObject(response);
  }

  Future<List<PartnerClinic>> loadPartners({
    double? latitude,
    double? longitude,
    bool urgency = false,
    String? service,
  }) async {
    final query = <String, String>{
      'urgency': urgency.toString(),
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
      if (service != null && service.trim().isNotEmpty)
        'service': service.trim(),
    };
    final path = Uri(path: 'partners', queryParameters: query).toString();
    final data = _decodeObject(await _get(path));
    final rawPartners = data['partners'];
    if (rawPartners is! List) return const [];
    return rawPartners.whereType<Map>().map((raw) {
      final item = Map<String, dynamic>.from(raw);
      final rawServices = item['services'];
      return PartnerClinic(
        id: item['id']?.toString() ?? '',
        name: item['name']?.toString() ?? 'Parceiro AuMiau',
        kind: item['kind']?.toString() ?? 'Veterinário',
        address: item['address']?.toString() ?? '',
        city: item['city']?.toString() ?? '',
        state: item['state']?.toString() ?? '',
        latitude: (item['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (item['longitude'] as num?)?.toDouble() ?? 0,
        services: rawServices is List
            ? rawServices.map((value) => value.toString()).toList()
            : const [],
        acceptsUrgency: item['acceptsUrgency'] == true,
        isDemonstration: false,
        phone: item['phone']?.toString() ?? '',
        whatsapp: item['whatsapp']?.toString() ?? '',
      );
    }).toList();
  }

  Future<Map<String, dynamic>> createBillingOrder({
    required String accessToken,
    required String productId,
  }) async {
    final deviceSessionId = await _deviceSessionId();
    final response = await _post(
      'billing/orders',
      body: {'productId': productId},
      accessToken: accessToken,
      extraHeaders: {'X-Meli-Session-Id': deviceSessionId},
    );
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> loadBillingOrder({
    required String accessToken,
    required String orderId,
  }) async {
    final response = await _get(
      'billing/orders/${Uri.encodeComponent(orderId)}',
      accessToken: accessToken,
    );
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> verifyGooglePlayPurchase({
    required String accessToken,
    required String productId,
    required String purchaseToken,
  }) async {
    final response = await _post(
      'billing/verify',
      body: {
        'provider': 'google_play',
        'productId': productId,
        'purchaseToken': purchaseToken,
      },
      accessToken: accessToken,
    );
    return _decodeObject(response);
  }

  @override
  Future<SyncBatchAck> pushBatch({
    required Map<String, dynamic> payload,
    required String accessToken,
  }) async {
    final response = await _post(
      'sync/batch',
      body: payload,
      accessToken: accessToken,
    );
    final data = _decodeObject(response);
    final ids = data['acknowledgedOperationIds'];
    if (ids is! List) {
      throw const SyncGatewayException(
        'Resposta de sincronização sem acknowledgedOperationIds.',
      );
    }
    return SyncBatchAck(
      acknowledgedOperationIds: ids
          .whereType<num>()
          .map((id) => id.toInt())
          .toList(),
      revision: data['revision'] is num
          ? (data['revision'] as num).toInt()
          : throw const SyncGatewayException(
              'Resposta de sincronização sem revisão.',
            ),
      serverTime: data['serverTime'] is String
          ? DateTime.tryParse(data['serverTime'] as String)
          : null,
    );
  }

  @override
  Future<RemoteSnapshot> pullSnapshot({required String accessToken}) async {
    final data = _decodeObject(
      await _get('sync/snapshot', accessToken: accessToken),
    );
    final revision = data['revision'];
    if (revision is! num) {
      throw const SyncGatewayException(
        'Resposta de sincronização sem revisão.',
      );
    }
    final snapshot = data['snapshot'];
    return RemoteSnapshot(
      snapshot: snapshot is Map ? Map<String, dynamic>.from(snapshot) : null,
      revision: revision.toInt(),
    );
  }

  @override
  Future<List<EntitySyncAck>> pushEntities({
    required List<Map<String, dynamic>> changes,
    required String accessToken,
  }) async {
    final data = _decodeObject(
      await _post(
        'sync/entities',
        body: {'changes': changes},
        accessToken: accessToken,
      ),
    );
    return _decodeObjectList(data['acknowledged'])
        .map(
          (item) => EntitySyncAck(
            operationId: (item['operationId'] as num).toInt(),
            entityId: item['entityId'].toString(),
            version: (item['version'] as num).toInt(),
          ),
        )
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> pullEntities({
    required String entityType,
    required String accessToken,
  }) async {
    final uri = Uri(
      path: 'sync/entities',
      queryParameters: {'entityType': entityType},
    );
    final data = _decodeObject(
      await _get(uri.toString(), accessToken: accessToken),
    );
    return _decodeObjectList(data['entities']);
  }

  SyncAuthSession _decodeSession(http.Response response) {
    final data = _decodeObject(response);
    final accessToken = data['accessToken'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const SyncGatewayException('Resposta sem accessToken.');
    }
    return SyncAuthSession(
      accessToken: accessToken,
      refreshToken: data['refreshToken'] is String
          ? data['refreshToken'] as String
          : null,
      expiresAt: data['expiresAt'] is String
          ? DateTime.tryParse(data['expiresAt'] as String)
          : null,
    );
  }

  Future<http.Response> _post(
    String path, {
    required Map<String, dynamic> body,
    String? accessToken,
    Map<String, String>? extraHeaders,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      ...?extraHeaders,
    };
    try {
      final response = await _client
          .post(baseUri.resolve(path), headers: headers, body: jsonEncode(body))
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SyncGatewayException(
          _errorMessage(response),
          statusCode: response.statusCode,
        );
      }
      return response;
    } on SyncGatewayException {
      rethrow;
    } catch (error) {
      throw SyncGatewayException('Falha de comunicação com o servidor: $error');
    }
  }

  Future<String> _deviceSessionId() async {
    const storageKey = 'aumiau.mercadopago.device_session_id';
    final existing = await _secureStorage.read(key: storageKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final random = Random.secure();
    final generated = List<String>.generate(
      32,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
    await _secureStorage.write(key: storageKey, value: generated);
    return generated;
  }

  Future<http.Response> _get(String path, {String? accessToken}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    try {
      final response = await _client
          .get(baseUri.resolve(path), headers: headers)
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SyncGatewayException(
          _errorMessage(response),
          statusCode: response.statusCode,
        );
      }
      return response;
    } on SyncGatewayException {
      rethrow;
    } catch (error) {
      throw SyncGatewayException('Falha de comunicação com o servidor: $error');
    }
  }

  Future<http.Response> _put(
    String path, {
    required Map<String, dynamic> body,
    String? accessToken,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    try {
      final response = await _client
          .put(baseUri.resolve(path), headers: headers, body: jsonEncode(body))
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SyncGatewayException(
          _errorMessage(response),
          statusCode: response.statusCode,
        );
      }
      return response;
    } on SyncGatewayException {
      rethrow;
    } catch (error) {
      throw SyncGatewayException('Falha de comunicação com o servidor: $error');
    }
  }

  Future<http.Response> _patch(
    String path, {
    required Map<String, dynamic> body,
    String? accessToken,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    try {
      final response = await _client
          .patch(
            baseUri.resolve(path),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SyncGatewayException(
          _errorMessage(response),
          statusCode: response.statusCode,
        );
      }
      return response;
    } on SyncGatewayException {
      rethrow;
    } catch (error) {
      throw SyncGatewayException('Falha de comunicação com o servidor: $error');
    }
  }

  List<Map<String, dynamic>> _decodeObjectList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      // A mensagem abaixo mantém o erro seguro e sem expor o corpo bruto.
    }
    throw const SyncGatewayException('Resposta inválida do servidor.');
  }

  String _decodeMessage(http.Response response) {
    final data = _decodeObject(response);
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
    return 'Operação concluída.';
  }

  String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['message'] is String) {
        return decoded['message'] as String;
      }
      if (decoded is Map && decoded['detail'] is String) {
        return decoded['detail'] as String;
      }
    } catch (_) {
      // Usa mensagem genérica para não expor conteúdo inesperado.
    }
    return 'Servidor recusou a operação.';
  }
}
