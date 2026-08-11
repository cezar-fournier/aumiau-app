import 'package:flutter/foundation.dart';

/// Canal usado para distribuir o binário atual.
///
/// O valor padrão mantém o beta Android instalado diretamente. O workflow da
/// Google Play precisa informar `AUMIAU_DISTRIBUTION=google_play`.
const String appDistribution = String.fromEnvironment(
  'AUMIAU_DISTRIBUTION',
  defaultValue: 'direct',
);

const bool isGooglePlayDistribution = appDistribution == 'google_play';

bool allowsMercadoPagoCheckout(
  TargetPlatform platform, {
  String distribution = appDistribution,
}) {
  if (platform == TargetPlatform.iOS) return false;
  if (platform == TargetPlatform.android && distribution == 'google_play') {
    return false;
  }
  return true;
}

bool allowsGooglePlayBilling(
  TargetPlatform platform, {
  String distribution = appDistribution,
}) {
  return platform == TargetPlatform.android && distribution == 'google_play';
}
