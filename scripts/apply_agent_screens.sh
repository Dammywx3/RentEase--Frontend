#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# apply_agent_screens.sh
# Writes Agent screens into correct lib/ paths in one run.
#
# Usage:
#   chmod +x scripts/apply_agent_screens.sh
#   ./scripts/apply_agent_screens.sh
# -----------------------------------------------------------------------------

ROOT="$(pwd)"

if [[ ! -f "$ROOT/pubspec.yaml" ]]; then
  echo "❌ Run this from your Flutter project root (where pubspec.yaml exists)."
  exit 1
fi

write_file () {
  local path="$1"
  mkdir -p "$(dirname "$path")"
  cat > "$path"
  echo "✅ Wrote: $path"
}

# -----------------------------------------------------------------------------
# 1) lib/features/agent/applications/application_detail_screen.dart
# -----------------------------------------------------------------------------
write_file "lib/features/agent/applications/application_detail_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/dialog_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({super.key, required this.appId, required this.title, required this.status});

  final String appId;
  final String title;
  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();

    return AppScaffold(
      topBar: const AppTopBar(title: 'Application Detail', subtitle: 'Docs + timeline'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          Text('Status: $status'),
          const SizedBox(height: AppSpacing.lg),

          Text('Documents', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => ToastService.show(context, 'Open doc (demo)', success: true),
            icon: const Icon(Icons.description_rounded),
            label: const Text('ID Card'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => ToastService.show(context, 'Open doc (demo)', success: true),
            icon: const Icon(Icons.description_rounded),
            label: const Text('Proof of income'),
          ),
          const SizedBox(height: AppSpacing.lg),

          if (s == 'pending') ...[
            PrimaryButton(
              label: 'Approve',
              onPressed: () => ToastService.show(context, 'Approved (demo)', success: true),
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Reject',
              onPressed: () async {
                final ok = await DialogService.confirm(
                  context,
                  title: 'Reject application?',
                  message: 'Reason is required in real flow.',
                  confirmText: 'Reject',
                  danger: true,
                );
                if (ok && context.mounted) ToastService.show(context, 'Rejected (demo)', success: true);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => ToastService.show(context, 'Request more info (demo)', success: true),
              icon: const Icon(Icons.mark_chat_unread_rounded),
              label: const Text('Request more info'),
            ),
          ] else ...[
            PrimaryButton(
              label: 'Send deposit/rent request',
              onPressed: () => ToastService.show(context, 'Pushed to payments (demo)', success: true),
            ),
          ],
        ],
      ),
    );
  }
}
EOF

# -----------------------------------------------------------------------------
# 2) lib/features/agent/viewings/viewings_screen.dart  (FIXED: no more placeholder)
# -----------------------------------------------------------------------------
write_file "lib/features/agent/viewings/viewings_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../core/ui/states/empty_state.dart';
import '../../../shared/widgets/status_badge.dart';
import 'viewing_detail_screen.dart';

class ViewingsScreen extends StatefulWidget {
  const ViewingsScreen({super.key});

  @override
  State<ViewingsScreen> createState() => _ViewingsScreenState();
}

class _ViewingsScreenState extends State<ViewingsScreen> {
  String _tab = 'Pending';

  final _items = const [
    _Row(id: 'vw1', title: 'Modern 2 Bedroom Apartment', date: 'Jan 25, 2026 • 2:00 PM', status: 'pending', mode: 'In-person'),
    _Row(id: 'vw2', title: 'Family Duplex (4 Beds)', date: 'Jan 26, 2026 • 11:00 AM', status: 'approved', mode: 'Virtual'),
    _Row(id: 'vw3', title: 'Cozy Studio', date: 'Jan 20, 2026 • 4:30 PM', status: 'rejected', mode: 'In-person'),
    _Row(id: 'vw4', title: 'Old Listing (Needs renew)', date: 'Jan 10, 2026 • 9:00 AM', status: 'completed', mode: 'In-person'),
    _Row(id: 'vw5', title: 'Rejected Listing', date: 'Dec 30, 2025 • 1:00 PM', status: 'cancelled', mode: 'Virtual'),
  ];

