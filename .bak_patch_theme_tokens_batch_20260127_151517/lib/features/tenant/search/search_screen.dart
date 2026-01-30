import 'package:flutter/material.dart';

import 'package:rentease_app/core/theme/app_colors.dart';
import 'package:rentease_app/core/theme/app_shadows.dart';
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
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return '₦$buf';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF1F3F8), Color(0xFFE9ECF4)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopHeader(onProfile: () {}),
              const SizedBox(height: 12),
              _SearchBar(onTap: () {}),
              const SizedBox(height: 16),

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
                  const SizedBox(width: 10),
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

              const SizedBox(height: 12),

              Text(
                '${_fmtNaira(_price.start)}                                ${_fmtNaira(_price.end)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1E2A3A),
                ),
              ),
              const SizedBox(height: 6),
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

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _Segment(
                      label: 'Residential',
                      active: _propertyTab == 0,
                      onTap: () => setState(() => _propertyTab = 0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Segment(
                      label: 'Commercial',
                      active: _propertyTab == 1,
                      onTap: () => setState(() => _propertyTab = 1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Segment(
                      label: 'Land',
                      active: _propertyTab == 2,
                      onTap: () => setState(() => _propertyTab = 2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Text(
                    'Buy',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF3C7C5A),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Rent',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF3C7C5A),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _BuyRentToggle(
                buy: _buy,
                onChanged: (v) => setState(() => _buy = v),
              ),

              const SizedBox(height: 12),

              Row(
                children: const [
                  Expanded(child: _MiniDrop(text: 'Min Beds  ›')),
                  SizedBox(width: 10),
                  Expanded(child: _MiniDrop(text: 'Min Baths')),
                ],
              ),
              const SizedBox(height: 10),
              const _MiniDrop(text: 'Min Plot Size (sqft)'),

              const SizedBox(height: 16),

              Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBFD0DA).withValues(alpha: 0.30),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.overlay(context, 0.06),
                      ),
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
                    right: 12,
                    top: 12,
                    child: _PillButton(
                      icon: Icons.map_rounded,
                      text: 'Map',
                      onTap: () {},
                      filled: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Center(
                child: SizedBox(
                  width: 280,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3C7C5A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 10,
                      shadowColor: AppColors.overlay(context, 0.20),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({required this.onProfile});
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // logo circle
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: AppColors.surface(context).withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                blurRadius: 14,
                offset: const Offset(0, 8),
                color: AppColors.overlay(context, 0.08),
              ),
            ],
          ),
          child: const Icon(Icons.eco_rounded, color: Color(0xFF3C7C5A)),
        ),
        const SizedBox(width: 10),
        Text(
          'HomeStead',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onProfile,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.surface(context).withValues(alpha: 0.92),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.overlay(context, 0.08)),
            ),
            child: const Icon(Icons.person_rounded, color: Color(0xFF5C6677)),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.overlay(context, 0.06)),
          boxShadow: AppShadows.lift(context, blur: 18, y: 10, alpha: 0.08),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Color(0xFF4E5A6D)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search location, price, or city...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4E5A6D),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF3C7C5A)),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: filled
              ? const Color(0xFF3C7C5A).withValues(alpha: 0.88)
              : AppColors.surface(context).withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.overlay(context, 0.06)),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              offset: const Offset(0, 8),
              color: AppColors.overlay(context, 0.08),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: filled ? AppColors.surface(context) : const Color(0xFF3C7C5A)),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: filled ? AppColors.surface(context) : const Color(0xFF1E2A3A),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF2D5E9C).withValues(alpha: 0.92)
              : AppColors.surface(context).withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.overlay(context, 0.06)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF1E2A3A),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onChanged(true),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: buy ? const Color(0xFF3C7C5A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Buy',
                  style: TextStyle(
                    color: buy ? Colors.white : const Color(0xFF6F7785),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onChanged(false),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !buy ? const Color(0xFF3C7C5A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Rent',
                  style: TextStyle(
                    color: !buy ? Colors.white : const Color(0xFF6F7785),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
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
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4E5A6D),
              ),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF4E5A6D),
          ),
        ],
      ),
    );
  }
}
