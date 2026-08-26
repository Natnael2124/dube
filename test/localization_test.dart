import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dube/l10n/app_localizations.dart';
import 'package:dube/l10n/locale_controller.dart';
import 'package:dube/models/customer_reliability.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppLocalizations Trilingual Translation Tests', () {
    test('English translations match core requirements', () {
      final l10n = AppLocalizations(const Locale('en', ''));
      expect(l10n.appTitle, 'Dube');
      expect(l10n.totalBalance, 'Total Balance');
      expect(l10n.customers, 'Customers');
      expect(l10n.recordDebt, 'Record Debt');
      expect(l10n.recordPayment, 'Record Payment');
      expect(l10n.name, 'Customer Name');
      expect(l10n.phone, 'Phone Number');
      expect(l10n.amountEtb, 'Total Amount (ETB)');
      expect(l10n.dueDate, 'Due Date');
      expect(l10n.save, 'Save');
      expect(l10n.cancel, 'Cancel');
      expect(l10n.delete, 'Delete');
      expect(l10n.all, 'All');
      expect(l10n.paid, 'Settled');
      expect(l10n.unpaid, 'Unpaid');
      expect(l10n.language, 'Language');
    });

    test('Amharic (አማርኛ) translations match core requirements', () {
      final l10n = AppLocalizations(const Locale('am', ''));
      expect(l10n.appTitle, 'ድቤ');
      expect(l10n.totalBalance, 'ጠቅላላ ቀሪ');
      expect(l10n.customers, 'ደንበኞች');
      expect(l10n.recordDebt, 'ዕዳ መዝግብ');
      expect(l10n.recordPayment, 'ክፍያ መዝግብ');
      expect(l10n.name, 'ስም');
      expect(l10n.phone, 'ስልክ ቁጥር');
      expect(l10n.amountEtb, 'መጠን (ብር)');
      expect(l10n.dueDate, 'የቀጠሮ ቀን');
      expect(l10n.save, 'መዝግብ');
      expect(l10n.cancel, 'ሰርዝ');
      expect(l10n.delete, 'አጥፋ');
      expect(l10n.all, 'ሁሉም');
      expect(l10n.paid, 'የተከፈለ');
      expect(l10n.unpaid, 'ያልተከፈለ');
      expect(l10n.language, 'ቋንቋ');
    });

    test('Afaan Oromoo translations match core requirements', () {
      final l10n = AppLocalizations(const Locale('om', ''));
      expect(l10n.appTitle, 'Dube');
      expect(l10n.totalBalance, 'Haftee Waliigalaa');
      expect(l10n.customers, 'Maamiltoota');
      expect(l10n.recordDebt, 'Liqii Galmeessi');
      expect(l10n.recordPayment, 'Kaffaltii Galmeessi');
      expect(l10n.name, 'Maqaa');
      expect(l10n.phone, 'Lakkoofsa Bilbilaa');
      expect(l10n.amountEtb, 'Hamma Qarshii (ETB)');
      expect(l10n.dueDate, 'Guyyaa Beellamaa');
      expect(l10n.save, 'Galmeessi');
      expect(l10n.cancel, 'Haqi');
      expect(l10n.delete, 'Balleessi');
      expect(l10n.all, 'Hundaa');
      expect(l10n.paid, 'Kaffalame');
      expect(l10n.unpaid, 'Hin Kaffalamne');
      expect(l10n.language, 'Afaan');
    });

    test('Trust labels and summaries format across all languages', () {
      const stats = CustomerReliabilityStats(
        customerId: 1,
        settledDebtsCount: 3,
        activeDebtsCount: 1,
        overdueDebtsCount: 0,
        onTimeSettledCount: 3,
        totalLifetimeBorrowed: 3000.0,
        totalLifetimeRepaid: 3000.0,
      );

      final en = AppLocalizations(const Locale('en', ''));
      final am = AppLocalizations(const Locale('am', ''));
      final om = AppLocalizations(const Locale('om', ''));

      expect(en.trustLabelFor(stats), 'Highly Reliable');
      expect(am.trustLabelFor(stats), 'በጣም አስተማማኝ');
      expect(om.trustLabelFor(stats), 'Baay\'ee Amanamaa');

      expect(en.quickSummaryFor(stats), contains('settled'));
      expect(am.quickSummaryFor(stats), contains('የተከፈሉ'));
      expect(om.quickSummaryFor(stats), contains('kaffalaman'));
    });
  });

  group('LocaleController State & Persistence Tests', () {
    test('Defaults to null when not configured on first launch', () async {
      final controller = LocaleController.instance;
      await controller.load();
      expect(controller.locale, isNull);
      expect(controller.isConfigured, isFalse);
    });

    test('Setting locale persists to SharedPreferences and updates notifier', () async {
      final controller = LocaleController.instance;
      await controller.setLocale(const Locale('am', ''));
      expect(controller.locale?.languageCode, 'am');
      expect(controller.isConfigured, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_language_code'), 'am');
      expect(prefs.getBool('has_selected_language'), isTrue);

      // Re-load state from storage
      await controller.load();
      expect(controller.locale?.languageCode, 'am');
      expect(controller.isConfigured, isTrue);
    });

    test('Setting language to Afaan Oromoo (om) works and persists', () async {
      final controller = LocaleController.instance;
      await controller.setLanguageCode('om');
      expect(controller.locale?.languageCode, 'om');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_language_code'), 'om');
    });
  });
}