  List<_Row> get _filtered {
    switch (_tab) {
      case 'Pending':
        return _items.where((x) => x.status == 'pending').toList();
      case 'Approved':
        return _items.where((x) => x.status == 'approved').toList();
      case 'Rejected':
        return _items.where((x) => x.status == 'rejected').toList();
      case 'Completed':
        return _items.where((x) => x.status == 'completed').toList();
      case 'Cancelled':
        return _items.where((x) => x.status == 'cancelled').toList();
      default:
        return _items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return AppScaffold(
      topBar: const AppTopBar(title: 'Viewings', subtitle: 'Approve / reschedule / complete'),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TabChip(label: 'Pending', active: _tab == 'Pending', onTap: () => setState(() => _tab = 'Pending')),
                _TabChip(label: 'Approved', active: _tab == 'Approved', onTap: () => setState(() => _tab = 'Approved')),
                _TabChip(label: 'Rejected', active: _tab == 'Rejected', onTap: () => setState(() => _tab = 'Rejected')),
                _TabChip(label: 'Completed', active: _tab == 'Completed', onTap: () => setState(() => _tab = 'Completed')),
                _TabChip(label: 'Cancelled', active: _tab == 'Cancelled', onTap: () => setState(() => _tab = 'Cancelled')),
                _TabChip(label: 'All', active: _tab == 'All', onTap: () => setState(() => _tab = 'All')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    title: 'No viewings here',
                    message: 'New viewing requests will show up here.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final x = items[i];

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ViewingDetailScreen(
                              viewingId: x.id,
                              title: x.title,
                              status: x.status,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.35)),
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.15),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(child: Icon(Icons.event_available_rounded)),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            x.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        StatusBadge(domain: StatusDomain.viewing, status: x.status, compact: true),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(x.date, style: Theme.of(context).textTheme.bodySmall),
                                    const SizedBox(height: 4),
                                    Text('Mode: ${x.mode}', style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        selected: active,
        label: Text(label),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _Row {
  const _Row({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
    required this.mode,
  });

  final String id;
  final String title;
  final String date;
  final String status;
  final String mode;
}
EOF

# -----------------------------------------------------------------------------
# 3) lib/features/agent/viewings/viewing_detail_screen.dart
# -----------------------------------------------------------------------------
write_file "lib/features/agent/viewings/viewing_detail_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/dialog_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/status_badge.dart';

class ViewingDetailScreen extends StatelessWidget {
  const ViewingDetailScreen({super.key, required this.viewingId, required this.title, required this.status});

  final String viewingId;
  final String title;
  final String status;

  bool get canApproveReject => status == 'pending';
  bool get canReschedule => status == 'pending' || status == 'approved';
  bool get canComplete => status == 'approved';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Viewing Detail', subtitle: 'Actions depend on status'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(domain: StatusDomain.viewing, status: status),
          const SizedBox(height: AppSpacing.lg),

          const Text('Info (demo)\n• Mode: In-person\n• Requested: Jan 25 • 2:00 PM\n• Notes: Please call on arrival'),
          const SizedBox(height: AppSpacing.lg),

          if (canApproveReject) ...[
            PrimaryButton(label: 'Approve', onPressed: () => ToastService.show(context, 'Approved (demo)', success: true)),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Reject',
              onPressed: () async {
                final ok = await DialogService.confirm(
                  context,
                  title: 'Reject viewing?',
                  message: 'Reason required in real flow.',
                  confirmText: 'Reject',
                  danger: true,
                );
                if (ok && context.mounted) ToastService.show(context, 'Rejected (demo)', success: true);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          OutlinedButton.icon(
            onPressed: canReschedule ? () => ToastService.show(context, 'Reschedule proposal (demo)', success: true) : null,
            icon: const Icon(Icons.schedule_rounded),
            label: Text(canReschedule ? 'Reschedule' : 'Reschedule (disabled)'),
          ),
          const SizedBox(height: AppSpacing.md),

          OutlinedButton.icon(
            onPressed: canComplete ? () => ToastService.show(context, 'Marked completed (demo)', success: true) : null,
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: Text(canComplete ? 'Mark completed' : 'Mark completed (disabled)'),
          ),
          const SizedBox(height: AppSpacing.md),

          OutlinedButton.icon(
            onPressed: () async {
              final ok = await DialogService.confirm(
                context,
                title: 'Cancel viewing?',
                message: 'This will notify the tenant.',
                confirmText: 'Cancel',
                danger: true,
              );
              if (ok && context.mounted) ToastService.show(context, 'Cancelled (demo)', success: true);
            },
            icon: const Icon(Icons.cancel_rounded),
            label: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
EOF

# -----------------------------------------------------------------------------
# 4) lib/features/agent/maintenance/maintenance_screen.dart
# -----------------------------------------------------------------------------
write_file "lib/features/agent/maintenance/maintenance_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/widgets/card_widgets/maintenance_card.dart';
import 'maintenance_detail_screen.dart';

class AgentMaintenanceScreen extends StatelessWidget {
  const AgentMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _Row(id: 'am1', title: 'Leaking tap in kitchen', cat: 'Plumbing', priority: 'High', status: 'open'),
      _Row(id: 'am2', title: 'AC not cooling', cat: 'Electrical', priority: 'Medium', status: 'in_progress'),
      _Row(id: 'am3', title: 'Door handle loose', cat: 'General', priority: 'Low', status: 'resolved'),
    ];

    return AppScaffold(
      topBar: const AppTopBar(title: 'Maintenance', subtitle: 'Assign & update status'),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, i) {
          final x = items[i];
          return MaintenanceCard(
            title: x.title,
            categoryText: 'Category: ${x.cat}',
            priorityText: 'Priority: ${x.priority}',
            status: x.status,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MaintenanceDetailScreen(requestId: x.id, status: x.status))),
            primaryActionText: 'View',
            onPrimaryAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MaintenanceDetailScreen(requestId: x.id, status: x.status))),
          );
        },
      ),
    );
  }
}

