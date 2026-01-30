import 'package:flutter/material.dart';
import 'package:rentease_frontend/features/agent/applications/applications_screen.dart';
import 'package:rentease_frontend/features/agent/viewings/viewings_screen.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/bottom_sheet_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../applications/applications_screen.dart';
import '../viewings/viewings_screen.dart';
import '../tenancies/tenancies_screen.dart';
import '../maintenance/maintenance_screen.dart';
import '../payments_payouts/payment_history_screen.dart';
import 'edit_listing_screen.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({
    super.key,
    required this.listingId,
    required this.title,
    required this.status,
  });

  final String listingId;
  final String title;
  final String status;

  bool get isReadOnly =>
      status == 'pending_owner_approval' || status == 'cancelled';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Listing Detail',
        subtitle: 'Manage status & performance',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(domain: StatusDomain.listing, status: status),
          const SizedBox(height: AppSpacing.lg),

          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: const Center(
              child: Text('Performance / Media preview (MVP)'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: isReadOnly ? 'Edit (disabled)' : 'Edit',
                  onPressed: isReadOnly
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                EditListingScreen(listingId: listingId),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SecondaryButton(
                  label: 'Status actions',
                  onPressed: () => _openStatusActions(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            'Quick links',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),

          _LinkTile(
            icon: Icons.description_rounded,
            title: 'Applications',
            subtitle: 'Review and approve/reject',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => ApplicationsScreen())),
          ),
          _LinkTile(
            icon: Icons.event_available_rounded,
            title: 'Viewings',
            subtitle: 'Approve/reschedule/cancel',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => ViewingsScreen())),
          ),
          _LinkTile(
            icon: Icons.home_work_rounded,
            title: 'Tenancies',
            subtitle: 'Create & manage tenancies',
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const TenanciesScreen())),
          ),
          _LinkTile(
            icon: Icons.build_rounded,
            title: 'Maintenance',
            subtitle: 'Track requests & updates',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AgentMaintenanceScreen()),
            ),
          ),
          _LinkTile(
            icon: Icons.payments_rounded,
            title: 'Payments',
            subtitle: 'History & receipts',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()),
            ),
          ),
        ],
      ),
    );
  }

  void _openStatusActions(BuildContext context) {
    BottomSheetService.show(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status actions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.md),
          _ActionBtn(
            label: 'Publish',
            onTap: () => _toast(context, 'Publish (demo)'),
          ),
          _ActionBtn(
            label: 'Pause',
            onTap: () => _toast(context, 'Pause (demo)'),
          ),
          _ActionBtn(
            label: 'Resume',
            onTap: () => _toast(context, 'Resume (demo)'),
          ),
          _ActionBtn(
            label: 'Renew',
            onTap: () => _toast(context, 'Renew (demo)'),
          ),
          _ActionBtn(
            label: 'Cancel',
            danger: true,
            onTap: () => _toast(context, 'Cancel (demo)'),
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    Navigator.of(context).pop();
    ToastService.show(context, msg, success: true);
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.onTap,
    this.danger = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onTap,
          child: Text(
            label,
            style: TextStyle(
              color: danger ? Theme.of(context).colorScheme.error : null,
            ),
          ),
        ),
      ),
    );
  }
}
