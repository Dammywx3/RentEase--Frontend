class VerifyOtpState {
  const VerifyOtpState({
    this.loading = false,
    this.error,
    this.verified = false,
  });

  final bool loading;
  final String? error;
  final bool verified;

  VerifyOtpState copyWith({bool? loading, String? error, bool? verified}) {
    return VerifyOtpState(
      loading: loading ?? this.loading,
      error: error,
      verified: verified ?? this.verified,
    );
  }
}
