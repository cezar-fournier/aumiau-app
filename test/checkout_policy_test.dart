import 'package:aumiau_app/services/checkout_policy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mantém Mercado Pago no Android de distribuição direta', () {
    expect(allowsMercadoPagoCheckout(TargetPlatform.iOS), isFalse);
    expect(allowsMercadoPagoCheckout(TargetPlatform.android), isTrue);
  });

  test('usa somente Google Play Billing na distribuição da loja', () {
    expect(
      allowsMercadoPagoCheckout(
        TargetPlatform.android,
        distribution: 'google_play',
      ),
      isFalse,
    );
    expect(
      allowsGooglePlayBilling(
        TargetPlatform.android,
        distribution: 'google_play',
      ),
      isTrue,
    );
    expect(
      allowsGooglePlayBilling(TargetPlatform.iOS, distribution: 'google_play'),
      isFalse,
    );
  });
}
