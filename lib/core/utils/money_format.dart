// core/utils/money_format.dart
// Shared money formatting helpers.
// Keep UI screens clean by using shared formatters.

/// Convert currency code to display symbol.
/// Keep currency in model as code (NGN, USD...) and only convert in UI.
String currencySymbol(String code) {
  switch (code.toUpperCase()) {
    case 'NGN':
      return '₦';
    case 'USD':
      return r'$';
    case 'GBP':
      return '£';
    case 'EUR':
      return '€';
    default:
      // Fallback: show the code if we don't know the symbol
      // (you can change this to return '' if you prefer no prefix)
      return code.toUpperCase();
  }
}

/// Internal: add symbol safely (no double prefix).
String _prefixSymbol(String symbol, String amountText) {
  final t = amountText.trim();
  if (t.isEmpty) return symbol;

  // Already has the symbol
  if (t.startsWith(symbol)) return t;

  // Already has common currency symbols/codes at start (avoid double)
  final upper = t.toUpperCase();
  const commonSymbols = ['₦', r'$', '£', '€'];
  const commonCodes = ['NGN', 'USD', 'GBP', 'EUR'];

  if (commonSymbols.any(t.startsWith)) return t;
  if (commonCodes.any((c) => upper.startsWith(c))) return t;

  return '$symbol$t';
}

/// Formats with commas (integer style) without adding any symbol.
/// 1200000 -> 1,200,000
String fmtWithCommas(num v) {
  final isNeg = v < 0;
  final s = v.abs().toInt().toString();

  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    buf.write(s[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
      buf.write(',');
    }
  }

  return isNeg ? '-$buf' : '$buf';
}

/// Formats 1200000 -> ₦1,200,000 (default NGN)
String fmtMoney(num v, {String currencyCode = 'NGN'}) {
  final sym = currencySymbol(currencyCode);
  final amount = fmtWithCommas(v);
  return _prefixSymbol(sym, amount);
}

/// Backwards-compatible: Formats 1200000 -> ₦1,200,000
String fmtNaira(num v) => fmtMoney(v, currencyCode: 'NGN');

/// Formats compact like 1200000 -> ₦1.2M
/// - removes trailing .0 (₦1.0M -> ₦1M)
/// - supports any currency code
String fmtMoneyCompact(num v, {String currencyCode = 'NGN'}) {
  final sym = currencySymbol(currencyCode);

  final n = v.toDouble();
  final abs = n.abs();

  String amount;
  if (abs >= 1000000000) {
    amount = (n / 1000000000).toStringAsFixed(1) + 'B';
  } else if (abs >= 1000000) {
    amount = (n / 1000000).toStringAsFixed(1) + 'M';
  } else if (abs >= 1000) {
    amount = (n / 1000).toStringAsFixed(1) + 'K';
  } else {
    // For small numbers, use comma formatting (no decimals)
    amount = fmtWithCommas(n);
  }

  // Remove trailing .0 before suffix (e.g., 1.0M -> 1M)
  amount = amount.replaceAllMapped(
    RegExp(r'(-?\d+)\.0([KMB])$'),
    (m) => '${m[1]}${m[2]}',
  );

  return _prefixSymbol(sym, amount);
}

/// Backwards-compatible: Formats 1200000 -> ₦1.2M
String fmtNairaCompact(num v) => fmtMoneyCompact(v, currencyCode: 'NGN');