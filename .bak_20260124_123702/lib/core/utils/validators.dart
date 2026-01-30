class Validators {
  static String? requiredField(String? v, {String message = 'This field is required'}) {
    if (v == null) return message;
    if (v.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? v, {String message = 'Enter a valid email'}) {
    if (v == null || v.trim().isEmpty) return message;
    final value = v.trim();
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

  static String? phone(String? v, {String message = 'Enter a valid phone number'}) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return message;
    final ok = RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value.replaceAll(' ', ''));
    return ok ? null : message;
  }
}
