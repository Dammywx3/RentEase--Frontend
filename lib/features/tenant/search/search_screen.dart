import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

// ✅ switch tabs instead of Navigator.pop
import '../../../core/ui/nav/tenant_nav.dart';

// ✅ results destination
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryCtrl = TextEditingController();
  final FocusNode _queryFocus = FocusNode();

  int _propertyTab = 0; // 0 residential, 1 commercial, 2 land
  bool _buy = true;

  // dropdown values
  int? _minBeds;
  int? _minBaths;
  int? _minPlotSqft;

  // optional filter
  bool _verifiedOnly = false;

  // dynamic budget range + selection
  late RangeValues _price;

  // -------- budgets you requested --------
  static const double _rentMin = 50_000;
  static const double _rentMax = 100_000_000;

  static const double _buyMin = 20_000_000;
  static const double _buyMax = 1_000_000_000;

  static const double _landMin = 500_000;
  static const double _landMax = 500_000_000;

  bool get _isLand => _propertyTab == 2;

  double get _budgetMin {
    if (_isLand) return _landMin;
    return _buy ? _buyMin : _rentMin;
  }

  double get _budgetMax {
    if (_isLand) return _landMax;
    return _buy ? _buyMax : _rentMax;
  }

  @override
  void initState() {
    super.initState();
    // default is Residential + Buy -> buy range
    _price = RangeValues(_budgetMin, _budgetMax);
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _queryFocus.dispose();
    super.dispose();
  }

  // ---------- helpers ----------

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

  String get _categoryLabel {
    if (_propertyTab == 1) return 'Commercial';
    if (_propertyTab == 2) return 'Land';
    return 'Residential';
  }

  String get _modeLabel {
    // land is special mode
    if (_propertyTab == 2) return 'land';
    return _buy ? 'buy' : 'rent';
  }

  void _applyBudgetPreset() {
    // reset budget fully to the active range
    _price = RangeValues(_budgetMin, _budgetMax);
  }

  void _setPropertyTab(int v) {
    setState(() {
      _propertyTab = v;

      if (_isLand) {
        // land rules: disable beds/baths (also clear)
        _minBeds = null;
        _minBaths = null;
      }

      // reset budget to correct range (rent/buy/land)
      _applyBudgetPreset();
    });
  }

  void _setBuy(bool v) {
    // if land selected, ignore buy/rent toggle
    if (_isLand) return;

    setState(() {
      _buy = v;
      _applyBudgetPreset();
    });
  }

  Map<String, dynamic> _buildFilters() {
    final q = _queryCtrl.text.trim();

    final map = <String, dynamic>{
      'mode': _modeLabel, // buy/rent/land
      'query': q,

      // budget
      'min': _price.start.toInt(),
      'max': _price.end.toInt(),

      // Land: beds/baths intentionally null
      'beds': _isLand ? null : _minBeds,
      'baths': _isLand ? null : _minBaths,

      // Plot allowed (and meaningful for Land)
      'plotMinSqft': _minPlotSqft,

      'verified': _verifiedOnly,
      'category': _categoryLabel, // Residential/Commercial/Land
    };

    // ✅ keep propertyTab only for debug builds
    assert(() {
      map['propertyTab'] = _propertyTab;
      return true;
    }());

    // remove nulls and empty strings
    map.removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));
    return map;
  }

  String _buildSummary() {
    final q = _queryCtrl.text.trim();
    final qPart = q.isEmpty ? 'Any location' : q;
    final typePart = _modeLabel;
    final pricePart = '${_fmtNaira(_price.start)} – ${_fmtNaira(_price.end)}';
    return '$typePart • $qPart • $pricePart';
  }

  void _openResults() {
    FocusScope.of(context).unfocus();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(
          title: 'Results',
          summary: _buildSummary(),
          filters: _buildFilters(),
        ),
      ),
    );
  }

  void _resetAll() {
    setState(() {
      _queryCtrl.clear();
      _propertyTab = 0;
      _buy = true;
      _minBeds = null;
      _minBaths = null;
      _minPlotSqft = null;
      _verifiedOnly = false;

      // reset budget to default (Residential+Buy)
      _applyBudgetPreset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const bottomPad = 140.0;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        appBar: AppTopBar(
          title: 'Search',
          leading: Padding(
            padding: const EdgeInsets.only(left: AppSpacing.screenH),
            child: InkWell(
              onTap: () => TenantNav.goToExplore(context),
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: Container(
                height: AppSizes.iconButtonBox,
                width: AppSizes.iconButtonBox,
                decoration: BoxDecoration(
                  color: AppColors.surface(context).withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.overlay(context, 0.08)),
                  boxShadow: AppShadows.lift(
                    context,
                    blur: 14,
                    y: 10,
                    alpha: 0.08,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.textPrimary(context),
                ),
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

            _SearchBarInput(
              controller: _queryCtrl,
              focusNode: _queryFocus,
              onSubmitted: (_) => _openResults(),
              onClear: () {
                setState(() => _queryCtrl.clear());
                _queryFocus.requestFocus();
              },
            ),

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
                  onPressed: _resetAll,
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

            // ✅ dynamic budget slider range (rent/buy/land)
            RangeSlider(
              values: _price,
              min: _budgetMin,
              max: _budgetMax,
              divisions: 80,
              onChanged: (v) => setState(() => _price = v),
            ),

            Text(
              '${_fmtNaira(_budgetMin)}  -  ${_fmtNaira(_budgetMax)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w700,
                  ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Category tabs
            Row(
              children: [
                Expanded(
                  child: _Segment(
                    label: 'Residential',
                    active: _propertyTab == 0,
                    onTap: () => _setPropertyTab(0),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Segment(
                    label: 'Commercial',
                    active: _propertyTab == 1,
                    onTap: () => _setPropertyTab(1),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _Segment(
                    label: 'Land',
                    active: _propertyTab == 2,
                    onTap: () => _setPropertyTab(2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Buy/Rent toggle (disabled for Land)
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

            Opacity(
              opacity: _isLand ? 0.45 : 1,
              child: _BuyRentToggle(
                buy: _buy,
                onChanged: (v) => _setBuy(v),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            _ToggleRow(
              label: 'Verified only',
              value: _verifiedOnly,
              onChanged: (v) => setState(() => _verifiedOnly = v),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Beds/Baths disabled on Land
            Row(
              children: [
                Expanded(
                  child: _DropSelect<int>(
                    label: 'Min Beds',
                    enabled: !_isLand,
                    value: _minBeds,
                    items: const [0, 1, 2, 3, 4, 5, 6],
                    itemLabel: (v) => v == 0 ? 'Any' : '$v+',
                    onChanged: (v) =>
                        setState(() => _minBeds = (v == 0) ? null : v),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _DropSelect<int>(
                    label: 'Min Baths',
                    enabled: !_isLand,
                    value: _minBaths,
                    items: const [0, 1, 2, 3, 4, 5, 6],
                    itemLabel: (v) => v == 0 ? 'Any' : '$v+',
                    onChanged: (v) =>
                        setState(() => _minBaths = (v == 0) ? null : v),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Plot enabled always (and meaningful for Land)
            _DropSelect<int>(
              label: 'Min Plot Size (sqft)',
              enabled: true,
              value: _minPlotSqft,
              items: const [0, 600, 900, 1200, 1800, 2400, 3600, 5000, 10000],
              itemLabel: (v) => v == 0 ? 'Any' : '$v+ sqft',
              onChanged: (v) =>
                  setState(() => _minPlotSqft = (v == 0) ? null : v),
            ),

            const SizedBox(height: AppSpacing.md),

            _MapPreview(onMapTap: () {}),

            const SizedBox(height: AppSpacing.lg),

            Center(
              child: SizedBox(
                width: 280,
                height: 56,
                child: ElevatedButton(
                  onPressed: _openResults,
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
      ),
    );
  }
}

/// ✅ Editable search bar
class _SearchBarInput extends StatelessWidget {
  const _SearchBarInput({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted(context);

    return Container(
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
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Type location, state, address, or name…',
                hintStyle: TextStyle(
                  color: muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Icon(Icons.close_rounded, color: muted),
            ),
          ),
        ],
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

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: alphaSurface),
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: AppColors.overlay(context, alphaBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.brandGreenDeep,
          ),
        ],
      ),
    );
  }
}

class _DropSelect<T> extends StatelessWidget {
  const _DropSelect({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.enabled = true,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
    final muted = AppColors.textMuted(context);

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          decoration: BoxDecoration(
            color: AppColors.surface(context).withValues(alpha: alphaSurface),
            borderRadius: BorderRadius.circular(AppRadii.button),
            border: Border.all(color: AppColors.overlay(context, alphaBorder)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: muted),
              hint: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: muted,
                    ),
              ),
              items: items
                  .map(
                    (it) => DropdownMenuItem<T>(
                      value: it,
                      child: Text(
                        itemLabel(it),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary(context),
                            ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
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