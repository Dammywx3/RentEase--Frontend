class ForgotPasswordState {
  final bool loading;
  final String email;
  final String? error;
  final String? info;

  const ForgotPasswordState({
    required this.loading,
    required this.email,
    required this.error,
    required this.info,
  });

  factory ForgotPasswordState.initial({String prefillEmail = ''}) {
    return ForgotPasswordState(
      loading: false,
      email: (prefillEmail).trim(),
      error: null,
      info: null,
    );
  }

  ForgotPasswordState copyWith({
    bool? loading,
    String? email,
    String? error,
    String? info,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return ForgotPasswordState(
      loading: loading ?? this.loading,
      email: email ?? this.email,
      error: clearError ? null : (error ?? this.error),
      info: clearInfo ? null : (info ?? this.info),
    );
  }

  bool get disabled => loading;
}
