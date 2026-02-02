// lib/features/tenant/applications/my_applications_screen.dart
// ignore_for_file: unnecessary_underscores

import "package:flutter/material.dart";

import "../../../core/ui/scaffold/app_scaffold.dart";
import "../../../core/ui/scaffold/app_top_bar.dart";
import "../../../core/ui/nav/tenant_nav.dart"; // Assuming existance based on Explore

import "../../../core/theme/app_colors.dart";
import "../../../core/theme/app_radii.dart";
import "../../../core/theme/app_shadows.dart";
import "../../../core/theme/app_sizes.dart";
import "../../../core/theme/app_spacing.dart";

import "../../../core/network/api_client.dart";
import "../../../core/network/applications_api.dart";

import "../../../shared/models/application_model.dart";

import "application_detail_screen.dart";

enum ApplicationsTab { all, pending, approved, rejected, withdrawn }

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({
    super.key,
    this.initialTab = ApplicationsTab.all,
  });

  final ApplicationsTab initialTab;

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  // ✅ Single source of truth
  late final ApplicationsApi _api = ApplicationsApi(ApiClient());

  late ApplicationsTab _currentTab = widget.initialTab;
  
  // Maps Enum to UI Chip index
  int get _activeChipIndex => ApplicationsTab.values.indexOf(_currentTab);
  final List<String> _chips = const ['All', 'Pending', 'Approved', 'Rejected', 'Withdrawn'];

  bool _loading = true;
  String? _error;
  List<ApplicationModel> _items = const [];

  // ---------- helpers (consistent with Explore) ----------
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _setTabFromChip(int index) {
    if (index >= 0 && index < ApplicationsTab.values.length) {
      setState(() {
        _currentTab = ApplicationsTab.values[index];
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
      // Note: We don't clear items immediately to avoid flicker if just switching tabs locally,
      // but if fetching fresh from API, clearing is safer for consistency.
      _items = []; 
    });

    try {
      // Fetching "All" and filtering locally for now, similar to original logic.
      // If API supports filtering, pass _currentTab params here.
      final rows = await _api.listMyApplications(limit: 60, offset: 0);
      
      if (!mounted) return;
      setState(() {
        _items = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<ApplicationModel> get _sorted {
    final all = [..._items];
    all.sort((a, b) {
      final aT = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bT = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bT.compareTo(aT);
    });
    return all;
  }

  List<ApplicationModel> get _filtered {
    final all = _sorted;
    switch (_currentTab) {
      case ApplicationsTab.all:
        return all;
      case ApplicationsTab.pending:
        return all.where((a) => a.status == ApplicationStatus.pending).toList();
      case ApplicationsTab.approved:
        return all.where((a) => a.status == ApplicationStatus.approved).toList();
      case ApplicationsTab.rejected:
        return all.where((a) => a.status == ApplicationStatus.rejected).toList();
      case ApplicationsTab.withdrawn:
        return all.where((a) => a.status == ApplicationStatus.withdrawn).toList();
    }
  }

  String _dateLabel(BuildContext context, ApplicationModel a) {
    final dt = a.createdAt;
    if (dt == null) return "Unknown date";
    final loc = MaterialLocalizations.of(context);
    return loc.formatShortMonthDay(dt);
  }

  Future<void> _withdraw(ApplicationModel a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Withdraw application?"),
        content: const Text("You can’t undo this action."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Withdraw"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final updated = await _api.withdraw(a.id);
      if (!mounted) return;

      setState(() {
        // Update item in local list
        final index = _items.indexWhere((x) => x.id == a.id);
        if (index != -1) {
          final newItems = [..._items];
          newItems[index] = updated;
          _items = newItems;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Application withdrawn.")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Withdraw failed: $e")),
      );
    }
  }

  void _openDetails(ApplicationModel a) {
    // Keeping navigation logic consistent
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ApplicationDetailScreen(
          application: a,
          onWithdraw: a.status == ApplicationStatus.pending ? () => _withdraw(a) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = _filtered;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        appBar: AppTopBar(
          title: "My Applications",
          subtitle: "${displayItems.length} ${_chips[_activeChipIndex]} items",
          leadingIcon: Icons.arrow_back_rounded,
          onLeadingTap: () => Navigator.of(context).maybePop(),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.screenH),
              child: InkWell(
                onTap: _refresh,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: Container(
                  height: AppSizes.iconButtonBox,
                  width: AppSizes.iconButtonBox,
                  decoration: BoxDecoration(
                    color: AppColors.surface(context)
                        .withValues(alpha: _alphaSurfaceStrong),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.overlay(context, _alphaBorderSoft),
                    ),
                    boxShadow: AppShadows.soft(
                      context,
                      blur: AppSpacing.xxxl,
                      y: AppSpacing.lg,
                      alpha: _alphaShadowSoft,
                    ),
                  ),
                  child: Icon(
                    Icons.refresh_rounded,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ),
            ),
          ],
        ),
        scroll: true,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.sm,
          AppSpacing.screenH,
          AppSizes.screenBottomPad,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            
            // Replaced custom Tab Row with Explore-style ChipRow
            _ChipRow(
              chips: _chips,
              activeIndex: _activeChipIndex,
              onTap: _setTabFromChip,
            ),
            
            const SizedBox(height: AppSpacing.lg),

            if (_loading && displayItems.isEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: CircularProgressIndicator(
                    color: AppColors.brandGreenDeep,
                  ),
                ),
              ),
            ] else if (_error != null && displayItems.isEmpty) ...[
              _ErrorBox(message: _error!, onRetry: _refresh),
            ] else if (displayItems.isEmpty) ...[
              _InfoBox(
                title: 'No applications',
                message: 'No applications found in this category.',
                onAction: () => _setTabFromChip(0), // Go to All
                actionText: 'View All',
              ),
            ] else ...[
               ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: displayItems.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) {
                  final item = displayItems[i];
                  final date = _dateLabel(context, item);

                  // Formatting details for the "Meta" line
                  final meta = "Prop: ${item.propertyId}";

                  return _ApplicationRowCard(
                    title: "Application",
                    subtitle: "Listing: ${item.listingId}",
                    meta: meta,
                    date: date,
                    status: item.status,
                    onTap: () => _openDetails(item),
                    onWithdraw: item.status == ApplicationStatus.pending
                        ? () => _withdraw(item)
                        : null,
                  );
                },
              ),
            ],
            
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

// ---------------- UI widgets (Consolidated from Explore Screen) ----------------

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.chips,
    required this.activeIndex,
    required this.onTap,
  });

  final List<String> chips;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

    return SizedBox(
      height: AppSpacing.s44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final active = i == activeIndex;
          return InkWell(
            onTap: () => onTap(i),
            borderRadius: BorderRadius.circular(AppRadii.chip),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                gradient: active ? AppColors.brandGradient : null,
                color: active
                    ? null
                    : AppColors.surface(context).withValues(alpha: alphaSurface),
                borderRadius: BorderRadius.circular(AppRadii.chip),
                border: Border.all(color: AppColors.overlay(context, alphaBorder)),
              ),
              child: Center(
                child: Text(
                  chips[i],
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: active
                        ? AppColors.white
                        : AppColors.textPrimary(context),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ApplicationRowCard extends StatelessWidget {
  const _ApplicationRowCard({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.date,
    required this.status,
    required this.onTap,
    required this.onWithdraw,
  });

  final String title;
  final String subtitle;
  final String meta;
  final String date;
  final ApplicationStatus status;
  final VoidCallback onTap;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: alphaSurface),
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.overlay(context, alphaBorder)),
          boxShadow: AppShadows.lift(
            context,
            blur: AppSpacing.xxxl,
            y: AppSpacing.xl,
            alpha: AppSpacing.xs / AppSpacing.xxxl,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail / Icon
            Container(
              height: AppSizes.listThumbSize,
              width: AppSizes.listThumbSize,
              decoration: BoxDecoration(
                color: AppColors.brandBlueSoft.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: AppColors.overlay(context, alphaBorder)),
              ),
              child: const Icon(Icons.assignment_rounded, color: AppColors.brandBlueSoft),
            ),
            const SizedBox(width: AppSpacing.md),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary(context),
                        ),
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        meta,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted(context),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        "•  $date",
                         style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted(context),
                              fontWeight: FontWeight.w700,
                            ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            
            // Status & Action
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: status),
                
                if (onWithdraw != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  InkWell(
                    onTap: onWithdraw,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
                      child: Text(
                        "Withdraw",
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.danger
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                   const SizedBox(height: AppSpacing.sm),
                   Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted(context),
                    size: 20,
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case ApplicationStatus.pending:
        color = AppColors.brandBlueSoft;
        label = "Pending";
        break;
      case ApplicationStatus.approved:
        color = AppColors.brandGreenDeep;
        label = "Approved";
        break;
      case ApplicationStatus.rejected:
        color = AppColors.danger; // Using Danger for consistency
        label = "Rejected";
        break;
      case ApplicationStatus.withdrawn:
        color = AppColors.textMuted(context);
        label = "Withdrawn";
        break;
    }

    final alphaBg = AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: alphaBg),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withValues(alpha: alphaBg + 0.1)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
              fontSize: 10, // Slightly smaller for badge
            ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Could not load applications',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.title,
    required this.message,
    required this.onAction,
    required this.actionText,
  });

  final String title;
  final String message;
  final VoidCallback onAction;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.overlay(context, 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(message, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(onPressed: onAction, child: Text(actionText)),
        ],
      ),
    );
  }
}