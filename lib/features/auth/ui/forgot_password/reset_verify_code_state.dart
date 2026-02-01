class ResetVerifyCodeState {
  final bool loading; // for "Continue"
  final bool sending; // for "Resend"
  final String email;
  final String code;
  final String? error;
  final String? info;

  const ResetVerifyCodeState({
    required this.loading,
    required this.sending,
    required this.email,
    required this.code,
    required this.error,
    required this.info,
  });

  factory ResetVerifyCodeState.initial({required String email}) {
    return ResetVerifyCodeState(
      loading: false,
      sending: false,
      email: email.trim(),
      code: '',
      error: null,
      info: null,
    );
  }

  ResetVerifyCodeState copyWith({
    bool? loading,
    bool? sending,
    String? code,
    String? error,
    String? info,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return ResetVerifyCodeState(
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      email: email,
      code: code ?? this.code,
      error: clearError ? null : (error ?? this.error),
      info: clearInfo ? null : (info ?? this.info),
    );
  }

  bool get disabled => loading || sending;
}
