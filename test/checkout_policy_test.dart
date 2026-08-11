import 'package:aumiau_app/services/checkout_policy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bloqueia o checkout do Mercado Pago somente no iPhone', () {
    expect(allowsMercadoPagoCheckout(TargetPlatform.iOS), isFalse);
    expect(allowsMercadoPagoCheckout(TargetPlatform.android), isTrue);
  });
}
