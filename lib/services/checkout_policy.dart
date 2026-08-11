import 'package:flutter/foundation.dart';

/// Regras temporárias de disponibilidade dos meios de contratação por plataforma.
///
/// No iPhone, a contratação de recursos digitais permanece indisponível até a
/// integração com as compras da App Store. O Android continua usando o fluxo
/// atual do Mercado Pago durante o beta.
bool allowsMercadoPagoCheckout(TargetPlatform platform) {
  return platform != TargetPlatform.iOS;
}
