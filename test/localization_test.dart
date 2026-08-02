import 'package:aumiau_app/localization/app_locale_controller.dart';
import 'package:aumiau_app/localization/app_localizations.dart';
import 'package:aumiau_app/data/app_database.dart';
import 'package:aumiau_app/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolve idiomas suportados e usa português como fallback', () {
    expect(
      resolveSupportedLocale([const Locale('en', 'US')]),
      const Locale('en'),
    );
    expect(
      resolveSupportedLocale([const Locale('es', 'MX')]),
      const Locale('es'),
    );
    expect(
      resolveSupportedLocale([const Locale('fr', 'FR')]),
      const Locale('pt', 'BR'),
    );
  });

  test('controlador troca o idioma durante a sessão', () async {
    final controller = AppLocaleController();
    expect(controller.locale, const Locale('pt', 'BR'));

    await controller.setLocale(const Locale('en', 'GB'));
    expect(controller.locale, const Locale('en'));

    await controller.setLocale(const Locale('es', 'AR'));
    expect(controller.locale, const Locale('es'));
  });

  for (final testCase in const [
    (locale: Locale('pt', 'BR'), expected: 'Cuide de quem ama'),
    (locale: Locale('en'), expected: 'Care for those you love'),
    (locale: Locale('es'), expected: 'Cuida a quienes amas'),
  ]) {
    testWidgets('carrega catálogo ${testCase.locale.toLanguageTag()}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: testCase.locale,
          supportedLocales: supportedAppLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          home: Builder(
            builder: (context) => Text(context.l10n.text('auth.hero')),
          ),
        ),
      );

      expect(find.text(testCase.expected), findsOneWidget);
    });
  }

  testWidgets('seletor da entrada troca português, inglês e espanhol', (
    tester,
  ) async {
    final controller = AppLocaleController();
    final database = AppDatabase.fromExecutor(
      NativeDatabase.memory(),
      seedDemoData: false,
    );
    await tester.pumpWidget(
      AumiauApp(
        database: database,
        enableUpdateChecks: false,
        localeController: controller,
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Cuide de quem ama'), findsOneWidget);
    await tester.tap(find.text('Português'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();
    expect(find.text('Care for those you love'), findsOneWidget);

    await tester.tap(find.text('English').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español').last);
    await tester.pumpAndSettle();
    expect(find.text('Cuida a quienes amas'), findsOneWidget);

    await database.close();
  });
}
