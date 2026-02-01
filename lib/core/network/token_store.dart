import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple token persistence used by ApiClient's tokenProvider.
/// Keeps auth working across app restarts.
class TokenStore {
  TokenStore._();

  static const _storage = FlutterSecureStorage();
  static const _kToken = 'auth_token';

  static Future<void> writeToken(String token) async {
    await _storage.write(key: _kToken, value: token);
  }

  static Future<String?> readToken() async {
    return _storage.read(key: _kToken);
  }

  static Future<void> clear() async {
    await _storage.delete(key: _kToken);
  }
}
