import 'package:rentease_frontend/shared/models/user_model.dart';

sealed class RegisterState {
  const RegisterState();

  const factory RegisterState.idle() = RegisterIdle;
  const factory RegisterState.loading() = RegisterLoading;
  const factory RegisterState.success(UserModel user) = RegisterSuccess;
  const factory RegisterState.error(String message) = RegisterError;

  /// Compatibility getters used by UI screens
  bool get loading => this is RegisterLoading;
  String? get error => this is RegisterError ? (this as RegisterError).message : null;
  UserModel? get user => this is RegisterSuccess ? (this as RegisterSuccess).user : null;
}

class RegisterIdle extends RegisterState {
  const RegisterIdle();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  const RegisterSuccess(this.user);
  final UserModel user;
}

class RegisterError extends RegisterState {
  const RegisterError(this.message);
  final String message;
}
