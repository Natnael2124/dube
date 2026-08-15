class CustomerReliabilityStats {
  const CustomerReliabilityStats({
    required this.customerId,
    required this.settledDebtsCount,
    required this.activeDebtsCount,
    required this.overdueDebtsCount,
    required this.onTimeSettledCount,
    required this.totalLifetimeBorrowed,
    required this.totalLifetimeRepaid,
  });

  final int customerId;
  final int settledDebtsCount;
  final int activeDebtsCount;
  final int overdueDebtsCount;
  final int onTimeSettledCount;
  final double totalLifetimeBorrowed;
  final double totalLifetimeRepaid;

  int get totalDebtsCount =>
      settledDebtsCount + activeDebtsCount + overdueDebtsCount;

  int get openDebtsCount => activeDebtsCount + overdueDebtsCount;

  double get onTimeRate =>
      settledDebtsCount == 0 ? 0.0 : (onTimeSettledCount / settledDebtsCount);

  String get onTimeRateDisplay {
    if (settledDebtsCount == 0) return 'No settled debts yet';
    final pct = (onTimeRate * 100).toStringAsFixed(0);
    return '$onTimeSettledCount/$settledDebtsCount settled on or before due date ($pct%)';
  }

  String get trustLabel {
    if (overdueDebtsCount > 0) return 'Needs Attention';
    if (settledDebtsCount >= 3 && onTimeRate >= 0.8) return 'Highly Reliable';
    if (settledDebtsCount >= 1 && onTimeRate >= 0.7) return 'Reliable';
    if (totalDebtsCount == 0) return 'New Customer';
    return 'Good Standing';
  }

  String get quickSummary {
    if (overdueDebtsCount > 0) {
      return '⚠️ $overdueDebtsCount overdue account${overdueDebtsCount > 1 ? 's' : ''} · Needs Attention';
    }
    if (settledDebtsCount > 0) {
      final onTimeText = onTimeSettledCount == settledDebtsCount
          ? '✓ $settledDebtsCount debt${settledDebtsCount > 1 ? 's' : ''} settled on time'
          : '✓ $settledDebtsCount settled ($onTimeSettledCount on time)';
      return '$onTimeText · $trustLabel';
    }
    if (openDebtsCount > 0) {
      return '✓ $openDebtsCount active Dube · Good Standing';
    }
    return '✓ New Customer · Clean Slate';
  }

  static const empty = CustomerReliabilityStats(
    customerId: 0,
    settledDebtsCount: 0,
    activeDebtsCount: 0,
    overdueDebtsCount: 0,
    onTimeSettledCount: 0,
    totalLifetimeBorrowed: 0.0,
    totalLifetimeRepaid: 0.0,
  );
}
