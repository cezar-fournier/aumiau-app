import 'package:flutter_test/flutter_test.dart';

import 'package:aumiau_partner_app/main.dart';

void main() {
  testWidgets('exibe a entrada do AuMiau Parceiro', (tester) async {
    await tester.pumpWidget(const PartnerApp());
    expect(find.text('AuMiau Parceiro'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
