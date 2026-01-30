import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rentease_frontend/core/constants/enums.dart';
import 'package:rentease_frontend/features/auth/ui/login/login_controller.dart';
import 'package:rentease_frontend/shared/services/toast_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = LoginController();
  final _formKey = GlobalKey<FormState>();

  final _emailOrPhone = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailOrPhone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final user = await _controller.login(
        emailOrPhone: _emailOrPhone.text.trim(),
        password: _password.text,
      );

      if (user == null) {
        setState(() => _error = 'Login failed. Please try again.');
        return;
      }

      final name = (user.fullName?.trim().isNotEmpty ?? false) ? user.fullName!.trim() : null;
      final email = user.email?.trim();

      ToastService.show(
        context,
        'Welcome back, ${name ?? email ?? 'user'}',
        success: true,
      );

      final role = user.role ?? UserRole.tenant;
      if (!mounted) return;

      switch (role) {
        case UserRole.tenant:
          context.go('/tenant');
          break;
        case UserRole.landlord:
        case UserRole.agent:
          context.go('/agent');
          break;
        case UserRole.admin:
          context.go('/agent'); // later: /admin
          break;
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _required(String? v, {String label = 'Field'}) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Sign in',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Welcome back to RentEase',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),

                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(color: cs.onErrorContainer),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailOrPhone,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username, AutofillHints.email],
                          decoration: const InputDecoration(labelText: 'Email or phone'),
                          validator: (v) => _required(v, label: 'Email or phone'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          decoration: const InputDecoration(labelText: 'Password'),
                          validator: (v) => _required(v, label: 'Password'),
                        ),
                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Sign in'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: _loading ? null : () => context.go('/forgot-password'),
                    child: const Text('Forgot password?'),
                  ),
                  TextButton(
                    onPressed: _loading ? null : () => context.go('/register'),
                    child: const Text('Create account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
