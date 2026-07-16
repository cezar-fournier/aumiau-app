import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredSession {
  const StoredSession({
    required this.email,
    required this.accessToken,
    this.refreshToken,
  });

  final String email;
  final String accessToken;
  final String? refreshToken;
}

class SessionStore {
  SessionStore()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  static const _emailKey = 'aumiau.session.email';
  static const _tokenKey = 'aumiau.session.access_token';
  static const _refreshKey = 'aumiau.session.refresh_token';

  final FlutterSecureStorage _storage;

  Future<void> save({
    required String email,
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _tokenKey, value: accessToken);
    if (refreshToken == null || refreshToken.isEmpty) {
      await _storage.delete(key: _refreshKey);
    } else {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
  }

  Future<StoredSession?> read() async {
    final email = await _storage.read(key: _emailKey);
    final accessToken = await _storage.read(key: _tokenKey);
    final refreshToken = await _storage.read(key: _refreshKey);
    if (email == null ||
        email.isEmpty ||
        accessToken == null ||
        accessToken.isEmpty) {
      return null;
    }
    return StoredSession(
      email: email,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  Future<void> clear() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshKey);
  }
}
