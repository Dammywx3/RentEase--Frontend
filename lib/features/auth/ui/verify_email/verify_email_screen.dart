// lib/features/auth/ui/verify_email/verify_email_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:rentease_frontend/core/constants/user_role.dart';
import 'package:rentease_frontend/core/network/api_client.dart';
import 'package:rentease_frontend/core/network/org_store.dart';
import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_sizes.dart';

import 'package:rentease_frontend/core/ui/scaffold/app_scaffold.dart';

import 'account_created_screen.dart';
import '../../welcome/post_login_welcome_screen.dart';

import 'verify_email_controller.dart';
import 'verify_email_state.dart';
import 'verify_purpose.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    super.key,
    required this.email,
    required this.role,
    required this.fullName,
    required this.purpose,
    this.channel = 'email',
  });

  final String email;
  final UserRole role;
  final String fullName;
  final VerifyPurpose purpose;
  final String channel;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late final VerifyEmailController _c;

  final _codeCtrl = TextEditingController();
  final _codeFocus = FocusNode();

  bool _confirming = false;
  String? _localError;

  // ✅ must match your TokenStore key
  static const String _kTokenKey = 'auth_token';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

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
    _c = VerifyEmailController(
      email: widget.email,
      purpose: widget.purpose,
      channel: widget.channel,
    )..addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _c.removeListener(_onChanged);
    _c.dispose();
    _codeCtrl.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  String get _subtitle {
    if (widget.purpose == VerifyPurpose.login) {
      return 'We sent a 6-digit code to\n${widget.email}';
    }
    return 'We sent a verification code to\n${widget.email}';
  }

  UserRole _parseUserRoleFromBackend(String raw, {required UserRole fallback}) {
    final v = raw.trim().toLowerCase();
    switch (v) {
      case 'tenant':
        return UserRole.tenant;
      case 'agent':
        return UserRole.agent;
      case 'landlord':
        return UserRole.landlord;
      case 'admin':
        return UserRole.admin;
      default:
        return fallback;
    }
  }

  Future<void> _saveToken(String token) async {
    await _storage.write(key: _kTokenKey, value: token.trim());
  }

  Future<void> _verifyNow() async {
    FocusScope.of(context).unfocus();
    setState(() => _localError = null);

    final code = _codeCtrl.text.trim();
    _c.setCode(code);

    if (code.length < 4) {
      setState(() => _localError = 'Enter the code sent to your email.');
      return;
    }

    if (widget.purpose == VerifyPurpose.login) {
      setState(() => _confirming = true);

      try {
        final api = ApiClient();
        final json = await api.post(
          '/v1/auth/login/confirm',
          data: {
            'email': widget.email.trim().toLowerCase(),
            'code': code,
          },
        );

        final token = (json['token'] ?? '').toString().trim();
        if (token.isEmpty) {
          throw Exception('Token missing from login confirm response.');
        }
        await _saveToken(token);

        final userAny = json['user'];
        final user = (userAny is Map)
            ? Map<String, dynamic>.from(userAny as Map)
            : <String, dynamic>{};

        final orgId = (user['organization_id'] ??
                user['organizationId'] ??
                '')
            .toString()
            .trim();
        if (orgId.isNotEmpty) {
          await OrgStore.writeOrgId(orgId);
        }

        final fullName =
            (user['full_name'] ?? user['fullName'] ?? user['name'] ?? '')
                .toString()
                .trim();
        final safeName = fullName.isEmpty ? 'User' : fullName;

        final roleStr = (user['role'] ?? '').toString();
        final realRole =
            _parseUserRoleFromBackend(roleStr, fallback: widget.role);

        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => PostLoginWelcomeScreen(
              fullName: safeName,
              role: realRole,
            ),
          ),
          (r) => false,
        );
        return;
      } catch (e) {
        setState(
            () => _localError = e.toString().replaceFirst('Exception: ', ''));
        return;
      } finally {
        if (mounted) setState(() => _confirming = false);
      }
    }

    // Non-login verify
    final ok = await _c.verify();
    if (!mounted || !ok) return;

    if (widget.purpose == VerifyPurpose.emailVerify) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => AccountCreatedScreen(email: widget.email)),
        (r) => false,
      );
      return;
    }

    final safeName =
        widget.fullName.trim().isEmpty ? 'User' : widget.fullName.trim();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => PostLoginWelcomeScreen(
          fullName: safeName,
          role: widget.role,
        ),
      ),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final VerifyEmailState s = _c.state;

    final textMuted = AppColors.textMuted(context);
    final busy = s.loading || _confirming;
    final disabled = s.disabled || _confirming;

    final shownError = _localError ?? s.error;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: null,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH, // Standard Horizontal Padding
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBarCentered(
                  title: 'Verify code',
                  disabled: disabled,
                  onBack: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: Text(
                    _subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                if (shownError != null) ...[
                  _Banner(text: shownError!, icon: Icons.error_outline_rounded),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (s.info != null) ...[
                  _Banner(
                      text: s.info!, icon: Icons.check_circle_outline_rounded),
                  const SizedBox(height: AppSpacing.md),
                ],

                // --- Main Frost Card ---
                _FrostCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppColors.surface(context)
                                .withValues(alpha: _alphaSurfaceSoft),
                            borderRadius: BorderRadius.circular(AppRadii.xl),
                            border: Border.all(
                              color: AppColors.overlay(
                                  context, _alphaBorderSoft),
                            ),
                          ),
                          child: Icon(
                            Icons.mark_email_read_rounded,
                            size: 40,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _CodeField(
                          controller: _codeCtrl,
                          enabled: !disabled,
                          onChanged: (v) => _c.setCode(v),
                          onSubmitted: (_) => _verifyNow(),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        _PrimaryButton(
                          text: (widget.purpose == VerifyPurpose.login)
                              ? 'Confirm'
                              : 'Verify',
                          loading: busy,
                          onPressed: busy ? null : _verifyNow,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        TextButton(
                          onPressed: disabled ? null : _c.resend,
                          child: Text(
                            s.sending ? 'Sending...' : 'Resend code',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.brandBlueSoft,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),

                        TextButton(
                          onPressed: disabled
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text(
                            'Change email',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textMuted(context),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* --------------------------------------------------------------------------
   UI COMPONENTS (Matched to Design System)
   -------------------------------------------------------------------------- */

class _TopBarCentered extends StatelessWidget {
  const _TopBarCentered({
    required this.title,
    required this.onBack,
    required this.disabled,
  });

  final String title;
  final VoidCallback onBack;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: disabled ? null : onBack,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: AppColors.overlay(context, 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted(context)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FrostCard extends StatelessWidget {
  const _FrostCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
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

class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.enabled,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlay(context, 0.04),
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: AppColors.overlay(context, 0.08)),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: TextInputType.number,
        maxLength: 6,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w900,
              letterSpacing: 8.0, // Space out the code digits
            ),
        cursorColor: AppColors.brandGreenDeep,
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
          hintText: '••••••',
          hintStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textMuted(context).withValues(alpha: 0.3),
                fontWeight: FontWeight.w900,
                letterSpacing: 8.0,
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
          height: 52,
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