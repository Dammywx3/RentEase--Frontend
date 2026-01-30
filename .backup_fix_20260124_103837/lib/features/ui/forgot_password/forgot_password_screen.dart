import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/scaffold/app_scaffold.dart';
import '../../../../core/ui/scaffold/app_top_bar.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/form_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../verify_otp/verify_otp_screen.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  late final ForgotPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ForgotPasswordController()..addListener(_listen);
  }

  void _listen() {
    final s = _controller.state;
    if (s.error != null && s.error!.trim().isNotEmpty) {
      ToastService.error(context, s.error!);
    }
    if (s.sent) {
      ToastService.show(context, 'Code sent. Check your phone/email.', success: true);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(emailOrPhone: _email.text.trim()),
        ),
      );
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_listen);
    _controller.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await _controller.requestReset(emailOrPhone: _email.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final loading = _controller.state.loading;

    return AppScaffold(
      topBar: const AppTopBar(title: 'Forgot Password', subtitle: 'We’ll send you a code'),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppFormField(
              controller: _email,
              label: 'Email / Phone',
              hint: 'you@example.com',
              validator: (v) => Validators.requiredField(v),
              prefixIcon: Icons.alternate_email_rounded,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: loading ? 'Sending...' : 'Send code',
              loading: loading,
              onPressed: loading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
