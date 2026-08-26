import 'package:dube/l10n/currency_controller.dart';
import 'package:intl/intl.dart';

final NumberFormat _etb = NumberFormat.currency(
  locale: 'en_US',
  symbol: '',
  decimalDigits: 2,
);

final DateFormat _displayDate = DateFormat('d MMM yyyy');
final DateFormat _displayDateTime = DateFormat('d MMM yyyy · HH:mm');

String formatCurrency(double amount, [String? symbol]) {
  final sym = symbol ?? CurrencyController.instance.currentSymbol;
  return '$sym ${_etb.format(amount).trim()}';
}

String formatEtb(double amount) {
  return formatCurrency(amount);
}

String formatEtbCompact(double amount) {
  return _etb.format(amount).trim();
}

String formatDate(DateTime date) {
  return _displayDate.format(date);
}

String formatDateIso(String iso) {
  return formatDate(DateTime.parse(iso));
}

String formatDateTime(DateTime date) {
  return _displayDateTime.format(date);
}

String formatDateTimeIso(String iso) {
  return formatDateTime(DateTime.parse(iso));
}

DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool isPastDueDate(DateTime due) {
  return dateOnly(due).isBefore(dateOnly(DateTime.now()));
}
