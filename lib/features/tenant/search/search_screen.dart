import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_sizes.dart';

// ✅ NEW: switch tabs instead of Navigator.push/pop
import '../../../core/ui/nav/tenant_nav.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  RangeValues _price = const RangeValues(20_000_000, 500_000_000);
  int _propertyTab = 0; // 0 residential, 1 commercial, 2 land
  bool _buy = true;

  String _fmtNaira(num v) {
    final s = v.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) {
        buf.write(',');
      }
    }
    return '₦$buf';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const bottomPad = 140.0;

    return AppScaffold(
      backgroundColor: Colors.transparent,
      safeAreaTop: true,
      safeAreaBottom: false,
      appBar: AppTopBar(
        title: 'Search',
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.screenH),
          child: InkWell(
            // ✅ Option A: DO NOT POP. Switch tabs.
            onTap: () => TenantNav.goToExplore(context),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: Container(
              height: AppSizes.iconButtonBox,
              width: AppSizes.iconButtonBox,
              decoration: BoxDecoration(
                color: AppColors.surface(context).withValues(alpha: 0.92),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.overlay(context, 0.08)),
                boxShadow: AppShadows.lift(context, blur: 14, y: 10, alpha: 0.08),
              ),
              child: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary(context)),
            ),
          ),
        ),
        actions: const [],
      ),
      scroll: true,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.sm,
        AppSpacing.screenH,
        bottomPad,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          _SearchBar(onTap: () {}),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _PillButton(
                  icon: Icons.filter_alt_rounded,
                  text: 'Advanced Filters',
                  onTap: () {},
                  filled: true,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  setState(() {
                    _price = const RangeValues(20_000_000, 500_000_000);
                    _propertyTab = 0;
                    _buy = true;
                  });
                },
                child: const Text('Reset All  ›'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${_fmtNaira(_price.start)}                                ${_fmtNaira(_price.end)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary(context),
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          RangeSlider(
            values: _price,
            min: 20_000_000,
            max: 1_000_000_000,
            divisions: 40,
            onChanged: (v) => setState(() => _price = v),
          ),
          Text(
            '${_fmtNaira(20_000_000)}  -  ${_fmtNaira(1_000_000_000)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _Segment(
                  label: 'Residential',
                  active: _propertyTab == 0,
                  onTap: () => setState(() => _propertyTab = 0),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Segment(
                  label: 'Commercial',
                  active: _propertyTab == 1,
                  onTap: () => setState(() => _propertyTab = 1),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _Segment(
                  label: 'Land',
                  active: _propertyTab == 2,
                  onTap: () => setState(() => _propertyTab = 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'Buy',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.brandGreenDeep,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const Spacer(),
              Text(
                'Rent',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.brandGreenDeep,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _BuyRentToggle(
            buy: _buy,
            onChanged: (v) => setState(() => _buy = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Row(
            children: [
              Expanded(child: _MiniDrop(text: 'Min Beds  ›')),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: _MiniDrop(text: 'Min Baths')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const _MiniDrop(text: 'Min Plot Size (sqft)'),
          const SizedBox(height: AppSpacing.md),
          _MapPreview(onMapTap: () {}),
          const SizedBox(height: AppSpacing.lg),

          Center(
            child: SizedBox(
              width: 280,
              height: 56,
              child: ElevatedButton(
                // ✅ Option A: keep user in shell — switch tab or stay on Search.
                // If you want to jump back to Explore after applying:
                onPressed: () => TenantNav.goToExplore(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandGreenDeep,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  elevation: 10,
                  shadowColor: AppColors.overlay(context, 0.20),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: AppTypography.size18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(color: AppColors.overlay(context, 0.06)),
          boxShadow: AppShadows.lift(context, blur: 18, y: 10, alpha: 0.08),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: muted),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Search location, price, or city...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.brandGreenDeep),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.filled,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppColors.white : AppColors.brandGreenDeep;
    final bg = filled
        ? AppColors.brandGreenDeep.withValues(alpha: 0.88)
        : AppColors.surface(context).withValues(alpha: 0.78);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(color: AppColors.overlay(context, 0.06)),
          boxShadow: AppShadows.lift(context, blur: 14, y: 10, alpha: 0.08),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg),
            const SizedBox(width: AppSpacing.sm),
            Text(
              text,
              style: TextStyle(
                color: filled ? AppColors.white : AppColors.textPrimary(context),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeBg = AppColors.brandBlueSoft.withValues(alpha: 0.92);
    final inactiveBg = AppColors.surface(context).withValues(alpha: 0.75);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(color: AppColors.overlay(context, 0.06)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.white : AppColors.textPrimary(context),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _BuyRentToggle extends StatelessWidget {
  const _BuyRentToggle({required this.buy, required this.onChanged});

  final bool buy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onChanged(true),
              borderRadius: BorderRadius.circular(AppRadii.button),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: buy ? AppColors.brandGreenDeep : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.button),
                ),
                child: Text(
                  'Buy',
                  style: TextStyle(
                    color: buy ? AppColors.white : AppColors.textMuted(context),
                    fontWeight: FontWeight.w900,
                    fontSize: AppTypography.size16,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onChanged(false),
              borderRadius: BorderRadius.circular(AppRadii.button),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !buy ? AppColors.brandGreenDeep : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.button),
                ),
                child: Text(
                  'Rent',
                  style: TextStyle(
                    color: !buy ? AppColors.white : AppColors.textMuted(context),
                    fontWeight: FontWeight.w900,
                    fontSize: AppTypography.size16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniDrop extends StatelessWidget {
  const _MiniDrop({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted(context);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: muted,
                  ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, color: muted),
        ],
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.onMapTap});
  final VoidCallback onMapTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final mapBg = AppColors.isDark(context)
        ? AppColors.surface2(context).withValues(alpha: 0.55)
        : AppColors.brandBlueSoft.withValues(alpha: 0.10);

    return Stack(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: mapBg,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(color: AppColors.overlay(context, 0.06)),
          ),
          child: Center(
            child: Text(
              'Map Preview (demo)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface.withValues(alpha: 0.60),
                  ),
            ),
          ),
        ),
        Positioned(
          right: AppSpacing.sm,
          top: AppSpacing.sm,
          child: _PillButton(
            icon: Icons.map_rounded,
            text: 'Map',
            onTap: onMapTap,
            filled: false,
          ),
        ),
      ],
    );
  }
}