import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

const currentAppVersion = String.fromEnvironment(
  'AUMIAU_APP_VERSION',
  defaultValue: '0.4.2',
);

class UpdateInfo {
  const UpdateInfo({
    required this.version,
    required this.releaseUrl,
    required this.downloadUrl,
    this.notes = '',
  });

  final String version;
  final String releaseUrl;
  final String downloadUrl;
  final String notes;
}

class UpdateService {
  UpdateService({http.Client? client}) : _client = client ?? http.Client();

  static const repository = 'cezar-fournier/aumiau-app';
  static const _latestReleasePath =
      'https://api.github.com/repos/$repository/releases/latest';

  final http.Client _client;

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await _client
          .get(
            Uri.parse(_latestReleasePath),
            headers: const {
              'Accept': 'application/vnd.github+json',
              'User-Agent': 'AuMiau-App',
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final packageInfo = await PackageInfo.fromPlatform();
      return parseRelease(
        jsonDecode(response.body) as Map<String, dynamic>,
        currentVersion: packageInfo.version,
      );
    } on Object {
      return null;
    }
  }

  UpdateInfo? parseRelease(
    Map<String, dynamic> release, {
    String? currentVersion,
  }) {
    final tag = (release['tag_name'] as String?)?.trim() ?? '';
    final version = tag.startsWith('v') ? tag.substring(1) : tag;
    final releaseUrl = (release['html_url'] as String?)?.trim() ?? '';
    if (version.isEmpty ||
        releaseUrl.isEmpty ||
        !_isNewer(version, currentVersion: currentVersion)) {
      return null;
    }

    final assets = release['assets'] as List<dynamic>? ?? const [];
    String? apkUrl;
    for (final item in assets) {
      final asset = item as Map<String, dynamic>;
      final name = (asset['name'] as String?)?.toLowerCase() ?? '';
      if (name.endsWith('.apk')) {
        apkUrl = (asset['browser_download_url'] as String?)?.trim();
        if (apkUrl != null && apkUrl.isNotEmpty) break;
      }
    }

    return UpdateInfo(
      version: version,
      releaseUrl: releaseUrl,
      downloadUrl: apkUrl?.isNotEmpty == true ? apkUrl! : releaseUrl,
      notes: (release['body'] as String?)?.trim() ?? '',
    );
  }

  bool _isNewer(String remoteVersion, {String? currentVersion}) =>
      _compareVersions(remoteVersion, currentVersion ?? currentAppVersion) > 0;

  static int compareVersions(String left, String right) =>
      _compareVersions(left, right);

  static int _compareVersions(String left, String right) {
    final leftParts = _versionParts(left);
    final rightParts = _versionParts(right);
    final length = leftParts.length > rightParts.length
        ? leftParts.length
        : rightParts.length;
    for (var index = 0; index < length; index++) {
      final leftPart = index < leftParts.length ? leftParts[index] : 0;
      final rightPart = index < rightParts.length ? rightParts[index] : 0;
      if (leftPart != rightPart) return leftPart.compareTo(rightPart);
    }
    return 0;
  }

  static List<int> _versionParts(String value) => value
      .replaceFirst(RegExp(r'^[vV]'), '')
      .split('+')
      .first
      .split('-')
      .first
      .split('.')
      .map((part) => int.tryParse(part) ?? 0)
      .toList();
}
