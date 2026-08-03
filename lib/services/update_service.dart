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
  static const _releasesPath =
      'https://api.github.com/repos/$repository/releases?per_page=20';

  final http.Client _client;

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await _client
          .get(
            Uri.parse(_releasesPath),
            headers: const {
              'Accept': 'application/vnd.github+json',
              'User-Agent': 'AuMiau-App',
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;
      final packageInfo = await PackageInfo.fromPlatform();
      return parseReleases(
        jsonDecode(response.body) as List<dynamic>,
        currentVersion: packageInfo.version,
      );
    } on Object {
      return null;
    }
  }

  UpdateInfo? parseReleases(
    List<dynamic> releases, {
    required String currentVersion,
  }) {
    final betaChannel = _isPrerelease(currentVersion);
    final candidates = <UpdateInfo>[];
    for (final item in releases) {
      if (item is! Map) continue;
      final release = Map<String, dynamic>.from(item);
      if (release['draft'] == true) continue;
      if (!betaChannel && release['prerelease'] == true) continue;
      final update = parseRelease(release, currentVersion: currentVersion);
      if (update != null) candidates.add(update);
    }
    if (candidates.isEmpty) return null;
    candidates.sort(
      (left, right) => compareVersions(right.version, left.version),
    );
    return candidates.first;
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
    final leftVersion = _semanticVersion(left);
    final rightVersion = _semanticVersion(right);
    final leftParts = leftVersion.$1;
    final rightParts = rightVersion.$1;
    final length = leftParts.length > rightParts.length
        ? leftParts.length
        : rightParts.length;
    for (var index = 0; index < length; index++) {
      final leftPart = index < leftParts.length ? leftParts[index] : 0;
      final rightPart = index < rightParts.length ? rightParts[index] : 0;
      if (leftPart != rightPart) return leftPart.compareTo(rightPart);
    }
    final leftPrerelease = leftVersion.$2;
    final rightPrerelease = rightVersion.$2;
    if (leftPrerelease.isEmpty && rightPrerelease.isNotEmpty) return 1;
    if (leftPrerelease.isNotEmpty && rightPrerelease.isEmpty) return -1;
    final prereleaseLength = leftPrerelease.length > rightPrerelease.length
        ? leftPrerelease.length
        : rightPrerelease.length;
    for (var index = 0; index < prereleaseLength; index++) {
      if (index >= leftPrerelease.length) return -1;
      if (index >= rightPrerelease.length) return 1;
      final leftPart = leftPrerelease[index];
      final rightPart = rightPrerelease[index];
      final leftNumber = int.tryParse(leftPart);
      final rightNumber = int.tryParse(rightPart);
      if (leftNumber != null &&
          rightNumber != null &&
          leftNumber != rightNumber) {
        return leftNumber.compareTo(rightNumber);
      }
      if (leftNumber != null && rightNumber == null) return -1;
      if (leftNumber == null && rightNumber != null) return 1;
      final comparison = leftPart.compareTo(rightPart);
      if (comparison != 0) return comparison;
    }
    return 0;
  }

  static (List<int>, List<String>) _semanticVersion(String value) {
    final normalized = value
        .replaceFirst(RegExp(r'^[vV]'), '')
        .split('+')
        .first;
    final segments = normalized.split('-');
    final numbers = segments.first
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
    final prerelease = segments.length <= 1
        ? const <String>[]
        : segments.skip(1).join('-').split('.');
    return (numbers, prerelease);
  }

  static bool _isPrerelease(String value) =>
      value.replaceFirst(RegExp(r'^[vV]'), '').split('+').first.contains('-');
}
