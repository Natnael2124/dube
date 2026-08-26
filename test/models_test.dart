import 'package:flutter_test/flutter_test.dart';
import 'package:dube/models/customer.dart';
import 'package:dube/models/customer_reliability.dart';
import 'package:dube/models/debt_record.dart';
import 'package:dube/models/debt_history.dart';
import 'package:dube/utils/formatters.dart';

void main() {
  group('Customer model tests', () {
    test('toMap and fromMap roundtrip correctly', () {
      const customer = Customer(
        id: 1,
        name: 'Abebe Bikila',
        phone: '0911223344',
        notes: 'Regular customer',
      );

      final map = customer.toMap();
      final fromMap = Customer.fromMap(map);

      expect(fromMap.id, 1);
      expect(fromMap.name, 'Abebe Bikila');
      expect(fromMap.phone, '0911223344');
      expect(fromMap.notes, 'Regular customer');
    });

    test('copyWith works correctly', () {
      const customer = Customer(
        id: 1,
        name: 'Abebe',
        phone: '0911000000',
      );
      final updated = customer.copyWith(name: 'Abebe Kebede');
      expect(updated.name, 'Abebe Kebede');
      expect(updated.phone, '0911000000');
      expect(updated.id, 1);
    });
  });

  group('DebtRecord model tests', () {
    test('remainingBalance and isSettled calculate properly', () {
      final debt = DebtRecord(
        id: 10,
        customerId: 1,
        itemsDescription: 'Teff 50kg, Oil 5L',
        totalAmount: 5000.0,
        amountPaid: 2000.0,
        dueDate: '2026-09-01T00:00:00.000',
        createdAt: '2026-08-01T00:00:00.000',
        status: DebtStatus.active,
      );

      expect(debt.remainingBalance, 3000.0);
      expect(debt.isSettled, isFalse);

      final settledDebt = debt.copyWith(amountPaid: 5000.0, status: DebtStatus.settled);
      expect(settledDebt.remainingBalance, 0.0);
      expect(settledDebt.isSettled, isTrue);
    });

    test('isPastDue correctly evaluates past and future dates', () {
      final pastDebt = DebtRecord(
        id: 1,
        customerId: 1,
        itemsDescription: 'Sugar 5kg',
        totalAmount: 500.0,
        amountPaid: 0.0,
        dueDate: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        createdAt: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        status: DebtStatus.active,
      );
      expect(pastDebt.isPastDue, isTrue);

      final futureDebt = DebtRecord(
        id: 2,
        customerId: 1,
        itemsDescription: 'Coffee 1kg',
        totalAmount: 400.0,
        amountPaid: 0.0,
        dueDate: DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
        status: DebtStatus.active,
      );
      expect(futureDebt.isPastDue, isFalse);
    });

    test('toMap and fromMap work accurately', () {
      final debt = DebtRecord(
        id: 3,
        customerId: 2,
        itemsDescription: 'Soap, Salt',
        totalAmount: 350.50,
        amountPaid: 150.00,
        dueDate: '2026-08-20T12:00:00.000',
        createdAt: '2026-08-15T10:00:00.000',
        status: DebtStatus.active,
      );

      final map = debt.toMap();
      final fromMap = DebtRecord.fromMap(map);

      expect(fromMap.id, 3);
      expect(fromMap.customerId, 2);
      expect(fromMap.itemsDescription, 'Soap, Salt');
      expect(fromMap.totalAmount, 350.50);
      expect(fromMap.amountPaid, 150.00);
      expect(fromMap.currency, 'ETB');
      expect(fromMap.status, DebtStatus.active);
    });
  });

  group('DebtHistory model tests', () {
    test('HistoryAction labels and map serialization', () {
      expect(HistoryAction.label(HistoryAction.created), 'Dube created');
      expect(HistoryAction.label(HistoryAction.partialPayment), 'Partial payment');
      expect(HistoryAction.label(HistoryAction.settled), 'Settled in full');
      expect(HistoryAction.label(HistoryAction.extendedDeadline), 'Deadline extended');
      expect(HistoryAction.label(HistoryAction.adjusted), 'Dube adjusted');

      final history = DebtHistory(
        id: 1,
        debtId: 10,
        actionType: HistoryAction.partialPayment,
        note: 'Half paid',
        amountChange: 250.0,
        newDueDate: null,
        createdAt: '2026-08-15T12:00:00.000',
      );

      final map = history.toMap();
      final fromMap = DebtHistory.fromMap(map);
      expect(fromMap.id, 1);
      expect(fromMap.debtId, 10);
      expect(fromMap.actionType, HistoryAction.partialPayment);
      expect(fromMap.amountChange, 250.0);
      expect(fromMap.note, 'Half paid');
    });
  });

  group('Formatters tests', () {
    test('formatEtb formats correctly', () {
      expect(formatEtb(1500.5), 'ETB 1,500.50');
      expect(formatEtb(0), 'ETB 0.00');
    });

    test('formatEtbCompact formats amount without ETB prefix', () {
      expect(formatEtbCompact(1500.5), '1,500.50');
    });

    test('formatDate and formatDateTime work with dates and ISO strings', () {
      final date = DateTime(2026, 8, 15, 14, 30);
      expect(formatDate(date), '15 Aug 2026');
      expect(formatDateIso('2026-08-15T14:30:00.000'), '15 Aug 2026');
      expect(formatDateTime(date), '15 Aug 2026 · 14:30');
    });
  });

  group('CustomerReliabilityStats tests', () {
    test('computes on-time rate and trust labels correctly', () {
      const stats = CustomerReliabilityStats(
        customerId: 1,
        settledDebtsCount: 5,
        activeDebtsCount: 1,
        overdueDebtsCount: 0,
        onTimeSettledCount: 4,
        totalLifetimeBorrowed: 10000.0,
        totalLifetimeRepaid: 8500.0,
      );

      expect(stats.totalDebtsCount, 6);
      expect(stats.openDebtsCount, 1);
      expect(stats.onTimeRate, 0.8);
      expect(stats.trustLabel, 'Highly Reliable');
      expect(stats.quickSummary, contains('Highly Reliable'));
    });

    test('flags overdue status in trust labels and quickSummary', () {
      const overdueStats = CustomerReliabilityStats(
        customerId: 2,
        settledDebtsCount: 2,
        activeDebtsCount: 0,
        overdueDebtsCount: 1,
        onTimeSettledCount: 2,
        totalLifetimeBorrowed: 3000.0,
        totalLifetimeRepaid: 1500.0,
      );

      expect(overdueStats.trustLabel, 'Needs Attention');
      expect(overdueStats.quickSummary, contains('overdue account'));
    });
  });
}
