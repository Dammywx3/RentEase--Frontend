import 'package:flutter/foundation.dart';
import 'package:rentease_frontend/features/auth/data/auth_repo.dart';
import 'package:rentease_frontend/shared/models/user_model.dart';
import 'login_state.dart';

class LoginController extends ChangeNotifier {
  final AuthRepo _repo;
  LoginState _state = const LoginState.idle();

  LoginController({AuthRepo? repo}) : _repo = repo ?? AuthRepo();

  LoginState get state => _state;

  void _set(LoginState s) {
    _state = s;
    notifyListeners();
  }

  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
    String? organizationId,
  }) async {
    _set(const LoginState.loading());
    try {
      final user = await _repo.login(
        emailOrPhone: emailOrPhone,
        password: password,
        organizationId: organizationId,
      );
      _set(LoginState.success(user));
      return user;
    } catch (e) {
      _set(LoginState.error(e.toString()));
      rethrow;
    }
  }
}
