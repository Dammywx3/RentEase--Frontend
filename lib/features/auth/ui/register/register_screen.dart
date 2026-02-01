import 'package:flutter/material.dart';

import 'package:rentease_frontend/core/config/env.dart';
import 'package:rentease_frontend/core/constants/user_role.dart';
import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_typography.dart';

import 'package:rentease_frontend/app/router/app_router.dart';
import 'package:rentease_frontend/features/auth/data/auth_di.dart';
import 'package:rentease_frontend/features/auth/ui/verify_email/verify_purpose.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.role,
  });

  final UserRole role;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _obscure = true;
  bool _loading = false;
  String? _errorText;

  static final RegExp _emailRx = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();

    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  String _prettyErr(Object e) =>
      e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();

  String? _validateName(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Enter your full name.';
    if (s.length < 2) return 'Name is too short.';
    return null;
  }

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Enter your email address.';
    if (!_emailRx.hasMatch(s)) return 'Enter a valid email address.';
    return null;
  }

  String? _validatePass(String? v) {
    final s = (v ?? '');
    if (s.isEmpty) return 'Enter a password.';
    if (s.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final organizationId = Env.organizationId.trim();
      if (organizationId.isEmpty) {
        throw Exception(
          'Missing ORGANIZATION_ID. Put it in .env or pass via --dart-define.',
        );
      }

      final fullName = _fullNameCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final phone =
          _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim();
      final password = _passCtrl.text;

      final model = await AuthDI.authRepo.register(
        fullName: fullName,
        email: email,
        password: password,
        role: widget.role,
        organizationId: organizationId,
        phone: phone,
      );

      if (!mounted) return;

      final safeFullName = (model.fullName ?? fullName).trim().isEmpty
          ? 'User'
          : (model.fullName ?? fullName).trim();

      final safeRole = model.role ?? widget.role;

      Navigator.of(context).pushNamed(
        AppRoutes.verifyEmail,
        arguments: {
          'email': email,
          'fullName': safeFullName,
          'role': safeRole,
          'purpose': VerifyPurpose.emailVerify,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = _prettyErr(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimary(context);
    final textMuted = AppColors.textMuted(context);
    final roleLabel = widget.role.label;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.sm),

                // ✅ back + centered screen name
                _TopBarCentered(
                  title: 'Create account',
                  onBack: _loading ? null : () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ✅ removed duplicate "Create account" headline
                Text(
                  'Register as $roleLabel',
                  style: AppTypography.h1(context).copyWith(color: textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Enter your details to continue.',
                  style: AppTypography.body(context).copyWith(color: textMuted),
                ),

                const SizedBox(height: AppSpacing.lg),
                if (_errorText != null) ...[
                  _ErrorBanner(text: _errorText!),
                  const SizedBox(height: AppSpacing.md),
                ],

                _GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label('Full name'),
                        const SizedBox(height: AppSpacing.xs),
                        _AuthField(
                          controller: _fullNameCtrl,
                          focusNode: _fullNameFocus,
                          hintText: 'John Doe',
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.person_outline_rounded,
                          enabled: !_loading,
                          validator: _validateName,
                          onSubmitted: (_) => _emailFocus.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _Label('Email'),
                        const SizedBox(height: AppSpacing.xs),
                        _AuthField(
                          controller: _emailCtrl,
                          focusNode: _emailFocus,
                          hintText: 'john@email.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.mail_outline_rounded,
                          enabled: !_loading,
                          validator: _validateEmail,
                          onSubmitted: (_) => _phoneFocus.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _Label('Phone (optional)'),
                        const SizedBox(height: AppSpacing.xs),
                        _AuthField(
                          controller: _phoneCtrl,
                          focusNode: _phoneFocus,
                          hintText: '+234 801 234 5678',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.phone_outlined,
                          enabled: !_loading,
                          validator: (_) => null,
                          onSubmitted: (_) => _passFocus.requestFocus(),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _Label('Password'),
                        const SizedBox(height: AppSpacing.xs),
                        _AuthField(
                          controller: _passCtrl,
                          focusNode: _passFocus,
                          hintText: '••••••••',
                          obscureText: _obscure,
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: _obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          onSuffixTap: () =>
                              setState(() => _obscure = !_obscure),
                          textInputAction: TextInputAction.done,
                          enabled: !_loading,
                          validator: _validatePass,
                          onSubmitted: (_) => _submit(),
                        ),

                        const SizedBox(height: AppSpacing.lg),
                        _PrimaryButton(
                          text: 'Create account',
                          loading: _loading,
                          onPressed: _loading ? null : _submit,
                        ),

                        const SizedBox(height: AppSpacing.md),
                        Center(
                          child: TextButton(
                            onPressed:
                                _loading ? null : () => Navigator.of(context).pop(),
                            child: Text(
                              'Already have an account? Sign in',
                              style: AppTypography.body(context).copyWith(
                                color: AppColors.brandBlueSoft,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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

class _TopBarCentered extends StatelessWidget {
  const _TopBarCentered({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Text(
            title,
            style: AppTypography.h3(context).copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.label(context).copyWith(
        color: AppColors.textPrimary(context),
        fontWeight: FontWeight.w800,
      ),
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

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface2(context).withValues(alpha: 0.70);
    final border = AppColors.border(context).withValues(alpha: 0.60);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: border),
        boxShadow: AppShadows.card(context),
      ),
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
      validator: validator,
      style: AppTypography.body(context).copyWith(
        color: AppColors.textPrimary(context),
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: fill,
        hintText: hintText,
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
          borderSide: const BorderSide(color: AppColors.brandBlueSoft, width: 1.4),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.loading,
    required this.onPressed,
  });

  final String text;
  final bool loading;
  final VoidCallback? onPressed;

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
                height: 18,
                width: 18,
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