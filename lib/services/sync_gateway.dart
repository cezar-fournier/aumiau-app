import 'dart:convert';

import 'package:http/http.dart' as http;

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
  const SyncBatchAck({required this.acknowledgedOperationIds, this.serverTime});

  final List<int> acknowledgedOperationIds;
  final DateTime? serverTime;
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
      serverTime: data['serverTime'] is String
          ? DateTime.tryParse(data['serverTime'] as String)
          : null,
    );
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
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
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
