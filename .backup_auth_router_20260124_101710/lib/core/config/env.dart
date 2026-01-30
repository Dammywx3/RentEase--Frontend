import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<void> load() async {
    // Safe load: don't crash if missing, but values may be empty.
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {}
  }

  static String get baseUrl => (dotenv.env['BASE_URL'] ?? '').trim();

  static String get organizationId => (dotenv.env['ORGANIZATION_ID'] ?? '').trim();

  static bool get isReady => baseUrl.isNotEmpty && organizationId.isNotEmpty;
}
