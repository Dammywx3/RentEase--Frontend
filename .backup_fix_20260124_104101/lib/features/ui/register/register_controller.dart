import 'package:rentease_frontend/features/auth/data/auth_repo.dart';
import 'package:rentease_frontend/shared/models/user_model.dart';

class RegisterController {
  RegisterController({AuthRepo? repo}) : _repo = repo ?? AuthRepo();
  final AuthRepo _repo;

  Future<UserModel?> register({
    required String fullName,
    required String email,
    required String password,
    required String role, // 'tenant' | 'agent' | ...
  }) {
    return _repo.register(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );
  }
}
