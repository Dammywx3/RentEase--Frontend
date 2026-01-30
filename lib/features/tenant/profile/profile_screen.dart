import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/dialog_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import 'documents/documents_list_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'verification_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Profile', subtitle: 'Account & settings'),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 28, child: Icon(Icons.person_rounded)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Treco Philippe',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      'you@example.com',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          _Tile(
            icon: Icons.edit_rounded,
            title: 'Edit Profile',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          _Tile(
            icon: Icons.settings_rounded,
            title: 'Settings',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          _Tile(
            icon: Icons.verified_user_rounded,
            title: 'Verification',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VerificationScreen()),
            ),
          ),
          _Tile(
            icon: Icons.folder_rounded,
            title: 'Documents',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DocumentsListScreen()),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Logout',
            onPressed: () async {
              final ok = await DialogService.confirm(
                context,
                title: 'Logout?',
                message: 'You will need to login again.',
                confirmText: 'Logout',
                danger: true,
              );
              if (ok && context.mounted) {
                ToastService.show(context, 'Logged out (demo)', success: true);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
