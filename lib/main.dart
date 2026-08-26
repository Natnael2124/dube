import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:dube/l10n/app_localizations.dart';
import 'package:dube/l10n/currency_controller.dart';
import 'package:dube/l10n/fallback_localizations.dart';
import 'package:dube/l10n/locale_controller.dart';
import 'package:dube/screens/dashboard_screen.dart';
import 'package:dube/screens/language_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('AdMob init warning: $e');
    }
  }

  await LocaleController.instance.load();
  await CurrencyController.instance.load();
  runApp(const DubeApp());
}

class DubeApp extends StatelessWidget {
  const DubeApp({super.key});

  static const Color _seed = Color(0xFF0B6E4F);

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    AppLocalizations.delegate,
    FallbackMaterialLocalizationsDelegate(),
    FallbackCupertinoLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );

    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.instance.notifier,
      builder: (context, locale, _) {
        return ValueListenableBuilder<String>(
          valueListenable: CurrencyController.instance.notifier,
          builder: (context, currencySymbol, _) {
            return MaterialApp(
              title: 'ድቤ · Dube',
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.system,
              theme: _buildTheme(lightScheme),
              darkTheme: _buildTheme(darkScheme),
              locale: locale ?? const Locale('en', ''),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: localizationsDelegates,
              home: locale == null
                  ? const LanguageSelectionScreen()
                  : const DashboardScreen(),
            );
          },
        );
      },
    );
  }

  ThemeData _buildTheme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
