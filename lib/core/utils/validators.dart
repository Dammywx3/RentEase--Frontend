class Validators {
  const Validators._();

  static String? required(String? v, {String message = 'Required'}) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return message;
    return null;
  }

  static String? email(String? v, {String message = 'Enter a valid email'}) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return message;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    return ok ? null : message;
  }

  static String? minLen(String? v, int min, {String? message}) {
    final value = (v ?? '').trim();
    if (value.length < min) {
      return message ?? 'Must be at least $min characters';
    }
    return null;
  }

  static String? phone(String? v, {String message = 'Enter a valid phone'}) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return message;

    // Allow +, spaces, dashes; require 7-15 digits total
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) return message;
    return null;
  }
}