class _Row {
  const _Row({required this.id, required this.title, required this.cat, required this.priority, required this.status});
  final String id;
  final String title;
  final String cat;
  final String priority;
  final String status;
}
EOF

# -----------------------------------------------------------------------------
# 5) lib/features/agent/maintenance/maintenance_detail_screen.dart
# -----------------------------------------------------------------------------
write_file "lib/features/agent/maintenance/maintenance_detail_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/bottom_sheet_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';

class MaintenanceDetailScreen extends StatelessWidget {
  const MaintenanceDetailScreen({super.key, required this.requestId, required this.status});

  final String requestId;
  final String status;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Request Detail', subtitle: 'Assign contractor & updates'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ticket #$requestId', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(domain: StatusDomain.maintenance, status: status),
          const SizedBox(height: AppSpacing.lg),

          PrimaryButton(
            label: 'Assign contractor',
            onPressed: () => ToastService.show(context, 'Assign contractor (demo)', success: true),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => _openStatus(context),
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Change status'),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('Timeline', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          const _Item('open', 'Request received'),
          const _Item('in_progress', 'Assigned to contractor'),
          const _Item('resolved', 'Issue fixed (demo)'),
        ],
      ),
    );
  }

  void _openStatus(BuildContext context) {
    BottomSheetService.show(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set status', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.md),
          _Btn('open', () => _set(context, 'open')),
          _Btn('in_progress', () => _set(context, 'in_progress')),
          _Btn('on_hold', () => _set(context, 'on_hold')),
          _Btn('resolved', () => _set(context, 'resolved')),
          _Btn('cancelled', () => _set(context, 'cancelled')),
        ],
      ),
    );
  }

  void _set(BuildContext context, String s) {
    Navigator.of(context).pop();
    ToastService.show(context, 'Status → $s (demo)', success: true);
  }
}

class _Btn extends StatelessWidget {
  const _Btn(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SizedBox(width: double.infinity, child: OutlinedButton(onPressed: onTap, child: Text(label))),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.title, this.body);
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.fiber_manual_record_rounded, size: 14),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
EOF

# -----------------------------------------------------------------------------
# 6) lib/features/agent/payments_payouts/wallet_summary_screen.dart
# -----------------------------------------------------------------------------
write_file "lib/features/agent/payments_payouts/wallet_summary_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import 'payout_accounts_screen.dart';
import 'request_payout_screen.dart';
import 'payout_status_screen.dart';
import 'payment_history_screen.dart';

