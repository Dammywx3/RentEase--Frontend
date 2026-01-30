class LoginState {
  const LoginState({this.loading = false, this.error});

  final bool loading;
  final String? error;

  LoginState copyWith({bool? loading, String? error}) {
    return LoginState(loading: loading ?? this.loading, error: error);
  }
}
