import 'package:flutter/foundation.dart';
import 'package:rentease_frontend/features/auth/data/auth_repo.dart';
import 'package:rentease_frontend/shared/models/user_model.dart';
import 'register_state.dart';

class RegisterController extends ChangeNotifier {
  final AuthRepo _repo;
  RegisterState _state = const RegisterState.idle();

  RegisterController({AuthRepo? repo}) : _repo = repo ?? AuthRepo();

  RegisterState get state => _state;

  void _set(RegisterState s) {
    _state = s;
    notifyListeners();
  }

  Future<UserModel> register({
    required String fullName,
    required String emailOrPhone,
    required String password,
    required String role, // tenant | landlord | agent | admin
  }) async {
    _set(const RegisterState.loading());
    try {
      final user = await _repo.register(
        fullName: fullName,
        emailOrPhone: emailOrPhone,
        password: password,
        role: role,
      );
      _set(RegisterState.success(user));
      return user;
    } catch (e) {
      _set(RegisterState.error(e.toString()));
      rethrow;
    }
  }
}
