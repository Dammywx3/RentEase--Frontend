import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_typography.dart';

import 'package:rentease_frontend/app/router/app_router.dart';
import '../register/choose_account_type_screen.dart';

import 'login_controller.dart';
import 'login_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController _c;

  bool _rememberMe = true;
  bool _didPrefill = false;

  @override
  void initState() {
    super.initState();
    _c = LoginController()..addListener(_onChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Read route args once and prefill email
    if (_didPrefill) return;
    _didPrefill = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final email = (args['email'] ?? '').toString().trim();
      if (email.isNotEmpty && _c.emailCtrl.text.trim().isEmpty) {
        _c.emailCtrl.text = email;
        // optional: put cursor at end
        _c.emailCtrl.selection = TextSelection.fromPosition(
          TextPosition(offset: _c.emailCtrl.text.length),
        );
        // optional: focus password
        Future.microtask(() => _c.passFocus.requestFocus());
      }
    }
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _c.removeListener(_onChanged);
    _c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final res = await _c.login();
    if (!mounted || res == null) return;

    // ✅ OTP required (login flow)
    if (res.requiresOtp) {
      Navigator.of(context).pushNamed(
        AppRoutes.verifyEmail,
        arguments: {
          'email': res.email,
          'fullName': 'User',
          'role': 'tenant',
          'purpose': 'login',
          'channel': 'email',
        },
      );
      return;
    }

    // ✅ direct success -> welcome screen
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.welcome,
      arguments: {
        'fullName': res.fullName ?? 'User',
        'role': res.role,
      },
    );
  }

  bool get _isIOS => Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    final LoginState s = _c.state;

    final textPrimary = AppColors.textPrimary(context);
    final textMuted = AppColors.textMuted(context);

    final showApple = _isIOS;
    final showGoogle = !showApple;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Form(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // ✅ Top bar title centered
                  SizedBox(
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          'Login',
                          style: AppTypography.h3(context).copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'Sign in with your email',
                    style: AppTypography.body(context).copyWith(color: textMuted),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  if (s.error != null) ...[
                    _ErrorBanner(text: s.error!),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email Address',
                          style: AppTypography.label(context).copyWith(color: textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _AuthField(
                          controller: _c.emailCtrl,
                          focusNode: _c.emailFocus,
                          hintText: 'jane.doe@email.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.mail_outline_rounded,
                          autofillHints: const [
                            AutofillHints.username,
                            AutofillHints.email
                          ],
                          enabled: !s.loading,
                          validator: (_) => null,
                          onSubmitted: (_) => _c.passFocus.requestFocus(),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        Text(
                          'Password',
                          style: AppTypography.label(context).copyWith(color: textPrimary),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _AuthField(
                          controller: _c.passCtrl,
                          focusNode: _c.passFocus,
                          hintText: '••••••••',
                          obscureText: s.obscure,
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: s.obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          onSuffixTap: s.loading ? null : _c.toggleObscure,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          enabled: !s.loading,
                          validator: (_) => null,
                          onSubmitted: (_) => _submit(),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        Row(
                          children: [
                            _RememberMe(
                              value: _rememberMe,
                              onChanged: s.loading
                                  ? null
                                  : (v) => setState(() => _rememberMe = v),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: s.loading
                                  ? null
                                  : () {
                                      Navigator.of(context).pushNamed(
                                        AppRoutes.forgotPassword,
                                        arguments: {
                                          'email': _c.emailCtrl.text.trim(),
                                        },
                                      );
                                    },
                              child: Text(
                                'Forgot password?',
                                style: AppTypography.body(context).copyWith(
                                  color: AppColors.brandBlueSoft,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),

                        _PrimaryButton(
                          text: 'Sign In',
                          loading: s.loading,
                          onPressed: s.loading ? null : _submit,
                        ),

                        const SizedBox(height: AppSpacing.lg),
                        const _OrDivider(),
                        const SizedBox(height: AppSpacing.lg),

                        if (showGoogle)
                          _GhostButton(
                            icon: FaIcon(
                              FontAwesomeIcons.google,
                              size: 18,
                              color: AppColors.textSecondary(context),
                            ),
                            text: 'Continue with Google',
                            onPressed: s.loading ? null : () {},
                          )
                        else
                          _GhostButton(
                            icon: FaIcon(
                              FontAwesomeIcons.apple,
                              size: 20,
                              color: AppColors.textSecondary(context),
                            ),
                            text: 'Continue with Apple',
                            onPressed: s.loading ? null : () {},
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account? ",
                        style: AppTypography.body(context).copyWith(color: textMuted),
                      ),
                      TextButton(
                        onPressed: s.loading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ChooseAccountTypeScreen(),
                                  ),
                                );
                              },
                        child: Text(
                          'Create account',
                          style: AppTypography.body(context).copyWith(
                            color: AppColors.brandBlueSoft,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'By continuing you agree to Terms & Privacy',
                    style: AppTypography.caption(context).copyWith(color: textMuted),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface2(context).withValues(alpha: 0.70);
    final border = AppColors.border(context).withValues(alpha: 0.60);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: border),
        boxShadow: AppShadows.card(context),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.enabled = true,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  final bool obscureText;
  final bool enabled;

  final List<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final fill = AppColors.surface(context).withValues(alpha: 0.85);
    final border = AppColors.border(context);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onFieldSubmitted: onSubmitted,
      autofillHints: autofillHints,
      style: AppTypography.body(context).copyWith(
        color: AppColors.textPrimary(context),
        fontWeight: FontWeight.w700,
      ),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: fill,
        hintText: hintText,
        hintStyle: AppTypography.body(context).copyWith(
          color: AppColors.textMuted(context),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: AppColors.textMuted(context)),
        suffixIcon: suffixIcon == null
            ? null
            : IconButton(
                onPressed: onSuffixTap,
                icon: Icon(suffixIcon, color: AppColors.textMuted(context)),
              ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: BorderSide(color: border.withValues(alpha: 0.70)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          borderSide: const BorderSide(
            color: AppColors.brandBlueSoft,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _RememberMe extends StatelessWidget {
  const _RememberMe({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final disabled = onChanged == null;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.md),
      onTap: disabled ? null : () => onChanged!(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: disabled ? null : (v) => onChanged!(v ?? false),
            activeColor: AppColors.brandGreen,
          ),
          Text(
            'Remember me',
            style: AppTypography.body(context).copyWith(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    required this.loading,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.brandGreenDeep.withValues(alpha: 0.95);
    final fg = AppColors.textLight;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                text,
                style: AppTypography.button(context).copyWith(
                  color: fg,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  final Widget icon;
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final border = AppColors.border(context);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
        ),
        icon: icon,
        label: Text(
          text,
          style: AppTypography.body(context).copyWith(
            color: AppColors.textSecondary(context),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.divider(context).withValues(alpha: 0.75);
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: c)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'or',
            style: AppTypography.caption(context).copyWith(
              color: AppColors.textMuted(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: c)),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface(context).withValues(alpha: 0.85);
    final border = AppColors.border(context).withValues(alpha: 0.70);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.textSecondary(context)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body(context).copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}