import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_sizes.dart'; // Ensure this exists or use constants

import 'package:rentease_frontend/core/ui/scaffold/app_scaffold.dart';
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

  // ---------- Explore-style alpha helpers ----------
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaSurfaceSoft =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  @override
  void initState() {
    super.initState();
    _c = LoginController()..addListener(_onChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didPrefill) return;
    _didPrefill = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      final email = (args['email'] ?? '').toString().trim();
      if (email.isNotEmpty && _c.emailCtrl.text.trim().isEmpty) {
        _c.emailCtrl.text = email;
        _c.emailCtrl.selection = TextSelection.fromPosition(
          TextPosition(offset: _c.emailCtrl.text.length),
        );
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

    if (res.requiresOtp) {
      final email = (res.email ?? _c.emailCtrl.text).toString().trim();

      Navigator.of(context).pushNamed(
        AppRoutes.verifyEmail,
        arguments: {
          'email': email,
          'fullName': (res.fullName ?? 'User').toString(),
          'role': (res.role ?? 'tenant').toString(),
          'purpose': 'login',
          'channel': 'email',
        },
      );
      return;
    }

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
    final showApple = _isIOS;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: null, // Custom header inside body
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH, // Standard Horizontal Padding
              vertical: AppSpacing.lg,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xxl),

                // --- Header ---
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sign in to access your dashboard',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted(context),
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xxl),

                if (s.error != null) ...[
                  _ErrorBanner(text: s.error!),
                  const SizedBox(height: AppSpacing.md),
                ],

                // --- Form Card (Frost Style) ---
                _FrostCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LabeledField(
                          label: 'Email Address',
                          child: _AuthField(
                            controller: _c.emailCtrl,
                            focusNode: _c.emailFocus,
                            hintText: 'damilare.vic@email.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.mail_outline_rounded,
                            autofillHints: const [
                              AutofillHints.username,
                              AutofillHints.email
                            ],
                            enabled: !s.loading,
                            onSubmitted: (_) => _c.passFocus.requestFocus(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _LabeledField(
                          label: 'Password',
                          child: _AuthField(
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
                            onSubmitted: (_) => _submit(),
                          ),
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
                                          'email': _c.emailCtrl.text.trim()
                                        },
                                      );
                                    },
                              child: Text(
                                'Forgot password?',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.brandBlueSoft,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _PrimaryButton(
                          text: 'Sign In',
                          loading: s.loading,
                          onPressed: s.loading ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
                const _OrDivider(),
                const SizedBox(height: AppSpacing.lg),

                // --- Socials ---
                if (showApple)
                  _SocialButton(
                    icon: FontAwesomeIcons.apple,
                    text: 'Continue with Apple',
                    onPressed: s.loading ? null : () {},
                  )
                else
                  _SocialButton(
                    icon: FontAwesomeIcons.google,
                    text: 'Continue with Google',
                    onPressed: s.loading ? null : () {},
                  ),

                const SizedBox(height: AppSpacing.xl),

                // --- Footer ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don’t have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted(context),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    InkWell(
                      onTap: s.loading
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ChooseAccountTypeScreen()),
                              );
                            },
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Create account',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.brandBlueSoft,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),
                Text(
                  'By continuing you agree to Terms & Privacy',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            AppColors.textMuted(context).withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* --------------------------------------------------------------------------
   UI COMPONENTS (Matched to Explore/Messages)
   -------------------------------------------------------------------------- */

class _FrostCard extends StatelessWidget {
  const _FrostCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Matches Explore logic
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
    final alphaShadow = AppSpacing.xs / AppSpacing.xxxl;

    return Material(
      color: AppColors.surface(context).withValues(alpha: alphaSurface),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.overlay(context, alphaBorder)),
          boxShadow: AppShadows.lift(
            context,
            blur: AppSpacing.xxxl,
            y: AppSpacing.xl,
            alpha: alphaShadow,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary(context),
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
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
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlay(context, 0.04), // Subtle input background
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: AppColors.overlay(context, 0.08)),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        onFieldSubmitted: onSubmitted,
        autofillHints: autofillHints,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
        cursorColor: AppColors.brandGreenDeep,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted(context).withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
          prefixIcon: prefixIcon == null
              ? null
              : Icon(
                  prefixIcon,
                  color: AppColors.textMuted(context),
                  size: 20,
                ),
          suffixIcon: suffixIcon == null
              ? null
              : InkWell(
                  onTap: onSuffixTap,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: Icon(
                    suffixIcon,
                    color: AppColors.textMuted(context),
                    size: 20,
                  ),
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
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
    final disabled = loading || onPressed == null;

    return Material(
      color: disabled
          ? AppColors.overlay(context, 0.1)
          : AppColors.brandGreenDeep.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: SizedBox(
          width: double.infinity,
          height: 52, // Standard height
          child: Center(
            child: loading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.textLight,
                    ),
                  )
                : Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: disabled
                              ? AppColors.textMuted(context)
                              : AppColors.textLight,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: alphaSurface),
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(color: AppColors.overlay(context, alphaBorder)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, size: 20, color: AppColors.textPrimary(context)),
            const SizedBox(width: AppSpacing.md),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
            ),
          ],
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
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.sm),
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.brandGreenDeep
                  : AppColors.overlay(context, 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value
                    ? AppColors.brandGreenDeep
                    : AppColors.textMuted(context).withValues(alpha: 0.5),
              ),
            ),
            child: value
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Remember me',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: AppColors.danger, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.textMuted(context).withValues(alpha: 0.2);
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: c)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'OR',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted(context),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
          ),
        ),
        Expanded(child: Container(height: 1, color: c)),
      ],
    );
  }
}