// lib/features/tenant/maintenance/maintenance_screen.dart
// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';

import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import '../../../shared/services/toast_service.dart';
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
  final List<MaintenanceRequestVM> requests;
  final List<String> categories;
  final List<String> priorities;
  final List<String> visitWindows;

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  // 0=open, 1=in_progress, 2=resolved, 3=cancelled
  int _tab = 0;

  // ---------- Explore-style alpha helpers ----------
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaSurfaceSoft =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

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

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: AppTopBar(
          title: 'Maintenance',
          leadingIcon: Icons.arrow_back_rounded,
          onLeadingTap: () => Navigator.of(context).maybePop(),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH, // ✅ Standard horizontal spacing
            AppSpacing.sm,
            AppSpacing.screenH, // ✅ Standard horizontal spacing
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
                          // Note: MaintenanceCard likely handles its own tap,
                          // but wrapping it ensures consistent borderRadius touch feedback
                          return InkWell(
                            onTap: () => _openDetails(x),
                            borderRadius: BorderRadius.circular(AppRadii.card),
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

class _FrostCard extends StatelessWidget {
  const _FrostCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Standard Explore logic
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
    final alphaShadow = AppSpacing.xs / AppSpacing.xxxl;

    return Material(
      color: AppColors.surface(context).withValues(alpha: alphaSurface),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.overlay(context, alphaBorder)),
          boxShadow: AppShadows.lift(
            context,
            blur: AppSpacing.xxxl,
            y: AppSpacing.xl,
            alpha: alphaShadow,
          ),
        ),
        child: child,
      ),
    );
  }
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
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
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
                  color: AppColors.overlay(context, 0.04),
                  border: Border.all(color: AppColors.overlay(context, 0.06)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.home_rounded,
                        color: AppColors.textMuted(context)),
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
                  child: _PrimaryButton(
                    text: 'Request',
                    onPressed: onRequest,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _SecondaryButton(
                    text: 'Emergency',
                    onPressed: onEmergency,
                  ),
                ),
              ],
            ),
          ],
        ),
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
    // Glass container for tabs
    return _FrostCard(
      child: Container(
        height: AppSizes.pillButtonHeight + AppSpacing.s2,
        padding: const EdgeInsets.all(4),
        child: Row(
          children: List.generate(items.length, (i) {
            final active = i == value;
            return Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    color: active
                        ? AppColors.brandGreenDeep.withValues(alpha: 0.15)
                        : Colors.transparent,
                    border: Border.all(
                      color: active
                          ? AppColors.brandGreenDeep.withValues(alpha: 0.2)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    items[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: active
                              ? AppColors.brandGreenDeep
                              : AppColors.textMuted(context),
                        ),
                  ),
                ),
              ),
            );
          }),
        ),
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
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Icon(
              Icons.build_rounded,
              size: AppSpacing.s34,
              color: AppColors.textMuted(context).withValues(alpha: 0.5),
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
            _PrimaryButton(text: ctaText, onPressed: onCta),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandGreenDeep.withValues(alpha: 0.95),
          foregroundColor: AppColors.textLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.overlay(context, 0.15)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}