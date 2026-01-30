// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';

import 'package:rentease_frontend/core/constants/user_role.dart';
import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_typography.dart';

import 'verify_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.role,

    // ✅ remove HomeStead hardcode
    this.brandName = 'RentEase',
    this.brandIcon = Icons.home_rounded,
  });

  final UserRole role;
  final String brandName;
  final IconData brandIcon;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _agree = false;
  bool _obscure = true;
  bool _loading = false;

  String? _nameError;
  String? _emailError;
  String? _passError;
  String? _confirmError;
  String? _agreeError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _validate() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    setState(() {
      _nameError = name.isEmpty ? 'Full name is required.' : null;
      _emailError = (email.isEmpty || !email.contains('@'))
          ? 'Enter a valid email address.'
          : null;

      _passError = pass.length < 8
          ? 'Use at least 8 characters.'
          : (!RegExp(r'[0-9]').hasMatch(pass) ? 'Add at least 1 number.' : null);

      _confirmError = confirm != pass ? 'Passwords do not match.' : null;
      _agreeError = _agree ? null : 'Please agree to Terms & Privacy.';
    });
  }

  Future<void> _submit() async {
    _validate();
    if (_nameError != null ||
        _emailError != null ||
        _passError != null ||
        _confirmError != null ||
        _agreeError != null) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerifyEmailScreen(
          email: _emailCtrl.text.trim(),
          role: widget.role,
          fullName: _nameCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimary(context);
    final textMuted = AppColors.textMuted(context);

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
              children: [
                const SizedBox(height: AppSpacing.sm),

                // ✅ Clean top row: back + perfectly centered brand
                SizedBox(
                  height: 48,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                      _BrandMarkSmall(
                        name: widget.brandName,
                        icon: widget.brandIcon,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _RolePill(role: widget.role),
                ),
                const SizedBox(height: AppSpacing.sm),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Create your account',
                    style: AppTypography.h1(context).copyWith(color: textPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Let’s get you started.",
                    style: AppTypography.body(context).copyWith(color: textMuted),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Name',
                        style: AppTypography.label(context).copyWith(color: textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _AuthField(
                        controller: _nameCtrl,
                        hintText: 'Jane Doe',
                        prefixIcon: Icons.person_outline_rounded,
                        errorText: _nameError,
                        onChanged: (_) => _validate(),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        'Email Address',
                        style: AppTypography.label(context).copyWith(color: textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _AuthField(
                        controller: _emailCtrl,
                        hintText: 'jane.doe@email.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline_rounded,
                        errorText: _emailError,
                        onChanged: (_) => _validate(),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        'Password',
                        style: AppTypography.label(context).copyWith(color: textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _AuthField(
                        controller: _passCtrl,
                        hintText: '••••••••',
                        obscureText: _obscure,
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: _obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        onSuffixTap: () => setState(() => _obscure = !_obscure),
                        errorText: _passError,
                        onChanged: (_) => _validate(),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        'Confirm Password',
                        style: AppTypography.label(context).copyWith(color: textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _AuthField(
                        controller: _confirmCtrl,
                        hintText: '••••••••',
                        obscureText: _obscure,
                        prefixIcon: Icons.lock_outline_rounded,
                        errorText: _confirmError,
                        onChanged: (_) => _validate(),
                      ),

                      const SizedBox(height: AppSpacing.md),
                      _AgreeRow(
                        value: _agree,
                        onChanged: (v) => setState(() => _agree = v),
                      ),
                      if (_agreeError != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _agreeError!,
                          style: AppTypography.caption(context).copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.lg),
                      _PrimaryButton(
                        text: 'Create account',
                        loading: _loading,
                        onPressed: _loading ? null : _submit,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.body(context).copyWith(color: textMuted),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Sign in',
                        style: AppTypography.body(context).copyWith(
                          color: AppColors.brandBlueSoft,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
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

class _RolePill extends StatelessWidget {
  const _RolePill({required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final border = AppColors.border(context).withValues(alpha: 0.70);
    final bg = AppColors.surface(context).withValues(alpha: 0.75);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: border),
      ),
      child: Text(
        role.pillLabel,
        style: AppTypography.caption(context).copyWith(
          color: AppColors.textSecondary(context),
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _BrandMarkSmall extends StatelessWidget {
  const _BrandMarkSmall({required this.name, required this.icon});

  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.brandGreen, size: 22),
        const SizedBox(width: AppSpacing.xs),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.h4(context).copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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

class _AgreeRow extends StatelessWidget {
  const _AgreeRow({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.md),
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppColors.brandGreen,
          ),
          Expanded(
            child: Text(
              'I agree to Terms & Privacy',
              style: AppTypography.body(context).copyWith(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;

  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  final bool obscureText;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final fill = AppColors.surface(context).withValues(alpha: 0.85);
    final border = AppColors.border(context);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      style: AppTypography.body(context).copyWith(
        color: AppColors.textPrimary(context),
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: fill,
        hintText: hintText,
        hintStyle: AppTypography.body(context).copyWith(
          color: AppColors.textMuted(context),
          fontWeight: FontWeight.w600,
        ),
        prefixIcon:
            prefixIcon == null ? null : Icon(prefixIcon, color: AppColors.textMuted(context)),
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
          borderSide: BorderSide(color: AppColors.brandBlueSoft, width: 1.4),
        ),
        errorText: errorText,
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