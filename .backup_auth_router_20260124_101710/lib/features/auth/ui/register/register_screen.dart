import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rentease_frontend/app/router/routes.dart';
import 'package:rentease_frontend/core/constants/enums.dart';
import 'package:rentease_frontend/features/auth/ui/register/register_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const routeName = AppRoutes.register;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullName = TextEditingController();
  final _emailOrPhone = TextEditingController();
  final _password = TextEditingController();

  UserRole _role = UserRole.tenant;
  bool _loading = false;

  @override
  void dispose() {
    _fullName.dispose();
    _emailOrPhone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      final ctrl = RegisterController.of(context);

      final user = await ctrl.register(
        fullName: _fullName.text,
        emailOrPhone: _emailOrPhone.text,
        password: _password.text,
        role: _role,
      );

      if (!mounted) return;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Please try again.')),
        );
        return;
      }

      // ✅ Don't pop() (can crash GoRouter if register was opened via go()).
      // Route to home based on role.
      final dest = (user.role == UserRole.agent) ? AppRoutes.agentHome : AppRoutes.tenantHome;
      context.go(dest);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _fullName, decoration: const InputDecoration(labelText: 'Full name')),
            const SizedBox(height: 12),
            TextField(controller: _emailOrPhone, decoration: const InputDecoration(labelText: 'Email (phone not supported yet)')),
            const SizedBox(height: 12),
            TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              value: _role,
              items: const [
                DropdownMenuItem(value: UserRole.tenant, child: Text('Tenant')),
                DropdownMenuItem(value: UserRole.landlord, child: Text('Landlord')),
                DropdownMenuItem(value: UserRole.agent, child: Text('Agent')),
              ],
              onChanged: (v) => setState(() => _role = v ?? UserRole.tenant),
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: Text(_loading ? 'Creating...' : 'Create account'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
