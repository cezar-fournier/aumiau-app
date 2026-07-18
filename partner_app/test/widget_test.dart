import 'package:flutter_test/flutter_test.dart';

import 'package:aumiau_partner_app/main.dart';

void main() {
  test('valida CPF e CNPJ e rejeita documentos inválidos', () {
    expect(isValidCpf('529.982.247-25'), isTrue);
    expect(isValidCpf('529.982.247-26'), isFalse);
    expect(isValidCnpj('04.368.187/0001-31'), isTrue);
    expect(isValidCnpj('04.368.187/0001-32'), isFalse);
    expect(isValidCpfOrCnpj('529.982.247-25'), isTrue);
    expect(isValidCpfOrCnpj('04.368.187/0001-31'), isTrue);
    expect(isValidCpfOrCnpj('111.111.111-11'), isFalse);
  });

  test('aplica máscara de CPF ou CNPJ conforme a quantidade de dígitos', () {
    expect(formatCpfOrCnpj('52998224725'), '529.982.247-25');
    expect(formatCpfOrCnpj('04368187000131'), '04.368.187/0001-31');
  });

  testWidgets('exibe a entrada do AuMiau Parceiro', (tester) async {
    await tester.pumpWidget(const PartnerApp());
    expect(find.text('AuMiau Parceiro'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
