class HistoryAction {
  static const String created = 'created';
  static const String partialPayment = 'partial_payment';
  static const String settled = 'settled';
  static const String extendedDeadline = 'extended_deadline';
  static const String adjusted = 'adjusted';

  static String label(String actionType) {
    switch (actionType) {
      case created:
        return 'Dube created';
      case partialPayment:
        return 'Partial payment';
      case settled:
        return 'Settled in full';
      case extendedDeadline:
        return 'Deadline extended';
      case adjusted:
        return 'Dube adjusted';
      default:
        return actionType;
    }
  }
}

class DebtHistory {
  const DebtHistory({
    this.id,
    required this.debtId,
    required this.actionType,
    this.note,
    this.amountChange,
    this.newDueDate,
    required this.createdAt,
  });

  final int? id;
  final int debtId;
  final String actionType;
  final String? note;
  final double? amountChange;
  final String? newDueDate;
  final String createdAt;

  DateTime get createdAtDateTime => DateTime.parse(createdAt);

  DateTime? get newDueDateTime =>
      newDueDate == null ? null : DateTime.parse(newDueDate!);

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'debt_id': debtId,
      'action_type': actionType,
      'note': note,
      'amount_change': amountChange,
      'new_due_date': newDueDate,
      'created_at': createdAt,
    };
  }

  factory DebtHistory.fromMap(Map<String, Object?> map) {
    return DebtHistory(
      id: map['id'] as int?,
      debtId: map['debt_id'] as int,
      actionType: map['action_type'] as String,
      note: map['note'] as String?,
      amountChange: (map['amount_change'] as num?)?.toDouble(),
      newDueDate: map['new_due_date'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}

/// History row plus the parent debt's item description for the timeline.
class DebtHistoryEntry {
  const DebtHistoryEntry({
    required this.history,
    required this.itemsDescription,
    required this.debtId,
  });

  final DebtHistory history;
  final String itemsDescription;
  final int debtId;
}
