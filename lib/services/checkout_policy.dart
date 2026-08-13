import 'package:flutter/foundation.dart';

/// Canal usado para distribuir o binário atual.
///
/// O valor padrão é reservado a builds locais de desenvolvimento. Todo binário
/// distribuído ao público precisa declarar a loja oficial correspondente; o
/// workflow Android informa `AUMIAU_DISTRIBUTION=google_play`.
const String appDistribution = String.fromEnvironment(
  'AUMIAU_DISTRIBUTION',
  defaultValue: 'development',
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
