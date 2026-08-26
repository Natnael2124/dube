import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  static const String _keyLanguageCode = 'selected_language_code';
  static const String _keyHasSelected = 'has_selected_language';

  final ValueNotifier<Locale?> notifier = ValueNotifier<Locale?>(null);

  Locale? get locale => notifier.value;
  bool get isConfigured => notifier.value != null;

  static const List<Map<String, String>> supportedLanguages = [
    {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English',
      'subtitle': 'Default international language',
      'badge': 'EN',
      'flag': '🇬🇧',
    },
    {
      'code': 'am',
      'name': 'Amharic',
      'nativeName': 'አማርኛ',
      'subtitle': 'የኢትዮጵያ የስራ ቋንቋ',
      'badge': 'አማ',
      'flag': '🇪🇹',
    },
    {
      'code': 'om',
      'name': 'Afaan Oromoo',
      'nativeName': 'Afaan Oromoo',
      'subtitle': 'Afaan Oromiyaa fi Itoophiyaa',
      'badge': 'OM',
      'flag': '🇪🇹',
    },
  ];

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSelected = prefs.getBool(_keyHasSelected) ?? false;
      final savedCode = prefs.getString(_keyLanguageCode);

      if (hasSelected && savedCode != null && ['en', 'am', 'om'].contains(savedCode)) {
        notifier.value = Locale(savedCode, '');
      } else {
        notifier.value = null; // Triggers first-run LanguageSelectionScreen
      }
    } catch (_) {
      notifier.value = null;
    }
  }

  Future<void> init() => load();

  Future<void> setLocale(Locale? locale) async {
    notifier.value = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_keyLanguageCode);
        await prefs.setBool(_keyHasSelected, false);
      } else {
        await prefs.setString(_keyLanguageCode, locale.languageCode);
        await prefs.setBool(_keyHasSelected, true);
      }
    } catch (_) {}
  }

  Future<void> setLanguageCode(String code) async {
    if (!['en', 'am', 'om'].contains(code)) return;
    await setLocale(Locale(code, ''));
  }
}
