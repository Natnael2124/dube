import 'package:dube/models/customer.dart';
import 'package:dube/models/debt_record.dart';

/// A debt row joined with its customer, used on the dashboard list.
class DebtorEntry {
  const DebtorEntry({
    required this.customer,
    required this.debt,
  });

  final Customer customer;
  final DebtRecord debt;
}
