import 'package:rentease_frontend/features/auth/data/auth_repo.dart';
import 'package:rentease_frontend/shared/models/user_model.dart';

class LoginController {
  LoginController({AuthRepo? repo}) : _repo = repo ?? AuthRepo();
  final AuthRepo _repo;

  Future<UserModel?> login({
    required String emailOrPhone,
    required String password,
  }) async {
    // backend login is email-only today
    return _repo.login(email: emailOrPhone, password: password);
  }
}
