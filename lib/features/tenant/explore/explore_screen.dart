// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/ui/nav/tenant_nav.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import '../../../core/utils/money_format.dart';
import '../../../shared/models/listing_model.dart';

import '../listing_detail/listing_detail_screen.dart';
// import '../search/search_screen.dart';

enum _ExploreMode { buy, rent, land }
enum _MarketSegment { residential, commercial }

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _activeChip = 0;

  final List<String> _chips = const [
    'For You',
    'Buy',
    'Rent',
    'Land',
    'Verified',
  ];

  _ExploreMode _mode = _ExploreMode.buy;
  _MarketSegment _segment = _MarketSegment.residential;

  // local saved state (later wire to backend)
  final Set<String> _savedIds = <String>{};

  // ---------- helpers (no hardcoded alphas) ----------
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs); // 32/36

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs); // 4/36

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl; // 4/32

  void _setModeFromChip(int index) {
    setState(() {
      _activeChip = index;
      final selected = _chips[index];

      // If user is in Commercial and taps Buy/Rent/Land/ForYou, return to Residential.
      if (_segment == _MarketSegment.commercial &&
          selected != 'Verified' &&
          selected != 'For You') {
        _segment = _MarketSegment.residential;
      }

      if (selected == 'Rent') {
        _mode = _ExploreMode.rent;
      } else if (selected == 'Land') {
        _mode = _ExploreMode.land;
      } else {
        // For You, Buy, Verified -> default to buy mode (residential)
        _mode = _ExploreMode.buy;
      }
    });
  }

  void _setSegment(_MarketSegment seg) {
    setState(() {
      _segment = seg;
      // When Commercial is active, listings come from commercial bucket only.
      // Verified chip still works (filters within that bucket).
    });
  }

  ListingModel _toListingModel(_DemoListing l) {
    return ListingModel(
      id: l.id,
      title: l.title,
      price: l.price,
      currency: '₦',
      location: l.location,
      status: 'published',
      beds: l.beds == 0 ? null : l.beds,
      baths: l.baths == 0 ? null : l.baths,
      type: l.type, // Buy / Rent / Land / Commercial
      mediaUrls: const [],
      propertyStatus: 'available',
      ownerName: 'RentEase',
      ownerId: 'system',
    );
  }

  void _toggleSaved(String id) {
    setState(() {
      if (_savedIds.contains(id)) {
        _savedIds.remove(id);
      } else {
        _savedIds.add(id);
      }
    });
  }

  void _openSearch() {
    // ✅ Correct: switch bottom-nav tab instead of Navigator.push()
    TenantNav.goToSearch(context);
  }

  /// IMPORTANT:
  /// We must pass the SAME heroTag used by the tapped card into the detail screen.
  void _openListing(_DemoListing demo, {required String heroTag}) {
    final listing = _toListingModel(demo);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(
          listing: listing,
          heroTag: heroTag,
          heroGradient: demo.gradient,
          isVerified: demo.verified,
          priceLabelOverride: demo.priceLabel,
        ),
      ),
    );
  }

  // ---------------- Demo data (token-sized; no random counts) ----------------
  late final List<_DemoListing> _buyListings = List.generate(
    AppSpacing.sm.toInt(), // 8
    (i) => _DemoListing(
      id: 'buy_$i',
      title: i.isEven ? 'Premium Family Duplex' : 'Modern 2BR Apartment',
      location: i.isEven ? 'Ikoyi • Lagos' : 'Lekki • Lagos',
      priceLabel: '₦${(115000000 + (i * 2500000)).toString()}',
      badge: i % 3 == 0 ? 'Verified' : 'Hot',
      gradient:
          i.isEven ? AppColors.demoCardGradientA : AppColors.demoCardGradientB,
      beds: 3 + (i % 2),
      baths: 2 + (i % 2),
      sqft: 1800 + (i * 40),
      verified: i % 3 == 0,
      type: 'Buy',
      price: 115000000 + (i * 2500000),
      segment: _MarketSegment.residential,
    ),
  );

  late final List<_DemoListing> _rentListings = List.generate(
    AppSpacing.sm.toInt(), // 8
    (i) => _DemoListing(
      id: 'rent_$i',
      title: i.isEven ? 'Luxury Studio Apartment' : 'Cozy 1BR Apartment',
      location: i.isEven ? 'Ikeja • Lagos' : 'Yaba • Lagos',
      priceLabel: '₦${(1200000 + (i * 85000)).toString()}/yr',
      badge: i % 4 == 0 ? 'Verified' : 'New',
      gradient:
          i.isEven ? AppColors.demoCardGradientB : AppColors.demoCardGradientA,
      beds: 1,
      baths: 1,
      sqft: 650 + (i * 25),
      verified: i % 4 == 0,
      type: 'Rent',
      price: 1200000 + (i * 85000),
      segment: _MarketSegment.residential,
    ),
  );

  late final List<_DemoListing> _landListings = List.generate(
    AppSpacing.sm.toInt(), // 8
    (i) => _DemoListing(
      id: 'land_$i',
      title: 'Prime Land Plot',
      location: i.isEven ? 'Ajah • Lagos' : 'Gwarinpa • Abuja',
      priceLabel: '₦${(45000000 + (i * 1200000)).toString()}',
      badge: i % 5 == 0 ? 'Verified' : 'Land',
      gradient:
          i.isEven ? AppColors.demoCardGradientA : AppColors.demoCardGradientB,
      beds: 0,
      baths: 0,
      sqft: 5000 + (i * 250),
      verified: i % 5 == 0,
      type: 'Land',
      price: 45000000 + (i * 1200000),
      segment: _MarketSegment.residential,
    ),
  );

  late final List<_DemoListing> _commercialListings = List.generate(
    AppSpacing.sm.toInt(), // 8
    (i) => _DemoListing(
      id: 'com_$i',
      title: i.isEven ? 'Prime Office Space' : 'Retail Shopfront',
      location: i.isEven ? 'Victoria Island • Lagos' : 'Wuse 2 • Abuja',
      priceLabel: '₦${(8500000 + (i * 500000)).toString()}/yr',
      badge: i % 3 == 0 ? 'Featured' : 'Commercial',
      gradient:
          i.isEven ? AppColors.demoCardGradientB : AppColors.demoCardGradientA,
      beds: 0,
      baths: 0,
      sqft: 120 + (i * 15),
      verified: i % 3 == 0,
      type: 'Commercial',
      price: 8500000 + (i * 500000),
      segment: _MarketSegment.commercial,
    ),
  );

  List<_DemoListing> get _activeListings {
    final bool onlyVerified = _chips[_activeChip] == 'Verified';

    final List<_DemoListing> base = (_segment == _MarketSegment.commercial)
        ? _commercialListings
        : switch (_mode) {
            _ExploreMode.buy => _buyListings,
            _ExploreMode.rent => _rentListings,
            _ExploreMode.land => _landListings,
          };

    if (!onlyVerified) return base;
    return base.where((x) => x.verified).toList();
  }

  String get _activeTitle {
    if (_segment == _MarketSegment.commercial) return 'Commercial';
    return switch (_mode) {
      _ExploreMode.buy => 'Buy',
      _ExploreMode.rent => 'Rent',
      _ExploreMode.land => 'Land',
    };
  }

  String _heroTag({
    required String section,
    required _DemoListing demo,
    required int index,
  }) {
    // Scoped + indexed to avoid duplicates across multiple lists/sections.
    return 'listingHero:explore:$section:${demo.id}:$index';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: Colors.transparent,
      safeAreaTop: true,
      safeAreaBottom: false,
      appBar: AppTopBar(
        title: 'Explore',
        subtitle: '$_activeTitle listings • tap any card',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.screenH),
            child: InkWell(
              onTap: () {},
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
                  Icons.notifications_none_rounded,
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
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            _SearchStub(onTap: _openSearch),
            const SizedBox(height: AppSpacing.md),

            _QuickActionsRow(
              segment: _segment,
              onFilter: () {},
              onResidential: () => _setSegment(_MarketSegment.residential),
              onCommercial: () => _setSegment(_MarketSegment.commercial),
            ),

            const SizedBox(height: AppSpacing.md),

            _ChipRow(
              chips: _chips,
              activeIndex: _activeChip,
              onTap: _setModeFromChip,
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              'Featured',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ✅ Responsive: 2 cards fully visible
            LayoutBuilder(
              builder: (context, constraints) {
                final gap = AppSpacing.md.toDouble();
                final viewport = constraints.maxWidth;

                var cardW = (viewport - gap) / AppSpacing.s2; // 2 cards
                cardW = cardW.clamp(
                  AppSizes.featuredCardMinW,
                  AppSizes.featuredCardMaxW,
                );

                final cardH = cardW * AppSizes.featuredCardAspect;
                final rowH = cardH + AppSpacing.lg;

                final featuredCount =
                    _activeListings.length < AppSpacing.s6.toInt()
                        ? _activeListings.length
                        : AppSpacing.s6.toInt();

                return SizedBox(
                  height: rowH,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: featuredCount,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, i) {
                      final demo = _activeListings[i];

                      final priceText =
                          (demo.type == 'Rent' || demo.type == 'Commercial')
                              ? demo.priceLabel
                              : fmtNairaCompact(demo.price);

                      final heroTag = _heroTag(
                        section: 'featured',
                        demo: demo,
                        index: i,
                      );

                      return _FeaturedCard(
                        width: cardW,
                        height: cardH,
                        heroTag: heroTag,
                        title: demo.title,
                        location: demo.location,
                        price: priceText,
                        badge: demo.verified ? 'Verified' : demo.badge,
                        gradient: demo.gradient,
                        onTap: () => _openListing(demo, heroTag: heroTag),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            Row(
              children: [
                Text(
                  'Popular near you',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary(context),
                      ),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('See all  ›')),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount:
                  _activeListings.length.clamp(0, AppSpacing.sm.toInt()),
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) {
                final demo = _activeListings[i];

                final meta = demo.beds == 0
                    ? 'Size • ${demo.sqft} sqft'
                    : '${demo.beds} Beds • ${demo.baths} Baths • ${demo.sqft} sqft';

                final priceText =
                    (demo.type == 'Rent' || demo.type == 'Commercial')
                        ? demo.priceLabel
                        : fmtNairaCompact(demo.price);

                final heroTag = _heroTag(
                  section: 'nearby',
                  demo: demo,
                  index: i,
                );

                return _ListingRowCard(
                  heroTag: heroTag,
                  title: demo.title,
                  location: demo.location,
                  price: priceText,
                  meta: meta,
                  onTap: () => _openListing(demo, heroTag: heroTag),
                  onToggleSaved: () => _toggleSaved(demo.id),
                  isSaved: _savedIds.contains(demo.id),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- UI widgets ----------------

class _SearchStub extends StatelessWidget {
  const _SearchStub({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted(context);

    final alphaSurfaceStrong =
        AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);
    final alphaBorderSoft = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
    final alphaShadowSoft = AppSpacing.xs / AppSpacing.xxxl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: Container(
        height: AppSizes.searchFieldHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        decoration: BoxDecoration(
          color:
              AppColors.surface(context).withValues(alpha: alphaSurfaceStrong),
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(color: AppColors.overlay(context, alphaBorderSoft)),
          boxShadow: AppShadows.lift(
            context,
            blur: AppSpacing.xxxl + AppSpacing.s2,
            y: AppSpacing.xl,
            alpha: alphaShadowSoft,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: muted),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Search by location, rent, or city...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const Icon(Icons.tune_rounded, color: AppColors.brandGreenDeep),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.segment,
    required this.onFilter,
    required this.onResidential,
    required this.onCommercial,
  });

  final _MarketSegment segment;
  final VoidCallback onFilter;
  final VoidCallback onResidential;
  final VoidCallback onCommercial;

  @override
  Widget build(BuildContext context) {
    final resActive = segment == _MarketSegment.residential;
    final comActive = segment == _MarketSegment.commercial;

    return Row(
      children: [
        Expanded(
          child: _PillButton(
            icon: Icons.filter_alt_rounded,
            text: 'Filters',
            onTap: onFilter,
            filled: true,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _PillButton(
            icon: Icons.home_rounded,
            text: 'Residential',
            onTap: onResidential,
            filled: resActive,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _PillButton(
            icon: Icons.apartment_rounded,
            text: 'Commercial',
            onTap: onCommercial,
            filled: comActive,
          ),
        ),
      ],
    );
  }
}

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
                border:
                    Border.all(color: AppColors.overlay(context, alphaBorder)),
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

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.width,
    required this.height,
    required this.heroTag,
    required this.title,
    required this.location,
    required this.price,
    required this.badge,
    required this.gradient,
    required this.onTap,
  });

  final double width;
  final double height;
  final String heroTag;
  final String title;
  final String location;
  final String price;
  final String badge;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alphaBadge = AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Hero(
        tag: heroTag,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: AppShadows.lift(
              context,
              blur: AppSpacing.xxxl + AppSpacing.lg,
              y: AppSpacing.xl,
              alpha: AppSpacing.xs / AppSpacing.xxl,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: AppSpacing.sm,
                top: AppSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.s6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: alphaBadge),
                    borderRadius: BorderRadius.circular(AppRadii.chip),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: alphaBadge),
                    ),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withValues(
                              alpha: AppSpacing.xxxl /
                                  (AppSpacing.xxxl + AppSpacing.sm),
                            ),
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(
                          alpha:
                              AppSpacing.lg / (AppSpacing.xxxl + AppSpacing.lg),
                        ),
                        borderRadius: BorderRadius.circular(AppRadii.button),
                        border: Border.all(
                          color: AppColors.white.withValues(
                            alpha: AppSpacing.lg /
                                (AppSpacing.xxxl + AppSpacing.lg),
                          ),
                        ),
                      ),
                      child: Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListingRowCard extends StatelessWidget {
  const _ListingRowCard({
    required this.heroTag,
    required this.title,
    required this.location,
    required this.price,
    required this.meta,
    required this.onTap,
    required this.onToggleSaved,
    required this.isSaved,
  });

  final String heroTag;
  final String title;
  final String location;
  final String price;
  final String meta;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;
  final bool isSaved;

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
            Hero(
              tag: heroTag,
              child: Container(
                height: AppSizes.listThumbSize,
                width: AppSizes.listThumbSize,
                decoration: BoxDecoration(
                  color: AppColors.brandBlueSoft.withValues(
                    alpha: AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md),
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border:
                      Border.all(color: AppColors.overlay(context, alphaBorder)),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: AppColors.brandBlueSoft,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary(context),
                                  ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      InkWell(
                        onTap: onToggleSaved,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          child: Icon(
                            isSaved
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isSaved
                                ? AppColors.danger
                                : AppColors.textMuted(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    meta,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted(context),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.brandGreenDeep,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted(context)),
              ],
            ),
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

    final alphaFill = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    final bg = filled
        ? AppColors.brandGreenDeep.withValues(alpha: alphaFill)
        : AppColors.surface(context).withValues(alpha: alphaFill);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: Container(
        height: AppSizes.pillButtonHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(
            color: AppColors.overlay(
              context,
              AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs),
            ),
          ),
          boxShadow: AppShadows.soft(
            context,
            blur: AppSpacing.xxxl,
            y: AppSpacing.xl,
            alpha: AppSpacing.xs / AppSpacing.xxxl,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppSpacing.xl - AppSpacing.s2, color: fg),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: fg, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- demo data ----------------

class _DemoListing {
  const _DemoListing({
    required this.id,
    required this.title,
    required this.location,
    required this.priceLabel,
    required this.badge,
    required this.gradient,
    required this.beds,
    required this.baths,
    required this.sqft,
    required this.verified,
    required this.type,
    required this.price,
    required this.segment,
  });

  final String id;
  final String title;
  final String location;
  final String priceLabel;
  final String badge;
  final Gradient gradient;
  final int beds;
  final int baths;
  final int sqft;
  final bool verified;
  final String type; // Buy / Rent / Land / Commercial
  final int price;
  final _MarketSegment segment;
}