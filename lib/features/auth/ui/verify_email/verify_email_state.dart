// lib/features/auth/ui/verify_email/verify_email_state.dart

import 'verify_purpose.dart';

class VerifyEmailState {
  VerifyEmailState({
    required this.email,
    required this.purpose,
    required this.channel,
    this.code = '',
    this.loading = false,
    this.sending = false,
    this.error,
    this.info,
  });

  final String email;
  final VerifyPurpose purpose;
  final String channel;

  final String code;
  final bool loading;
  final bool sending;

  final String? error;
  final String? info;

  bool get disabled => loading || sending;

  VerifyEmailState copyWith({
    String? email,
    VerifyPurpose? purpose,
    String? channel,
    String? code,
    bool? loading,
    bool? sending,
    String? error,
    String? info,
  }) {
    return VerifyEmailState(
      email: email ?? this.email,
      purpose: purpose ?? this.purpose,
      channel: channel ?? this.channel,
      code: code ?? this.code,
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      error: error,
      info: info,
    );
  }
}