class WalletSummaryScreen extends StatelessWidget {
  const WalletSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Wallet', subtitle: 'Balance + payouts'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available Balance', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                Text('NGN 320,500', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: AppSpacing.sm),
                Text('Escrow (display-only for now)', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                Text('NGN 80,000', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          PrimaryButton(
            label: 'Request payout',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RequestPayoutScreen())),
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PayoutAccountsScreen())),
                  icon: const Icon(Icons.account_balance_rounded),
                  label: const Text('Payout accounts'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PayoutStatusScreen())),
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text('Payout status'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaymentHistoryScreen())),
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text('Payment history'),
          ),
          const SizedBox(height: AppSpacing.md),

          OutlinedButton.icon(
            onPressed: () => ToastService.show(context, 'Inflow/outflow ledger (Phase 2)', success: true),
            icon: const Icon(Icons.list_alt_rounded),
            label: const Text('Wallet transactions'),
          ),
        ],
      ),
    );
  }
}
EOF

# -----------------------------------------------------------------------------
# 7) lib/features/agent/payments_payouts/payment_history_screen.dart
# -----------------------------------------------------------------------------
write_file "lib/features/agent/payments_payouts/payment_history_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/widgets/card_widgets/payment_card.dart';
import 'payment_detail_screen.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _Row(id: 'ph1', purpose: 'Rent Payment', amount: 'NGN 1,200,000', date: 'Jan 12, 2026', status: 'successful'),
      _Row(id: 'ph2', purpose: 'Deposit', amount: 'NGN 250,000', date: 'Jan 11, 2026', status: 'pending'),
      _Row(id: 'ph3', purpose: 'Rent Payment', amount: 'NGN 1,200,000', date: 'Dec 10, 2025', status: 'failed'),
    ];

    return AppScaffold(
      topBar: const AppTopBar(title: 'Payment History', subtitle: 'Successful / pending / failed'),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, i) {
          final x = items[i];
          return PaymentCard(
            purposeText: x.purpose,
            amountText: x.amount,
            dateText: x.date,
            status: x.status,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentDetailScreen(paymentId: x.id, status: x.status))),
            primaryActionText: 'View',
            onPrimaryAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentDetailScreen(paymentId: x.id, status: x.status))),
          );
        },
      ),
    );
  }
}

class _Row {
  const _Row({required this.id, required this.purpose, required this.amount, required this.date, required this.status});
  final String id;
  final String purpose;
  final String amount;
  final String date;
  final String status;
}
EOF

# -----------------------------------------------------------------------------
# 8) lib/features/agent/payments_payouts/payment_detail_screen.dart
# -----------------------------------------------------------------------------
write_file "lib/features/agent/payments_payouts/payment_detail_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/widgets/status_badge.dart';

class PaymentDetailScreen extends StatelessWidget {
  const PaymentDetailScreen({super.key, required this.paymentId, required this.status});

  final String paymentId;
  final String status;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Payment Detail', subtitle: 'Receipt & reference'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment #$paymentId', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(domain: StatusDomain.payment, status: status),
          const SizedBox(height: AppSpacing.lg),
          const Text('MVP breakdown:\n• Purpose: Rent\n• Amount: NGN 1,200,000\n• Ref: PAY-10113-2481'),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_rounded), label: const Text('Download receipt (demo)')),
        ],
      ),
    );
  }
}
EOF

# -----------------------------------------------------------------------------
# 9) lib/features/agent/payments_payouts/request_payout_screen.dart
# -----------------------------------------------------------------------------
write_file "lib/features/agent/payments_payouts/request_payout_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/form_field.dart';
import '../../../shared/widgets/primary_button.dart';

class RequestPayoutScreen extends StatefulWidget {
  const RequestPayoutScreen({super.key});

  @override
  State<RequestPayoutScreen> createState() => _RequestPayoutScreenState();
}

