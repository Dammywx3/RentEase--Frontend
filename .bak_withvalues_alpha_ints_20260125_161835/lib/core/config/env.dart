import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // ok: allow running without .env in some environments
    }
    _loaded = true;
  }

  static String get baseUrl {
    final v = dotenv.env['BASE_URL']?.trim();
    return (v == null || v.isEmpty) ? 'http://127.0.0.1:4000' : v;
  }

  static String get organizationId {
    final v = dotenv.env['ORGANIZATION_ID']?.trim();
    return (v == null || v.isEmpty) ? '' : v;
  }
}
