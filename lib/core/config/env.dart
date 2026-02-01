import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;

    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // OK: app can run without .env
    }

    _loaded = true;
  }

  static String _cleanUrl(String v) {
    final s = v.trim();
    if (s.isEmpty) return s;
    return s.endsWith('/') ? s.substring(0, s.length - 1) : s;
  }

  static String _fromDartDefine(String key) {
    final v = String.fromEnvironment(key).trim();
    return v;
  }

  static String _fromDotEnv(String key) {
    final v = dotenv.env[key]?.trim();
    return (v == null) ? '' : v;
  }

  /// Priority:
  /// 1) --dart-define=BASE_URL=...
  /// 2) .env BASE_URL=...
  /// 3) fallback based on platform
  static String get baseUrl {
    // 1) dart-define
    final defined = _fromDartDefine('BASE_URL');
    if (defined.isNotEmpty) return _cleanUrl(defined);

    // (optional) per platform overrides, if you ever want them:
    // --dart-define=BASE_URL_ANDROID=... or BASE_URL_IOS=...
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        final a = _fromDartDefine('BASE_URL_ANDROID');
        if (a.isNotEmpty) return _cleanUrl(a);
      } else if (Platform.isIOS) {
        final i = _fromDartDefine('BASE_URL_IOS');
        if (i.isNotEmpty) return _cleanUrl(i);
      }
    }

    // 2) dotenv
    final v = _fromDotEnv('BASE_URL');
    if (v.isNotEmpty) return _cleanUrl(v);

    // (optional) per platform .env keys:
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        final a = _fromDotEnv('BASE_URL_ANDROID');
        if (a.isNotEmpty) return _cleanUrl(a);
      } else if (Platform.isIOS) {
        final i = _fromDotEnv('BASE_URL_IOS');
        if (i.isNotEmpty) return _cleanUrl(i);
      }
    }

    // 3) fallback
    if (kIsWeb) return 'http://127.0.0.1:4000';

    // Android emulator uses 10.0.2.2 to reach host machine
    if (Platform.isAndroid) return 'http://10.0.2.2:4000';

    // iOS/macOS/windows/linux (simulators/dev) can use localhost
    return 'http://127.0.0.1:4000';
  }

  static String get organizationId {
    // 1) dart-define
    final defined = _fromDartDefine('ORGANIZATION_ID');
    if (defined.isNotEmpty) return defined;

    // 2) dotenv
    final v = _fromDotEnv('ORGANIZATION_ID');
    return v.isNotEmpty ? v : '';
  }
}