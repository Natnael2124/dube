import 'package:flutter_test/flutter_test.dart';
import 'package:dube/models/debt_record.dart';
import 'package:dube/utils/formatters.dart';

void main() {
  group('Per-Debt Currency & Formatter Tests', () {
    test('DebtRecord defaults currency to ETB', () {
      const debt = DebtRecord(
        customerId: 1,
        itemsDescription: 'Oil 5L',
        totalAmount: 450.0,
        dueDate: '2026-09-01',
        createdAt: '2026-08-26',
        status: DebtStatus.active,
      );

      expect(debt.currency, 'ETB');
      expect(formatEtb(debt.totalAmount, debt.currency), 'ETB 450.00');
    });

    test('DebtRecord supports custom currencies (USD, EUR, ብር, Qarshii, KES)', () {
      const usdDebt = DebtRecord(
        customerId: 1,
        itemsDescription: 'Electronics',
        totalAmount: 120.50,
        currency: r'$',
        dueDate: '2026-09-01',
        createdAt: '2026-08-26',
        status: DebtStatus.active,
      );

      expect(usdDebt.currency, r'$');
      expect(formatEtb(usdDebt.totalAmount, usdDebt.currency), r'$ 120.50');

      const birrDebt = DebtRecord(
        customerId: 2,
        itemsDescription: 'Teff 50kg',
        totalAmount: 7500.0,
        currency: 'ብር',
        dueDate: '2026-09-01',
        createdAt: '2026-08-26',
        status: DebtStatus.active,
      );

      expect(birrDebt.currency, 'ብር');
      expect(formatEtb(birrDebt.totalAmount, birrDebt.currency), 'ብር 7,500.00');
    });

    test('DebtRecord toMap and fromMap serialize currency correctly', () {
      const customDebt = DebtRecord(
        id: 10,
        customerId: 3,
        itemsDescription: 'Imported Coffee',
        totalAmount: 85.0,
        amountPaid: 20.0,
        currency: 'EUR',
        dueDate: '2026-09-01',
        createdAt: '2026-08-26',
        status: DebtStatus.active,
      );

      final map = customDebt.toMap();
      expect(map['currency'], 'EUR');

      final reconstructed = DebtRecord.fromMap(map);
      expect(reconstructed.id, 10);
      expect(reconstructed.currency, 'EUR');
      expect(reconstructed.remainingBalance, 65.0);
      expect(formatEtb(reconstructed.remainingBalance, reconstructed.currency), 'EUR 65.00');
    });

    test('DebtRecord fromMap falls back to ETB if currency is missing in legacy DB', () {
      final legacyMap = <String, Object?>{
        'id': 5,
        'customer_id': 1,
        'items_description': 'Flour 25kg',
        'total_amount': 2500.0,
        'amount_paid': 0.0,
        'due_date': '2026-09-01',
        'created_at': '2026-08-26',
        'status': 'active',
      };

      final legacyDebt = DebtRecord.fromMap(legacyMap);
      expect(legacyDebt.currency, 'ETB');
      expect(formatEtb(legacyDebt.totalAmount, legacyDebt.currency), 'ETB 2,500.00');
    });

    test('Formatters format with default and custom currencies', () {
      expect(formatEtb(100.0), 'ETB 100.00');
      expect(formatEtb(1500.25, 'KES'), 'KES 1,500.25');
      expect(formatCurrency(50.0, 'Qarshii'), 'Qarshii 50.00');
    });
  });
}
