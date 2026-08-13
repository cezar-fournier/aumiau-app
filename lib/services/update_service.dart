import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';

import 'checkout_policy.dart';

enum AppUpdateStatus {
  current,
  available,
  downloaded,
  storeUnavailable,
  unsupported,
  failed,
}

class AppUpdateResult {
  const AppUpdateResult(
    this.status, {
    this.availableVersionCode,
    this.immediateUpdateAllowed = false,
    this.flexibleUpdateAllowed = false,
  });

  final AppUpdateStatus status;
  final int? availableVersionCode;
  final bool immediateUpdateAllowed;
  final bool flexibleUpdateAllowed;

  bool get hasUpdate =>
      status == AppUpdateStatus.available ||
      status == AppUpdateStatus.downloaded;
}

/// Atualizações do Android distribuído pela Google Play.
///
/// O serviço deliberadamente não consulta GitHub Releases. A Google Play é a
/// fonte oficial para Android; no iOS, TestFlight/App Store gerenciam o canal.
class UpdateService {
  const UpdateService();

  bool get usesGooglePlayUpdates =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      isGooglePlayDistribution;

  bool get usesAppleUpdates =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<AppUpdateResult> checkForUpdate() async {
    if (!usesGooglePlayUpdates) {
      return const AppUpdateResult(AppUpdateStatus.unsupported);
    }
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.installStatus == InstallStatus.downloaded) {
        return AppUpdateResult(
          AppUpdateStatus.downloaded,
          availableVersionCode: info.availableVersionCode,
          immediateUpdateAllowed: info.immediateUpdateAllowed,
          flexibleUpdateAllowed: info.flexibleUpdateAllowed,
        );
      }
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        return AppUpdateResult(
          AppUpdateStatus.available,
          availableVersionCode: info.availableVersionCode,
          immediateUpdateAllowed: info.immediateUpdateAllowed,
          flexibleUpdateAllowed: info.flexibleUpdateAllowed,
        );
      }
      return const AppUpdateResult(AppUpdateStatus.current);
    } on PlatformException catch (error) {
      if (error.code == 'ERROR_API_NOT_AVAILABLE' ||
          error.code == 'ERROR_APP_NOT_OWNED') {
        return const AppUpdateResult(AppUpdateStatus.storeUnavailable);
      }
      return const AppUpdateResult(AppUpdateStatus.failed);
    } on Object {
      return const AppUpdateResult(AppUpdateStatus.failed);
    }
  }

  Future<AppUpdateStatus> install(AppUpdateResult update) async {
    if (!usesGooglePlayUpdates || !update.hasUpdate) {
      return AppUpdateStatus.unsupported;
    }
    try {
      if (update.status == AppUpdateStatus.downloaded) {
        await InAppUpdate.completeFlexibleUpdate();
        return AppUpdateStatus.current;
      }
      if (update.flexibleUpdateAllowed) {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
        return AppUpdateStatus.current;
      }
      if (update.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
        return AppUpdateStatus.current;
      }
      return AppUpdateStatus.storeUnavailable;
    } on Object {
      return AppUpdateStatus.failed;
    }
  }
}
