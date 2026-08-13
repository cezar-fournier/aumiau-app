import 'package:aumiau_app/services/play_billing_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

void main() {
  test('ofusca a conta sem expor o e-mail ao Google Play', () {
    final identifier = obfuscatePlayAccountId(' Cliente@Example.com ');

    expect(identifier, hasLength(64));
    expect(identifier, isNot(contains('@')));
    expect(identifier, obfuscatePlayAccountId('cliente@example.com'));
  });

  test('não cria identificador para conta ausente', () {
    expect(obfuscatePlayAccountId(null), isNull);
    expect(obfuscatePlayAccountId('  '), isNull);
  });

  test('traduz erro técnico do Billing para orientação ao usuário', () {
    final message = playPurchaseErrorMessage(
      IAPError(
        source: 'google_play',
        code: 'BillingResponse.developerError',
        message: 'BillingResponse.developerError',
      ),
    );

    expect(message, contains('Atualize o aplicativo'));
    expect(message, isNot(contains('developerError')));
  });
}
