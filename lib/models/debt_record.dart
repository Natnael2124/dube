class DebtStatus {
  static const String active = 'active';
  static const String settled = 'settled';
  static const String overdue = 'overdue';

  static const List<String> values = [active, settled, overdue];
}

class DebtRecord {
  const DebtRecord({
    this.id,
    required this.customerId,
    required this.itemsDescription,
    required this.totalAmount,
    this.amountPaid = 0.0,
    this.currency = 'ETB',
    required this.dueDate,
    required this.createdAt,
    required this.status,
  });

  final int? id;
  final int customerId;
  final String itemsDescription;
  final double totalAmount;
  final double amountPaid;
  final String currency;
  final String dueDate;
  final String createdAt;
  final String status;

  double get remainingBalance {
    final remaining = totalAmount - amountPaid;
    return remaining < 0 ? 0 : remaining;
  }

  bool get isSettled =>
      status == DebtStatus.settled || remainingBalance <= 0.005;

  DateTime get dueDateTime => DateTime.parse(dueDate);

  DateTime get createdAtDateTime => DateTime.parse(createdAt);

  bool get isPastDue {
    if (isSettled) return false;
    final due = dueDateTime;
    final now = DateTime.now();
    final dueDay = DateTime(due.year, due.month, due.day);
    final today = DateTime(now.year, now.month, now.day);
    return dueDay.isBefore(today);
  }

  DebtRecord copyWith({
    int? id,
    int? customerId,
    String? itemsDescription,
    double? totalAmount,
    double? amountPaid,
    String? currency,
    String? dueDate,
    String? createdAt,
    String? status,
  }) {
    return DebtRecord(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      itemsDescription: itemsDescription ?? this.itemsDescription,
      totalAmount: totalAmount ?? this.totalAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      currency: currency ?? this.currency,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'customer_id': customerId,
      'items_description': itemsDescription,
      'total_amount': totalAmount,
      'amount_paid': amountPaid,
      'currency': currency,
      'due_date': dueDate,
      'created_at': createdAt,
      'status': status,
    };
  }

  factory DebtRecord.fromMap(Map<String, Object?> map) {
    return DebtRecord(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      itemsDescription: map['items_description'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      amountPaid: (map['amount_paid'] as num?)?.toDouble() ?? 0.0,
      currency: (map['currency'] as String?)?.trim().isNotEmpty == true
          ? (map['currency'] as String).trim()
          : 'ETB',
      dueDate: map['due_date'] as String,
      createdAt: map['created_at'] as String,
      status: map['status'] as String,
    );
  }
}

class DashboardStats {
  const DashboardStats({
    required this.totalActiveDube,
    required this.overdueAccounts,
    required this.totalBorrowers,
  });

  final double totalActiveDube;
  final int overdueAccounts;
  final int totalBorrowers;

  static const empty = DashboardStats(
    totalActiveDube: 0,
    overdueAccounts: 0,
    totalBorrowers: 0,
  );
}


