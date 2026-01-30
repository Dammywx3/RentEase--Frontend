// lib/features/tenant/saved/saved_searches_screen.dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

class SavedSearchesScreen extends StatefulWidget {
  const SavedSearchesScreen({
    super.key,
    this.onExploreHomes,
  });

  final VoidCallback? onExploreHomes;

  @override
  State<SavedSearchesScreen> createState() => _SavedSearchesScreenState();
}

class _SavedSearchesScreenState extends State<SavedSearchesScreen> {
  // Demo list (wire later). Set to [] if you want empty by default.
  final List<SavedSearchVM> _searches = [
    const SavedSearchVM(
      id: 's1',
      title: 'For Rent in Lekki',
      summary: '₦800k–₦1.2m • 2 beds • Verified agents',
      updatesLine: '3 new listings since yesterday',
      alertsEnabled: true,
    ),
    const SavedSearchVM(
      id: 's2',
      title: 'Land in Ikoyi',
      summary: '₦150m–₦350m • 500–1200sqm • Verified only',
      updatesLine: '1 new listing since yesterday',
      alertsEnabled: false,
    ),
  ];

  void _openSearchResults(SavedSearchVM s) {
    // TODO: open SearchScreen with filters applied
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open search results: ${s.title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: Colors.transparent,
      safeAreaTop: true,
      safeAreaBottom: false,
      topBar: AppTopBar(
        title: 'Saved Searches',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.screenH),
            child: _CircleIconButton(
              icon: Icons.edit_rounded,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Manage saved searches (wire later)')),
                );
              },
            ),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenV,
            AppSpacing.sm,
            AppSpacing.screenV,
            AppSizes.screenBottomPad,
          ),
          children: [
            if (_searches.isEmpty)
              _EmptyState(
                icon: Icons.saved_search_rounded,
                title: 'No saved searches yet',
                buttonText: 'Create a saved search',
                onTap: () {
                  // TODO: open SearchScreen and let user save filters
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Create saved search (wire later)')),
                  );
                },
              )
            else
              ..._searches.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _SavedSearchCard(
                    search: s,
                    onTap: () => _openSearchResults(s),
                    onToggleAlerts: (v) {
                      setState(() {
                        final i = _searches.indexWhere((e) => e.id == s.id);
                        if (i >= 0) _searches[i] = _searches[i].copyWith(alertsEnabled: v);
                      });
                    },
                    onEdit: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Edit search: ${s.title}')),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ---------------------------- View Model ---------------------------- */

class SavedSearchVM {
  const SavedSearchVM({
    required this.id,
    required this.title,
    required this.summary,
    required this.updatesLine,
    required this.alertsEnabled,
  });

  final String id;
  final String title;
  final String summary;
  final String updatesLine;
  final bool alertsEnabled;

  SavedSearchVM copyWith({bool? alertsEnabled}) {
    return SavedSearchVM(
      id: id,
      title: title,
      summary: summary,
      updatesLine: updatesLine,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
    );
    }
}

/* ---------------------------- UI ---------------------------- */

class _SavedSearchCard extends StatelessWidget {
  const _SavedSearchCard({
    required this.search,
    required this.onTap,
    required this.onToggleAlerts,
    required this.onEdit,
  });

  final SavedSearchVM search;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggleAlerts;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final bellColor = search.alertsEnabled ? AppColors.brandGreenDeep : AppColors.textMutedLight;

    return _FrostCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // left icon
                Container(
                  height: AppSizes.iconButtonBox + AppSpacing.md,
                  width: AppSizes.iconButtonBox + AppSpacing.md,
                  decoration: BoxDecoration(
                    color: AppColors.surface(context).withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: AppColors.overlay(context, 0.06)),
                  ),
                  child: Icon(Icons.saved_search_rounded, color: AppColors.brandBlueSoft),
                ),
                const SizedBox(width: AppSpacing.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        search.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.navy,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      Text(
                        search.summary,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMutedLight.withValues(alpha: 0.92),
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.brandOrange.withValues(alpha: 0.85)),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              search.updatesLine,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.navy.withValues(alpha: 0.85),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppSpacing.sm),

                // right controls
                Column(
                  children: [
                    InkWell(
                      onTap: () => onToggleAlerts(!search.alertsEnabled),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: Container(
                        height: AppSizes.iconButtonBox,
                        width: AppSizes.iconButtonBox,
                        decoration: BoxDecoration(
                          color: bellColor.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          border: Border.all(color: bellColor.withValues(alpha: 0.22)),
                        ),
                        child: Icon(
                          search.alertsEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                          color: bellColor.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      child: Container(
                        height: AppSizes.iconButtonBox,
                        width: AppSizes.iconButtonBox,
                        decoration: BoxDecoration(
                          color: AppColors.overlay(context, 0.04),
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          border: Border.all(color: AppColors.overlay(context, 0.06)),
                        ),
                        child: Icon(Icons.more_horiz_rounded, color: AppColors.textMuted(context)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ---------------------------- Shared UI ---------------------------- */

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.iconButtonBox,
      width: AppSizes.iconButtonBox,
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.92),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.overlay(context, 0.06)),
        boxShadow: AppShadows.soft(
          context,
          blur: AppSpacing.xxxl,
          y: AppSpacing.lg,
          alpha: 0.10,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Icon(icon, color: AppColors.textMuted(context)),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.buttonText,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String buttonText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxl),
        child: Column(
          children: [
            Icon(icon, size: AppSpacing.xxxl + AppSpacing.lg, color: AppColors.overlay(context, 0.22)),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            _PrimaryButton(text: buttonText, onTap: onTap),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return Material(
      color: disabled
          ? AppColors.overlay(context, 0.06)
          : AppColors.brandBlueSoft.withValues(alpha: 0.80),
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: SizedBox(
          height: AppSizes.minTap,
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: disabled ? AppColors.textMutedLight : AppColors.white,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FrostCard extends StatelessWidget {
  const _FrostCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: 0.62),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.surface(context).withValues(alpha: 0.55)),
          boxShadow: AppShadows.lift(context, blur: 18, y: 10, alpha: 0.08),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: child,
        ),
      ),
    );
  }
}