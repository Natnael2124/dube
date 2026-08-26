import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dube/l10n/currency_controller.dart';
import 'package:dube/utils/formatters.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CurrencyController & Formatter Tests', () {
    test('Defaults to ETB when no currency is saved', () async {
      final controller = CurrencyController.instance;
      await controller.load();
      expect(controller.currentSymbol, 'ETB');
      expect(formatEtb(150.0), 'ETB 150.00');
    });

    test('Setting currency symbol updates notifier and formatEtb', () async {
      final controller = CurrencyController.instance;
      await controller.setCurrency('ብር');
      expect(controller.currentSymbol, 'ብር');
      expect(formatEtb(2500.5), 'ብር 2,500.50');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_currency_symbol'), 'ብር');

      // Test Qarshii
      await controller.setCurrency('Qarshii');
      expect(controller.currentSymbol, 'Qarshii');
      expect(formatEtb(100.0), 'Qarshii 100.00');

      // Test USD ($)
      await controller.setCurrency(r'$');
      expect(controller.currentSymbol, r'$');
      expect(formatEtb(99.99), r'$ 99.99');

      // Reset back to ETB for subsequent tests
      await controller.setCurrency('ETB');
    });

    test('Custom formatCurrency supports passing explicit symbol override', () {
      expect(formatCurrency(50.0, 'EUR'), 'EUR 50.00');
      expect(formatCurrency(75.25, 'KSh'), 'KSh 75.25');
    });
  });
}
