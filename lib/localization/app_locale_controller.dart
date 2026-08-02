import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const supportedAppLocales = <Locale>[
  Locale('pt', 'BR'),
  Locale('en'),
  Locale('es'),
];

Locale resolveSupportedLocale(Iterable<Locale> preferredLocales) {
  for (final preferred in preferredLocales) {
    for (final supported in supportedAppLocales) {
      if (preferred.languageCode == supported.languageCode) return supported;
    }
  }
  return supportedAppLocales.first;
}

class LocalePreferenceStore {
  const LocalePreferenceStore()
    : _storage = const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  static const _key = 'aumiau.preferences.locale';
  final FlutterSecureStorage _storage;

  Future<String?> read() => _storage.read(key: _key);

  Future<void> write(Locale locale) =>
      _storage.write(key: _key, value: locale.toLanguageTag());
}

class AppLocaleController extends ChangeNotifier {
  AppLocaleController({Locale initialLocale = const Locale('pt', 'BR')})
    : _locale = resolveSupportedLocale([initialLocale]),
      _store = null;

  AppLocaleController.persistent(
    this._store, {
    Locale initialLocale = const Locale('pt', 'BR'),
  }) : _locale = resolveSupportedLocale([initialLocale]);

  final LocalePreferenceStore? _store;
  Locale _locale;

  Locale get locale => _locale;

  Future<void> load({Iterable<Locale>? systemLocales}) async {
    String? storedTag;
    try {
      storedTag = await _store?.read();
    } catch (_) {
      storedTag = null;
    }

    final storedLocale = _parseLanguageTag(storedTag);
    _locale =
        storedLocale ??
        resolveSupportedLocale(
          systemLocales ?? PlatformDispatcher.instance.locales,
        );
  }

  Future<void> setLocale(Locale locale) async {
    final resolved = resolveSupportedLocale([locale]);
    if (_locale == resolved) return;
    _locale = resolved;
    notifyListeners();
    try {
      await _store?.write(resolved);
    } catch (_) {
      // A troca continua válida na sessão mesmo se a persistência falhar.
    }
  }

  static Locale? _parseLanguageTag(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.replaceAll('_', '-').toLowerCase();
    return switch (normalized.split('-').first) {
      'pt' => const Locale('pt', 'BR'),
      'en' => const Locale('en'),
      'es' => const Locale('es'),
      _ => null,
    };
  }
}
