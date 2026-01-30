class ForgotPasswordState {
  const ForgotPasswordState({
    this.loading = false,
    this.error,
    this.sent = false,
  });

  final bool loading;
  final String? error;
  final bool sent;

  ForgotPasswordState copyWith({bool? loading, String? error, bool? sent}) {
    return ForgotPasswordState(
      loading: loading ?? this.loading,
      error: error,
      sent: sent ?? this.sent,
    );
  }
}
