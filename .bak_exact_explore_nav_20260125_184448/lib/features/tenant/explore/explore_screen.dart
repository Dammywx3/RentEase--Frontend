import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const _bgPath = 'assets/images/screen_bg.png';
  static const _logoPath = 'assets/images/rentease_logo2.png';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppScaffold(
      backgroundImagePath: _bgPath,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _TopRow(cs: cs)),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          SliverToBoxAdapter(child: _SearchBar(cs: cs)),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          SliverToBoxAdapter(child: _SectionTitle(title: 'Featured Listings')),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          SliverToBoxAdapter(child: _FeaturedCard(cs: cs)),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          SliverToBoxAdapter(child: _QuickActions(cs: cs)),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
          SliverToBoxAdapter(child: _SectionTitle(title: 'Latest Listings')),
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _ListingMiniCard(
                  cs: cs,
                  price: i.isEven ? 'US\$900,000' : 'US\$129,000',
                  meta: i.isEven
                      ? '4 bds | 3 ba | 2,676 sqft'
                      : '3 bds | 2 ba | 1,900 sqft',
                  location: i.isEven ? 'Sand Springs, OK' : 'Jenks, OK',
                ),
                childCount: 6,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            ExploreScreen._logoPath,
            width: 34,
            height: 34,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.home_rounded, color: cs.primary),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'HomeStead',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const Spacer(),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: Colors.black.withValues(alpha: 0.10),
              ),
            ],
          ),
          child: Icon(Icons.person_rounded, color: cs.primary),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search location, price, or city...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.70),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, 14),
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=1400&q=80&auto=format&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: cs.surface,
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 44,
                      color: cs.outline,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(Icons.favorite_border_rounded, color: cs.onSurface),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.70),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premium Villa',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: cs.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Verified Deal',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cs.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'US\$1,150,000',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tulsa, OK',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.75),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
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

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    Widget pill({
      required IconData icon,
      required String label,
      bool filled = true,
    }) {
      final bg = filled
          ? cs.primary.withValues(alpha: 0.18)
          : cs.surface.withValues(alpha: 0.80);
      final fg = filled ? cs.primary : cs.onSurface;

      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget smallPill({required IconData icon, required String label}) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.80),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: cs.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            pill(icon: Icons.home_rounded, label: 'Buy'),
            const SizedBox(width: AppSpacing.md),
            pill(icon: Icons.shield_rounded, label: 'Agents'),
            const SizedBox(width: AppSpacing.md),
            pill(icon: Icons.key_rounded, label: 'Rent'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            smallPill(icon: Icons.terrain_rounded, label: 'Land'),
            const SizedBox(width: AppSpacing.md),
            smallPill(icon: Icons.apartment_rounded, label: 'Commercial'),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            smallPill(icon: Icons.bookmark_rounded, label: 'Saved'),
            const SizedBox(width: AppSpacing.md),
            smallPill(icon: Icons.calendar_month_rounded, label: 'Viewings'),
            const SizedBox(width: AppSpacing.md),
            smallPill(icon: Icons.notifications_rounded, label: 'Alerts'),
          ],
        ),
      ],
    );
  }
}

class _ListingMiniCard extends StatelessWidget {
  const _ListingMiniCard({
    required this.cs,
    required this.price,
    required this.meta,
    required this.location,
  });

  final ColorScheme cs;
  final String price;
  final String meta;
  final String location;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=1200&q=80&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: cs.surface,
                        child: Center(
                          child: Icon(Icons.image_outlined, color: cs.outline),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: cs.surface.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 18,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    price,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
