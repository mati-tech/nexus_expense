import 'package:intl/intl.dart';

final NumberFormat _currency =
    NumberFormat.currency(symbol: '\$', decimalDigits: 2);
final DateFormat _time = DateFormat('h:mm a');

String formatCurrency(double value) => _currency.format(value);

String formatSignedCurrency(double value, {required bool isIncome}) {
  final formatted = _currency.format(value.abs());
  return isIncome ? '+ $formatted' : '- $formatted';
}

String formatTime(DateTime timestamp) => _time.format(timestamp.toLocal());
