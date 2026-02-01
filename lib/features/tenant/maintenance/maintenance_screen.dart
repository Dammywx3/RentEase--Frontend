// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';

import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/card_widgets/maintenance_card.dart';

import 'maintenance_detail_screen.dart';
import 'create_request_screen.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({
    super.key,
    this.tenancyLabel,
    this.requests = const [],
    this.categories = const [],
    this.priorities = const [],
    this.visitWindows = const [],
  });

  final String? tenancyLabel;

  /// ✅ feed from backend later
  final List<MaintenanceRequestVM> requests;

  /// ✅ feed from backend/config later
  final List<String> categories;
  final List<String> priorities;
  final List<String> visitWindows;

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  // 0=open, 1=in_progress, 2=resolved, 3=cancelled
  int _tab = 0;

  List<MaintenanceRequestVM> get _filtered {
    final all = widget.requests;
    switch (_tab) {
      case 0:
        return all.where((x) => x.status == 'open').toList();
      case 1:
        return all.where((x) => x.status == 'in_progress').toList();
      case 2:
        return all.where((x) => x.status == 'resolved').toList();
      case 3:
        return all.where((x) => x.status == 'cancelled').toList();
      default:
        return all;
    }
  }

  String _tabLabel(int i) {
    if (i == 0) return 'Open';
    if (i == 1) return 'In Progress';
    if (i == 2) return 'Resolved';
    return 'Cancelled';
  }

  void _openDetails(MaintenanceRequestVM r) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MaintenanceDetailScreen(
          requestId: r.id,
          status: r.status,
          title: r.title,
          category: r.category,
          dateLabel: r.dateLabel,
          address: r.address,
          priority: r.priority,
          description: r.description,
          permissionToEnter: r.permissionToEnter,
        ),
      ),
    );
  }

  void _openNewRequest() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateMaintenanceRequestScreen(
          categories: widget.categories,
          priorities: widget.priorities,
          visitWindows: widget.visitWindows,
          addressLabel: widget.tenancyLabel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filtered;

    return Stack(
      children: [
        // ✅ Fix: gradient behind the entire screen (safe-area + top bar)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.pageBgGradient(context),
            ),
          ),
        ),
        AppScaffold(
          backgroundColor: Colors.transparent,
          safeAreaTop: true,
          safeAreaBottom: false,
          topBar: AppTopBar(
            title: 'Maintenance',
            subtitle:
                null, // ✅ keep top bar clean (screen name only if you want)
            leadingIcon: Icons.arrow_back_rounded,
            onLeadingTap: () => Navigator.of(context).maybePop(),
            actions: const [],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.sm,
              AppSpacing.screenH,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SummaryCard(
                  tenancyText: (widget.tenancyLabel ?? '').trim(),
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

                Expanded(
                  child: list.isEmpty
                      ? _EmptyState(
                          title: 'No requests',
                          subtitle: 'Nothing to show in this tab.',
                          ctaText: 'Request Maintenance',
                          onCta: _openNewRequest,
                        )
                      : ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, i) {
                            final x = list[i];
                            return InkWell(
                              onTap: () => _openDetails(x),
                              borderRadius: BorderRadius.circular(
                                AppRadii.card,
                              ),
                              child: MaintenanceCard(
                                title: x.title,
                                categoryText: x.category ?? '',
                                status: x.status,
                                priorityText: x.priority == null
                                    ? ''
                                    : 'Priority: ${x.priority}',
                                onTap: () => _openDetails(x),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/* ------------------ VM ------------------ */

class MaintenanceRequestVM {
  const MaintenanceRequestVM({
    required this.id,
    required this.title,
    required this.status,
    this.category,
    this.dateLabel,
    this.address,
    this.priority,
    this.description,
    this.permissionToEnter,
  });

  final String id;
  final String title;
  final String status;

  final String? category;
  final String? dateLabel;
  final String? address;
  final String? priority;
  final String? description;
  final bool? permissionToEnter;
}

/* ------------------ UI ------------------ */

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.tenancyText,
    required this.onRequest,
    required this.onEmergency,
  });

  final String tenancyText;
  final VoidCallback onRequest;
  final VoidCallback onEmergency;

  double get _surfaceA => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _borderA => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        color: AppColors.surface(context).withValues(alpha: _surfaceA),
        border: Border.all(color: AppColors.overlay(context, _borderA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Maintenance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (tenancyText.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.button),
                color: AppColors.surface(context).withValues(alpha: _surfaceA),
                border: Border.all(color: AppColors.overlay(context, _borderA)),
              ),
              child: Row(
                children: [
                  Icon(Icons.home_rounded, color: AppColors.textMuted(context)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      tenancyText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary(context),
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

  double get _surfaceA => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _borderA => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.pillButtonHeight,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        color: AppColors.surface(context).withValues(alpha: _surfaceA),
        border: Border.all(color: AppColors.overlay(context, _borderA)),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == value;
          final base = Theme.of(context).colorScheme;

          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              borderRadius: BorderRadius.circular(AppRadii.sm),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  color: active
                      ? base.primary.withValues(alpha: 0.18)
                      : Colors.transparent,
                  border: Border.all(
                    color: active
                        ? base.primary.withValues(alpha: 0.22)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  items[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
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

  double get _surfaceA => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _borderA => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        color: AppColors.surface(context).withValues(alpha: _surfaceA),
        border: Border.all(color: AppColors.overlay(context, _borderA)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.build_rounded,
            size: AppSpacing.s34,
            color: AppColors.textMuted(context),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(label: ctaText, onPressed: onCta),
        ],
      ),
    );
  }
}
