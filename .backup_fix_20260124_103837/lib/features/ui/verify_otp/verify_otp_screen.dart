import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/ui/scaffold/app_scaffold.dart';
import '../../../../core/ui/scaffold/app_top_bar.dart';
import '../../../../shared/services/toast_service.dart';
import '../../../../shared/widgets/primary_button.dart';
import 'verify_otp_controller.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key, required this.emailOrPhone});

  final String emailOrPhone;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otp = TextEditingController();
  late final VerifyOtpController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VerifyOtpController()..addListener(_listen);
  }

  void _listen() {
    final s = _controller.state;
    if (s.error != null && s.error!.trim().isNotEmpty) {
      ToastService.error(context, s.error!);
    }
    if (s.verified) {
      ToastService.show(context, 'Verified successfully.', success: true);
      Navigator.of(context).pop(true);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_listen);
    _controller.dispose();
    _otp.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final otp = _otp.text.trim();
    if (otp.length < 4) {
      ToastService.error(context, 'Enter the OTP code.');
      return;
    }
    await _controller.verify(emailOrPhone: widget.emailOrPhone, otp: otp);
  }

  @override
  Widget build(BuildContext context) {
    final loading = _controller.state.loading;

    return AppScaffold(
      topBar: const AppTopBar(title: 'Verify OTP', subtitle: 'Enter the code you received'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sent to', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(widget.emailOrPhone, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.lg),
          Text('OTP Code', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _otp,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              hintText: '6-digit code',
              prefixIcon: Icon(Icons.verified_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: loading ? 'Verifying...' : 'Verify',
            loading: loading,
            onPressed: loading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
