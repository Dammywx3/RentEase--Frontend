import 'package:intl/intl.dart';

class Formatters {
  static final _ngn = NumberFormat.currency(symbol: '₦', decimalDigits: 2);

  static String moneyNGN(num value) => _ngn.format(value);

  static String compactMoneyNGN(num value) {
    final c = NumberFormat.compactCurrency(symbol: '₦', decimalDigits: 2);
    return c.format(value);
  }

  static String dateShort(DateTime dt) => DateFormat('d MMM, yyyy').format(dt);

  static String dateTimeShort(DateTime dt) =>
      DateFormat('d MMM, yyyy • h:mm a').format(dt);

  static String safeUpper(String? v) => (v ?? '').toUpperCase();

  static String titleCase(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) {
      return '';
    }
    return s
        .split(RegExp(r'\s+'))
        .map((w) {
          if (w.isEmpty) {
            return w;
          }
          final lower = w.toLowerCase();
          return lower[0].toUpperCase() + lower.substring(1);
        })
        .join(' ');
  }
}