class _RequestPayoutScreenState extends State<RequestPayoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController(text: '50000');

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ToastService.show(context, 'Payout requested (demo)', success: true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Request Payout', subtitle: 'Withdraw to bank'),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppFormField(
              controller: _amount,
              label: 'Amount (NGN)',
              hint: 'e.g. 50000',
              validator: (v) => Validators.requiredField(v),
              prefixIcon: Icons.payments_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(label: 'Confirm request', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
EOF

# -----------------------------------------------------------------------------
# 10) lib/features/agent/payments_payouts/payout_accounts_screen.dart
# -----------------------------------------------------------------------------
write_file "lib/features/agent/payments_payouts/payout_accounts_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';

class PayoutAccountsScreen extends StatelessWidget {
  const PayoutAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Payout Accounts', subtitle: 'Add your bank account'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Accounts (demo)\n• Access Bank • 1234567890'),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Add bank account',
            onPressed: () => ToastService.show(context, 'Add account flow (demo)', success: true),
          ),
        ],
      ),
    );
  }
}
EOF

# -----------------------------------------------------------------------------
# 11) lib/features/agent/payments_payouts/payout_detail_screen.dart
# -----------------------------------------------------------------------------
write_file "lib/features/agent/payments_payouts/payout_detail_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/widgets/status_badge.dart';

class PayoutDetailScreen extends StatelessWidget {
  const PayoutDetailScreen({super.key, required this.payoutId, required this.status});

  final String payoutId;
  final String status;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Payout Detail', subtitle: 'Status & reference'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payout #$payoutId', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(domain: StatusDomain.payout, status: status),
          const SizedBox(height: AppSpacing.lg),
          const Text('MVP breakdown:\n• Amount: NGN 50,000\n• Bank: Access Bank\n• Ref: PO-10113-2481'),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_rounded), label: const Text('Download receipt (demo)')),
        ],
      ),
    );
  }
}
EOF

# -----------------------------------------------------------------------------
# 12) lib/features/agent/payments_payouts/payout_status_screen.dart
# -----------------------------------------------------------------------------
write_file "lib/features/agent/payments_payouts/payout_status_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/widgets/card_widgets/payout_card.dart';
import 'payout_detail_screen.dart';

class PayoutStatusScreen extends StatelessWidget {
  const PayoutStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _Row(id: 'po1', amount: 'NGN 50,000', date: 'Jan 13, 2026', status: 'processing'),
      _Row(id: 'po2', amount: 'NGN 120,000', date: 'Jan 05, 2026', status: 'paid'),
      _Row(id: 'po3', amount: 'NGN 30,000', date: 'Dec 22, 2025', status: 'failed'),
    ];

    return AppScaffold(
      topBar: const AppTopBar(title: 'Payouts', subtitle: 'Pending → processing → paid'),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, i) {
          final x = items[i];
          return PayoutCard(
            amountText: x.amount,
            dateText: x.date,
            status: x.status,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PayoutDetailScreen(payoutId: x.id, status: x.status))),
            primaryActionText: 'View',
            onPrimaryAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PayoutDetailScreen(payoutId: x.id, status: x.status))),
          );
        },
      ),
    );
  }
}

class _Row {
  const _Row({required this.id, required this.amount, required this.date, required this.status});
  final String id;
  final String amount;
  final String date;
  final String status;
}
EOF

# -----------------------------------------------------------------------------
# 13) lib/features/agent/verification/verification_dashboard_screen.dart
# -----------------------------------------------------------------------------
write_file "lib/features/agent/verification/verification_dashboard_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/widgets/primary_button.dart';
import 'property_verification_detail_screen.dart';
import 'document_review_list_screen.dart';

class VerificationDashboardScreen extends StatelessWidget {
  const VerificationDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Verification', subtitle: 'Properties & documents'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.md),
          const Text('MVP: only UI. Wire permissions + endpoints later.'),
          const SizedBox(height: AppSpacing.lg),

          PrimaryButton(
            label: 'Property verification',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PropertyVerificationDetailScreen())),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DocumentReviewListScreen())),
            icon: const Icon(Icons.fact_check_rounded),
            label: const Text('Document reviews'),
          ),
        ],
      ),
    );
  }
}
EOF

# -----------------------------------------------------------------------------
# 14) lib/features/agent/verification/document_review_list_screen.dart
# -----------------------------------------------------------------------------
write_file "lib/features/agent/verification/document_review_list_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/widgets/status_badge.dart';
import 'document_detail_screen.dart';

class DocumentReviewListScreen extends StatefulWidget {
  const DocumentReviewListScreen({super.key});

  @override
  State<DocumentReviewListScreen> createState() => _DocumentReviewListScreenState();
}

