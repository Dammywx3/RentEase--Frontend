class ResetNewPasswordState {
  final bool loading;
  final bool obscure1;
  final bool obscure2;
  final String email;
  final String code;
  final String? error;
  final String? info;

  const ResetNewPasswordState({
    required this.loading,
    required this.obscure1,
    required this.obscure2,
    required this.email,
    required this.code,
    required this.error,
    required this.info,
  });

  factory ResetNewPasswordState.initial({
    required String email,
    required String code,
  }) {
    return ResetNewPasswordState(
      loading: false,
      obscure1: true,
      obscure2: true,
      email: email.trim(),
      code: code.trim(),
      error: null,
      info: null,
    );
  }

  ResetNewPasswordState copyWith({
    bool? loading,
    bool? obscure1,
    bool? obscure2,
    String? error,
    String? info,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return ResetNewPasswordState(
      loading: loading ?? this.loading,
      obscure1: obscure1 ?? this.obscure1,
      obscure2: obscure2 ?? this.obscure2,
      email: email,
      code: code,
      error: clearError ? null : (error ?? this.error),
      info: clearInfo ? null : (info ?? this.info),
    );
  }

  bool get disabled => loading;
}
