// lib/features/auth/data/auth_di.dart
import 'package:rentease_frontend/core/network/api_client.dart';
import 'package:rentease_frontend/core/network/token_store.dart';
import 'package:rentease_frontend/features/auth/data/auth_repo.dart';

class AuthDI {
  static late final ApiClient apiClient;
  static late final AuthRepo authRepo;

  static bool _inited = false;

  /// Call once after Env.load() so Env.baseUrl is ready.
  static void init() {
    if (_inited) return;
    _inited = true;

    apiClient = ApiClient(
      tokenProvider: () async => await TokenStore.readToken(),
    );

    authRepo = AuthRepo(apiClient);
  }
}
