import 'package:intl/intl.dart';

class AppFormatters {
  static final _dateFormat = DateFormat('dd/MM/yyyy', 'fr_FR');

  static String currency(double amount) {
    try {
      final formatter = NumberFormat.currency(
        locale: 'fr_FR',
        symbol: 'FCFA',
        decimalDigits: 0,
      );
      return formatter.format(amount);
    } catch (_) {
      return '${amount.toStringAsFixed(0)} FCFA';
    }
  }

  static String date(DateTime? date) {
    if (date == null) return '--';
    return _dateFormat.format(date);
  }

  static String percent(double rate) =>
      '${(rate * 100).toStringAsFixed(0)}%';
}
