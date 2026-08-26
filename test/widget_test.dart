import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dube/l10n/app_localizations.dart';
import 'package:dube/l10n/locale_controller.dart';
import 'package:dube/main.dart';
import 'package:dube/widgets/ad_banner_bar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'selected_language_code': 'en',
      'has_selected_language': true,
    });
    await LocaleController.instance.load();
  });

  testWidgets('Dube app boots with MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const DubeApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.textContaining('Dube'), findsWidgets);
  });

  testWidgets('AdBannerBar renders local sponsor card gracefully', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: DubeApp.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          bottomNavigationBar: AdBannerBar(),
        ),
      ),
    );
    expect(find.byType(AdBannerBar), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
  });
}
