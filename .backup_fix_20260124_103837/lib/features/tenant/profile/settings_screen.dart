import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool push = true;
  bool sms = false;
  bool email = true;
  bool twoFA = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Settings', subtitle: 'Notifications & security'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            value: push,
            onChanged: (v) => setState(() => push = v),
            title: const Text('Push notifications'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: sms,
            onChanged: (v) => setState(() => sms = v),
            title: const Text('SMS notifications'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: email,
            onChanged: (v) => setState(() => email = v),
            title: const Text('Email notifications'),
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: AppSpacing.lg),
          Text('Security', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            value: twoFA,
            onChanged: (v) => setState(() => twoFA = v),
            title: const Text('Two-factor authentication (2FA)'),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
