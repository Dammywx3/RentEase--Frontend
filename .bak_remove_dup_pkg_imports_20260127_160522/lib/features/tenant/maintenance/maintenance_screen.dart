import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/card_widgets/maintenance_card.dart';

import 'maintenance_detail_screen.dart';
import 'create_request_screen.dart';

import '../../../core/theme/app_colors.dart';

import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  // 0=open, 1=in_progress, 2=completed, 3=rejected
  int _tab = 0;

  // Demo data (wire later)
  final List<_Req> _all = const [
    _Req(
      id: 'm1',
      category: 'Plumbing',
      title: 'Leaking kitchen pipe',
      status: 'in_progress',
      dateLabel: 'Jan 24',
      priority: 'High',
      address: '123 Maple St, Apt 2B',
    ),
    _Req(
      id: 'm2',
      category: 'AC',
      title: 'Living room AC not cooling',
      status: 'open',
      dateLabel: 'Jan 21',
      priority: 'Medium',
      address: '123 Maple St, Apt 2B',
    ),
    _Req(
      id: 'm3',
      category: 'Security',
      title: 'Front door lock broken',
      status: 'resolved',
      dateLabel: 'Dec 29',
      priority: 'Normal',
      address: '123 Maple St, Apt 2B',
    ),
    _Req(
      id: 'm4',
      category: 'Electrical',
      title: 'Sockets sparking in kitchen',
      status: 'rejected',
      dateLabel: 'Dec 14',
      priority: 'High',
      address: '123 Maple St, Apt 2B',
    ),
  ];

  List<_Req> get _filtered {
    switch (_tab) {
      case 0:
        return _all.where((x) => x.status == 'open').toList();
      case 1:
        return _all.where((x) => x.status == 'in_progress').toList();
      case 2:
        // completed/resolved
        return _all.where((x) => x.status == 'resolved').toList();
      case 3:
        return _all.where((x) => x.status == 'rejected').toList();
      default:
        return _all;
    }
  }

  String _tabLabel(int i) {
    if (i == 0) return 'Open';
    if (i == 1) return 'In Progress';
    if (i == 2) return 'Completed';
    return 'Rejected';
  }

  void _openDetails(_Req r) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MaintenanceDetailScreen(
          requestId: r.id,
          status: r.status,
          // optional extra info (safe defaults in screen)
          title: r.title,
          category: r.category,
          dateLabel: r.dateLabel,
          address: r.address,
          priority: r.priority,
        ),
      ),
    );
  }

  void _openNewRequest() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateMaintenanceRequestScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Maintenance',
        subtitle: 'Report issues in your home and track progress',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryCard(
            tenancyText: '123 Maple St, Apt 2B',
            onRequest: _openNewRequest,
            onEmergency: () => ToastService.show(
              context,
              'Emergency contact (wire later)',
              success: true,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          _SegmentTabs(
            value: _tab,
            items: List.generate(4, (i) => _tabLabel(i)),
            onChanged: (v) => setState(() => _tab = v),
          ),
          const SizedBox(height: AppSpacing.md),

          if (list.isEmpty)
            _EmptyState(
              title: 'No requests here',
              subtitle: _tab == 0
                  ? 'You have no open maintenance requests.'
                  : 'Nothing to show in this tab.',
              ctaText: 'Request Maintenance',
              onCta: _openNewRequest,
            )
          else
            ...list.map(
              (x) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: InkWell(
                  onTap: () => _openDetails(x),
                  borderRadius: BorderRadius.circular(18),
                  child: MaintenanceCard(
                    title: x.title,
                    categoryText: x.category,
                    status: x.status,
                    priorityText: 'Priority: ${x.priority}',
                    onTap: () => _openDetails(x),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/* ------------------ Small UI pieces ------------------ */

class _Req {
  const _Req({
    required this.id,
    required this.category,
    required this.title,
    required this.status,
    required this.dateLabel,
    required this.priority,
    required this.address,
  });

  final String id;
  final String category;
  final String title;
  final String status; // open / in_progress / resolved / rejected
  final String dateLabel;
  final String priority; // Low/Normal/Medium/High
  final String address;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.tenancyText,
    required this.onRequest,
    required this.onEmergency,
  });

  final String tenancyText;
  final VoidCallback onRequest;
  final VoidCallback onEmergency;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Maintenance',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Report issues in your home and track progress',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.overlay(context, 0.60),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.surface(context).withValues(alpha: 0.55),
              border: Border.all(color: AppColors.overlay(context, 0.06)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.home_rounded,
                  color: AppColors.overlay(context, 0.60),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    tenancyText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Request Maintenance',
                  onPressed: onRequest,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SecondaryButton(
                  label: 'Emergency Contact',
                  onPressed: onEmergency,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final int value;
  final List<String> items;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surface(context).withValues(alpha: 0.60),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == value;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: active
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.14)
                      : Colors.transparent,
                  border: Border.all(
                    color: active
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.22)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  items[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.onCta,
  });

  final String title;
  final String subtitle;
  final String ctaText;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.surface(context).withValues(alpha: 0.55),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.build_rounded,
            size: 34,
            color: AppColors.overlay(context, 0.60),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.overlay(context, 0.60),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(label: ctaText, onPressed: onCta),
        ],
      ),
    );
  }
}
