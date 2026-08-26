import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyController {
  CurrencyController._();
  static final CurrencyController instance = CurrencyController._();

  static const String _keyCurrencySymbol = 'selected_currency_symbol';
  static const String defaultCurrency = 'ETB';

  final ValueNotifier<String> notifier = ValueNotifier<String>(defaultCurrency);

  String get currentSymbol => notifier.value;

  static const List<Map<String, String>> presets = [
    {
      'code': 'ETB',
      'symbol': 'ETB',
      'label': 'ETB',
      'sublabel': 'Ethiopian Birr (Standard)',
    },
    {
      'code': 'BIRR',
      'symbol': 'ብር',
      'label': 'ብር',
      'sublabel': 'የኢትዮጵያ ብር',
    },
    {
      'code': 'QARSHII',
      'symbol': 'Qarshii',
      'label': 'Qarshii',
      'sublabel': 'Qarshii Itoophiyaa',
    },
    {
      'code': 'USD',
      'symbol': r'$',
      'label': r'$',
      'sublabel': r'US Dollar ($)',
    },
    {
      'code': 'EUR',
      'symbol': '€',
      'label': '€',
      'sublabel': 'Euro (€)',
    },
    {
      'code': 'GBP',
      'symbol': '£',
      'label': '£',
      'sublabel': 'British Pound (£)',
    },
    {
      'code': 'KES',
      'symbol': 'KSh',
      'label': 'KSh',
      'sublabel': 'Kenyan Shilling',
    },
  ];

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_keyCurrencySymbol);
      if (saved != null && saved.trim().isNotEmpty) {
        notifier.value = saved.trim();
      } else {
        notifier.value = defaultCurrency;
      }
    } catch (_) {
      notifier.value = defaultCurrency;
    }
  }

  Future<void> init() => load();

  Future<void> setCurrency(String symbol) async {
    final clean = symbol.trim();
    if (clean.isEmpty) return;
    notifier.value = clean;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCurrencySymbol, clean);
    } catch (_) {}
  }
}
