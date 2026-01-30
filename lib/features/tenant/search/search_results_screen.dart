import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

/// A small, clean "results wrapper" screen that you can navigate to from Saved Searches.
/// It renders a premium header + passes initial filters down to your search experience.
///
/// Later: you can replace the body with your real results list, map, sorting, etc.
class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({
    super.key,
    required this.title,
    required this.summary,
    required this.filters,
  });

  final String title;
  final String summary;

  /// Keep this flexible so it works with your backend filters later.
  /// Example keys:
  /// { "type": "rent", "city": "Lekki", "min": 800000, "max": 1200000, "beds": 2, "verified": true }
  final Map<String, dynamic> filters;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: Colors.transparent,
      safeAreaTop: true,
      safeAreaBottom: false,
      topBar: AppTopBar(
        title: title,
        leadingIcon: Icons.arrow_back_rounded,
        onLeadingTap: () => Navigator.of(context).maybePop(),
        actions: const [],
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
            Text(
              'Search results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
            ),
            const SizedBox(height: AppSpacing.s6),
            Text(
              summary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted(context),
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ✅ For now: show filters so you can confirm navigation is passing data correctly.
            // Replace this with your real results UI later.
            _FiltersPreview(filters: filters),

            const SizedBox(height: AppSpacing.lg),

            // Placeholder results area
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface(context).withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.overlay(context, 0.06)),
              ),
              child: Text(
                'TODO: Render results list/grid here.\n\n'
                'This screen exists so Saved Searches can navigate somewhere real.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersPreview extends StatelessWidget {
  const _FiltersPreview({required this.filters});
  final Map<String, dynamic> filters;

  @override
  Widget build(BuildContext context) {
    final entries = filters.entries.toList();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applied filters',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      e.key,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textMuted(context),
                          ),
                    ),
                  ),
                  Text(
                    '${e.value}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.navy,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}