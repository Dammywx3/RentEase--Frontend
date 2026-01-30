// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/toast_service.dart';

import '../../../core/theme/app_colors.dart';

import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // NOTE: local-only (wire to persistence later)
  ThemeMode _appearance = ThemeMode.system;
  String _language = 'English';
  String _currency = 'NGN';
  bool _allowLocation = true;
  String _defaultCity = 'Lagos';

  // Notifications
  bool _push = true;
  bool _email = false;
  bool _sms = false;

  // Privacy & Security
  bool _biometric = true;

  // Data & Storage
  bool _wifiOnly = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.color?.withValues(alpha: 0.70);

    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Settings',
        subtitle: 'Manage preferences and privacy',
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('Preferences'),
            _GroupCard(
              children: [
                _NavTile(
                  icon: Icons.brightness_6_rounded,
                  title: 'App Appearance',
                  trailingText: _appearanceLabel(_appearance),
                  onTap: () => _openAppearancePicker(context),
                ),
                _DividerLine(),
                _NavTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  trailingText: _language,
                  onTap: () => _openPicker(
                    context,
                    title: 'Language',
                    current: _language,
                    options: const ['English', 'Yoruba', 'Igbo', 'Hausa'],
                    onPick: (v) => setState(() => _language = v),
                  ),
                ),
                _DividerLine(),
                _NavTile(
                  icon: Icons.payments_rounded,
                  title: 'Currency',
                  trailingText: _currency,
                  onTap: () => _openPicker(
                    context,
                    title: 'Currency',
                    current: _currency,
                    options: const ['NGN', 'USD'],
                    onPick: (v) => setState(() => _currency = v),
                  ),
                ),
                _DividerLine(),
                _NavTile(
                  icon: Icons.location_on_rounded,
                  title: 'Location Settings',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LocationSettingsScreen(
                        allowLocation: _allowLocation,
                        defaultCity: _defaultCity,
                        onChanged: (allow, city) {
                          setState(() {
                            _allowLocation = allow;
                            _defaultCity = city;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _SectionTitle('Notifications'),
            _GroupCard(
              children: [
                _NavTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Notification Preferences',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NotificationPreferencesScreen(
                        push: _push,
                        email: _email,
                        sms: _sms,
                        onChanged: (p, e, s) {
                          setState(() {
                            _push = p;
                            _email = e;
                            _sms = s;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _SectionTitle('Privacy & Security'),
            _GroupCard(
              children: [
                _NavTile(
                  icon: Icons.lock_rounded,
                  title: 'Change Password',
                  onTap: () => ToastService.show(
                    context,
                    'Change password (wire later)',
                    success: true,
                  ),
                ),
                _DividerLine(),
                _SwitchTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Use Biometric Lock',
                  value: _biometric,
                  onChanged: (v) => setState(() => _biometric = v),
                ),
                _DividerLine(),
                _NavTile(
                  icon: Icons.devices_rounded,
                  title: 'Login Devices',
                  onTap: () => ToastService.show(
                    context,
                    'Login devices / sessions (wire later)',
                    success: true,
                  ),
                ),
                _DividerLine(),
                _NavTile(
                  icon: Icons.verified_user_rounded,
                  title: '2FA',
                  trailingText: 'Later',
                  onTap: () => ToastService.show(
                    context,
                    '2FA (Phase 2)',
                    success: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _SectionTitle('Data & Storage'),
            _GroupCard(
              children: [
                _NavTile(
                  icon: Icons.cleaning_services_rounded,
                  title: 'Clear Cache',
                  onTap: () => _confirm(
                    context,
                    title: 'Clear cache?',
                    message:
                        'This will remove temporary files and cached data.',
                    confirmText: 'Clear',
                    isDanger: false,
                    onConfirm: () => ToastService.show(
                      context,
                      'Cache cleared (demo)',
                      success: true,
                    ),
                  ),
                ),
                _DividerLine(),
                _SwitchTile(
                  icon: Icons.wifi_rounded,
                  title: 'Wi-Fi Only Downloads',
                  value: _wifiOnly,
                  onChanged: (v) => setState(() => _wifiOnly = v),
                ),
                _DividerLine(),
                _NavTile(
                  icon: Icons.delete_sweep_rounded,
                  title: 'Delete Downloaded Documents',
                  onTap: () => _confirm(
                    context,
                    title: 'Delete downloads?',
                    message: 'This removes downloaded files from this device.',
                    confirmText: 'Delete',
                    isDanger: true,
                    onConfirm: () => ToastService.show(
                      context,
                      'Downloads deleted (demo)',
                      success: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _SectionTitle('About'),
            _GroupCard(
              children: [
                _InfoTile(
                  icon: Icons.info_outline_rounded,
                  title: 'App Version',
                  value: 'HomeStead v1.0.0',
                ),
                _DividerLine(),
                _NavTile(
                  icon: Icons.star_rate_rounded,
                  title: 'Rate HomeStead',
                  onTap: () => ToastService.show(
                    context,
                    'Open store rating (wire later)',
                    success: true,
                  ),
                ),
                _DividerLine(),
                _NavTile(
                  icon: Icons.description_rounded,
                  title: 'Terms',
                  onTap: () => ToastService.show(
                    context,
                    'Open Terms (wire later)',
                    success: true,
                  ),
                ),
                _DividerLine(),
                _NavTile(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Privacy Policy',
                  onTap: () => ToastService.show(
                    context,
                    'Open Privacy Policy (wire later)',
                    success: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _SectionTitle('Danger zone'),
            _GroupCard(
              danger: true,
              children: [
                _NavTile(
                  icon: Icons.delete_forever_rounded,
                  iconColor: Colors.redAccent,
                  title: 'Delete Account',
                  titleColor: Colors.redAccent,
                  onTap: () => _confirm(
                    context,
                    title: 'Delete account?',
                    message:
                        'This action is permanent. Your account and data may be removed.',
                    confirmText: 'Delete',
                    isDanger: true,
                    onConfirm: () => ToastService.show(
                      context,
                      'Account deleted (demo)',
                      success: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Some settings are demo-only (wire to backend/local storage later).',
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  String _appearanceLabel(ThemeMode m) {
    switch (m) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  Future<void> _openAppearancePicker(BuildContext context) async {
    final picked = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (_) => _PickerSheet<ThemeMode>(
        title: 'App Appearance',
        current: _appearance,
        options: const [
          _PickOption(value: ThemeMode.system, label: 'System'),
          _PickOption(value: ThemeMode.light, label: 'Light'),
          _PickOption(value: ThemeMode.dark, label: 'Dark'),
        ],
      ),
    );
    if (picked != null) setState(() => _appearance = picked);
  }

  Future<void> _openPicker(
    BuildContext context, {
    required String title,
    required String current,
    required List<String> options,
    required ValueChanged<String> onPick,
  }) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => _PickerSheet<String>(
        title: title,
        current: current,
        options: options
            .map((x) => _PickOption<String>(value: x, label: x))
            .toList(),
      ),
    );
    if (picked != null) onPick(picked);
  }

  void _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required bool isDanger,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            style: isDanger
                ? FilledButton.styleFrom(backgroundColor: Colors.redAccent)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

/* ---------------- Sub Screens ---------------- */

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({
    super.key,
    required this.push,
    required this.email,
    required this.sms,
    required this.onChanged,
  });

  final bool push;
  final bool email;
  final bool sms;
  final void Function(bool push, bool email, bool sms) onChanged;

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  late bool _push = widget.push;
  late bool _email = widget.email;
  late bool _sms = widget.sms;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Notification Preferences',
        subtitle: 'Choose how you want to be notified',
      ),
      child: Column(
        children: [
          _SectionTitle('Channels'),
          _GroupCard(
            children: [
              _SwitchTile(
                icon: Icons.notifications_active_rounded,
                title: 'Push Notifications',
                value: _push,
                onChanged: (v) {
                  setState(() => _push = v);
                  widget.onChanged(_push, _email, _sms);
                },
              ),
              _DividerLine(),
              _SwitchTile(
                icon: Icons.email_rounded,
                title: 'Email Notifications',
                value: _email,
                onChanged: (v) {
                  setState(() => _email = v);
                  widget.onChanged(_push, _email, _sms);
                },
              ),
              _DividerLine(),
              _SwitchTile(
                icon: Icons.sms_rounded,
                title: 'SMS Notifications',
                value: _sms,
                onChanged: (v) {
                  setState(() => _sms = v);
                  widget.onChanged(_push, _email, _sms);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle('Tip'),
          _GroupCard(
            children: const [
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Push is best for instant alerts (payments, approvals, viewings). Email/SMS can be used as backup.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({
    super.key,
    required this.allowLocation,
    required this.defaultCity,
    required this.onChanged,
  });

  final bool allowLocation;
  final String defaultCity;
  final void Function(bool allowLocation, String defaultCity) onChanged;

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  late bool _allow = widget.allowLocation;
  late String _city = widget.defaultCity;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Location Settings',
        subtitle: 'Control location usage and default city',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Location'),
          _GroupCard(
            children: [
              _SwitchTile(
                icon: Icons.location_on_rounded,
                title: 'Allow Location',
                value: _allow,
                onChanged: (v) {
                  setState(() => _allow = v);
                  widget.onChanged(_allow, _city);
                },
              ),
              _DividerLine(),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default City',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    DropdownButtonFormField<String>(
                      value: _city,
                      items: const [
                        DropdownMenuItem(value: 'Lagos', child: Text('Lagos')),
                        DropdownMenuItem(value: 'Abuja', child: Text('Abuja')),
                        DropdownMenuItem(
                          value: 'Port Harcourt',
                          child: Text('Port Harcourt'),
                        ),
                        DropdownMenuItem(
                          value: 'Ibadan',
                          child: Text('Ibadan'),
                        ),
                      ],
                      onChanged: (v) {
                        setState(() => _city = v ?? 'Lagos');
                        widget.onChanged(_allow, _city);
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle('Note'),
          _GroupCard(
            children: const [
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'We use location to improve search results and show nearby listings. You can turn it off anytime.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ---------------- UI Components ---------------- */

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: t.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children, this.danger = false});
  final List<Widget> children;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.55,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: (danger ? Colors.redAccent : Colors.black).withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.overlay(context, 0.06),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailingText;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final muted = t.textTheme.bodySmall?.color?.withValues(alpha: 0.70);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: t.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: t.textTheme.bodyMedium?.copyWith(
                  color: muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(Icons.chevron_right_rounded, color: muted),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final muted = t.textTheme.bodySmall?.color?.withValues(alpha: 0.70);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: t.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final muted = t.textTheme.bodySmall?.color?.withValues(alpha: 0.70);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: muted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: t.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: t.textTheme.bodyMedium?.copyWith(
              color: muted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/* ------------- Bottom sheet picker ------------- */

class _PickOption<T> {
  const _PickOption({required this.value, required this.label});
  final T value;
  final String label;
}

class _PickerSheet<T> extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.current,
    required this.options,
  });

  final String title;
  final T current;
  final List<_PickOption<T>> options;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            ...options.map((o) {
              final selected = o.value == current;
              return ListTile(
                title: Text(
                  o.label,
                  style: t.textTheme.bodyLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
                trailing: selected
                    ? const Icon(Icons.check_rounded)
                    : const SizedBox.shrink(),
                onTap: () => Navigator.of(context).pop(o.value),
              );
            }),
          ],
        ),
      ),
    );
  }
}