class _DocumentReviewListScreenState extends State<DocumentReviewListScreen> {
  String _tab = 'Pending';

  final _items = const [
    _Row(id: 'dr1', user: 'John Doe', type: 'ID Card', status: 'pending'),
    _Row(id: 'dr2', user: 'Ada K.', type: 'Utility Bill', status: 'verified'),
    _Row(id: 'dr3', user: 'Kemi A.', type: 'ID Card', status: 'rejected'),
  ];

  List<_Row> get _filtered {
    if (_tab == 'Pending') return _items.where((x) => x.status == 'pending').toList();
    if (_tab == 'Verified') return _items.where((x) => x.status == 'verified').toList();
    if (_tab == 'Rejected') return _items.where((x) => x.status == 'rejected').toList();
    return _items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return AppScaffold(
      topBar: const AppTopBar(title: 'Document Reviews', subtitle: 'Pending / verified / rejected'),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(label: 'Pending', active: _tab == 'Pending', onTap: () => setState(() => _tab = 'Pending')),
                _Chip(label: 'Verified', active: _tab == 'Verified', onTap: () => setState(() => _tab = 'Verified')),
                _Chip(label: 'Rejected', active: _tab == 'Rejected', onTap: () => setState(() => _tab = 'Rejected')),
                _Chip(label: 'All', active: _tab == 'All', onTap: () => setState(() => _tab = 'All')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) {
                final x = items[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.description_rounded)),
                  title: Text(
                    '${x.user} • ${x.type}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  trailing: StatusBadge(domain: StatusDomain.verified, status: x.status, compact: true),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DocumentDetailScreen(docId: x.id, userName: x.user, docType: x.type, status: x.status),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(selected: active, label: Text(label), onSelected: (_) => onTap()),
    );
  }
}

class _Row {
  const _Row({required this.id, required this.user, required this.type, required this.status});
  final String id;
  final String user;
  final String type;
  final String status;
}
EOF

# -----------------------------------------------------------------------------
# 15) lib/features/agent/verification/document_detail_screen.dart
# -----------------------------------------------------------------------------
write_file "lib/features/agent/verification/document_detail_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/dialog_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';

class DocumentDetailScreen extends StatelessWidget {
  const DocumentDetailScreen({super.key, required this.docId, required this.userName, required this.docType, required this.status});

  final String docId;
  final String userName;
  final String docType;
  final String status;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Document Detail', subtitle: 'Preview + approve/reject'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$userName • $docType', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          StatusBadge(domain: StatusDomain.verified, status: status),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: const Center(child: Text('Preview (image/pdf)')),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Approve',
            onPressed: () => ToastService.show(context, 'Approved (demo)', success: true),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () async {
              final ok = await DialogService.confirm(
                context,
                title: 'Reject document?',
                message: 'Reason required in real flow.',
                confirmText: 'Reject',
                danger: true,
              );
              if (ok && context.mounted) ToastService.show(context, 'Rejected (demo)', success: true);
            },
            icon: const Icon(Icons.block_rounded),
            label: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
EOF

# -----------------------------------------------------------------------------
# 16) lib/features/agent/verification/property_verification_detail_screen.dart
# -----------------------------------------------------------------------------
write_file "lib/features/agent/verification/property_verification_detail_screen.dart" <<'EOF'
import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';

class PropertyVerificationDetailScreen extends StatelessWidget {
  const PropertyVerificationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const status = 'pending';

    return AppScaffold(
      topBar: const AppTopBar(title: 'Property Verification', subtitle: 'Status + notes'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Property: Modern 2 Bedroom Apartment', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.sm),
          const StatusBadge(domain: StatusDomain.verified, status: status),
          const SizedBox(height: AppSpacing.lg),
          const Text('Notes: Awaiting on-site verification (demo).'),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Mark verified',
            onPressed: () => ToastService.show(context, 'Verified (demo)', success: true),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => ToastService.show(context, 'Reject with reason (demo)', success: true),
            icon: const Icon(Icons.block_rounded),
            label: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
EOF

echo ""
echo "✅ Done."
echo "Next step: run Flutter analyze/build and paste any errors:"
echo "  flutter analyze"
echo "  flutter run"
