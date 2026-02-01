// lib/features/auth/ui/login/login_state.dart
import 'package:flutter/material.dart';

@immutable
class LoginState {
  final String email;
  final String password;

  final bool rememberMe;
  final bool obscure;

  final bool loading;
  final String? error;

  const LoginState({
    required this.email,
    required this.password,
    required this.rememberMe,
    required this.obscure,
    required this.loading,
    required this.error,
  });

  factory LoginState.initial() => const LoginState(
        email: '',
        password: '',
        rememberMe: true,
        obscure: true,
        loading: false,
        error: null,
      );

  LoginState copyWith({
    String? email,
    String? password,
    bool? rememberMe,
    bool? obscure,
    bool? loading,
    String? error,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      obscure: obscure ?? this.obscure,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  bool get disabled => loading;
}