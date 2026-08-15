import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dube/main.dart';
import 'package:dube/widgets/ad_banner_bar.dart';

void main() {
  testWidgets('Dube app boots with MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const DubeApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.textContaining('Dube'), findsWidgets);
  });

  testWidgets('AdBannerBar renders local sponsor card gracefully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AdBannerBar(),
        ),
      ),
    );
    expect(find.byType(AdBannerBar), findsOneWidget);
    expect(find.textContaining('Call · ደውል'), findsOneWidget);
  });
}
