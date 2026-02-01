// lib/features/tenant/explore/explore_screen.dart
// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';

import '../../../core/config/env.dart';
import '../../../core/network/marketplace_api.dart';
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
import '../../../shared/stores/saved_store.dart';

import '../listing_detail/listing_detail_screen.dart';

enum _ExploreMode { buy, rent, land }
enum _MarketSegment { residential, commercial }

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // ✅ Single source of truth:
  late final MarketplaceApi _api = MarketplaceApi(baseUrl: Env.baseUrl);

  int _activeChip = 0;
  final List<String> _chips = const ['For You', 'Buy', 'Rent', 'Land', 'Verified'];

  _ExploreMode _mode = _ExploreMode.buy;
  _MarketSegment _segment = _MarketSegment.residential;

  // Pagination / loading
  final List<ListingModel> _items = <ListingModel>[];
  final Map<String, bool> _verifiedById = <String, bool>{};

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _offset = 0;
  static const int _limit = 20;

  // ---------- helpers (no hardcoded alphas) ----------
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

  void _setModeFromChip(int index) {
    setState(() {
      _activeChip = index;
      final selected = _chips[index];

      // ✅ FIX: Do NOT force segment changes.
      // Segment is UI-only for now; backend ignores it, but UI should not block user.

      // ✅ FIX: "Verified" and "For You" should NOT reset the current mode.
      // Verified respects current mode (buy/rent/land).
      if (selected == 'Rent') {
        _mode = _ExploreMode.rent;
      } else if (selected == 'Land') {
        _mode = _ExploreMode.land;
      } else if (selected == 'Buy') {
        _mode = _ExploreMode.buy;
      }
      // else: For You / Verified => keep _mode as-is.
    });

    _refresh();
  }

  void _setSegment(_MarketSegment seg) {
    setState(() {
      _segment = seg;
      // NOTE: backend does not support commercial vs residential filtering yet.
      // When backend supports it, pass a category/segment param to fetchListings.
    });

    _refresh();
  }

  void _openSearch() => TenantNav.goToSearch(context);

  String _locationText({
    required String? city,
    required String? state,
    required String? country,
  }) {
    final parts = <String>[];
    if (city != null && city.trim().isNotEmpty) parts.add(city.trim());
    if (state != null && state.trim().isNotEmpty) parts.add(state.trim());

    final c = (country ?? '').trim();
    if (c.isNotEmpty) {
      parts.add(_countryName(c));
    } else if (parts.isEmpty) {
      parts.add('Location not set');
    }

    return parts.join(' • ');
  }

  String _countryName(String codeOrName) {
    final v = codeOrName.toUpperCase();
    if (v == 'NG') return 'Nigeria';
    if (v == 'US') return 'USA';
    if (v == 'GB') return 'UK';
    return codeOrName;
  }

  String _uiTypeFromPropertyType(String propertyType) {
    switch (propertyType) {
      case 'sale':
        return 'Buy';
      case 'rent':
      case 'short_lease':
      case 'long_lease':
        return 'Rent';
      default:
        return propertyType;
    }
  }

  // ✅ ListingModel.currency should be a CODE (NGN/USD/EUR), not a symbol.
  String _currencyCode(String? currency) {
    final c = (currency ?? 'NGN').toUpperCase();
    if (c.isEmpty) return 'NGN';
    return c;
  }

  ListingModel _toListingModel(MarketplaceItem x) {
    final location =
        _locationText(city: x.city, state: x.state, country: x.country);
    final uiType = _uiTypeFromPropertyType(x.propertyType);
    final code = _currencyCode(x.currency);

    return ListingModel(
      id: x.listingId,
      title: x.title,
      price: x.listedPrice,
      currency: code,
      location: location,
      status: x.status,
      beds: x.bedrooms,
      baths: x.bathrooms,
      type: uiType,
      mediaUrls: x.coverUrl != null ? [x.coverUrl!] : const [],
      propertyStatus: 'available',
      ownerName: 'RentEase',
      ownerId: 'system',
    );
  }

  bool _isVerifiedItem(MarketplaceItem x) {
    return x.verificationStatus.toLowerCase() == 'verified';
  }

  /// ✅ IMPORTANT: Explore should be able to display ALL backend listings.
  /// So we NEVER pass fake values like "__land__".
  ///
  /// - For You: types = null (show everything)
  /// - Buy: only sale
  /// - Rent: rent + leases
  /// - Land: types = null (until backend supports land properly)
  /// - Verified: verifiedOnly = true + types based on current mode
  List<String>? _typesForCurrentSelection() {
    final selected = _chips[_activeChip];

    // Verified respects current mode
    if (selected == 'Verified') {
      return _typesForMode(_mode);
    }

    // For You = show everything
    if (selected == 'For You') return null;

    if (selected == 'Buy') return const ['sale'];
    if (selected == 'Rent') return const ['rent', 'short_lease', 'long_lease'];

    // ✅ FIX: Land should NOT send "__land__" (it blocks backend results).
    // Until backend supports land as a property_type/category, show everything.
    if (selected == 'Land') return null;

    return null;
  }

  /// Types based on current mode (used by Verified chip)
  List<String>? _typesForMode(_ExploreMode m) {
    switch (m) {
      case _ExploreMode.buy:
        return const ['sale'];
      case _ExploreMode.rent:
        return const ['rent', 'short_lease', 'long_lease'];
      case _ExploreMode.land:
        // ✅ FIX: Land not supported yet => do not block results
        return null;
    }
  }

  bool get _verifiedOnly => _chips[_activeChip] == 'Verified';

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _loadingMore = false;
      _error = null;
      _offset = 0;
      _hasMore = true;
      _items.clear();
      _verifiedById.clear();
    });

    try {
      final types = _typesForCurrentSelection();

      final rows = await _api.fetchListings(
        types: types,
        verifiedOnly: _verifiedOnly,
        limit: _limit,
        offset: 0,
      );

      final mapped = <ListingModel>[];
      for (final x in rows) {
        mapped.add(_toListingModel(x));
        _verifiedById[x.listingId] = _isVerifiedItem(x);
      }

      setState(() {
        _items.addAll(mapped);
        _hasMore = rows.length >= _limit;
        _loading = false;
        _offset = 0;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;

    setState(() {
      _loadingMore = true;
      _error = null;
    });

    try {
      final nextOffset = _offset + _limit;

      final rows = await _api.fetchListings(
        types: _typesForCurrentSelection(),
        verifiedOnly: _verifiedOnly,
        limit: _limit,
        offset: nextOffset,
      );

      final mapped = <ListingModel>[];
      for (final x in rows) {
        mapped.add(_toListingModel(x));
        _verifiedById[x.listingId] = _isVerifiedItem(x);
      }

      setState(() {
        _offset = nextOffset;
        _items.addAll(mapped);
        _hasMore = rows.length >= _limit;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loadingMore = false;
      });
    }
  }

  void _openListing(ListingModel listing, {required String heroTag}) {
    final grad = AppColors.demoCardGradientA;
    final verified = _verifiedById[listing.id] ?? false;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(
          listing: listing,
          heroTag: heroTag,
          heroGradient: grad,
          isVerified: verified,
          priceLabelOverride: null,
        ),
      ),
    );
  }

  String _heroTag({
    required String section,
    required ListingModel listing,
    required int index,
  }) {
    return 'listingHero:explore:$section:${listing.id}:$index';
  }

  String get _activeTitle {
    if (_segment == _MarketSegment.commercial) return 'Commercial';
    return switch (_mode) {
      _ExploreMode.buy => 'Buy',
      _ExploreMode.rent => 'Rent',
      _ExploreMode.land => 'Land',
    };
  }

  @override
  Widget build(BuildContext context) {
    final featuredCount = _items.length < 6 ? _items.length : 6;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
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

            if (_loading && _items.isEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: CircularProgressIndicator(
                    color: AppColors.brandGreenDeep,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ] else if (_error != null && _items.isEmpty) ...[
              _ErrorBox(message: _error!, onRetry: _refresh),
            ] else if (_items.isEmpty) ...[
              _InfoBox(
                title: 'No listings found',
                message: 'Try another tab or remove Verified filter.',
                onAction: _refresh,
                actionText: 'Refresh',
              ),
            ] else ...[
              Text(
                'Featured',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary(context),
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),

              LayoutBuilder(
                builder: (context, constraints) {
                  final gap = AppSpacing.md.toDouble();
                  final viewport = constraints.maxWidth;

                  var cardW = (viewport - gap) / 2;
                  cardW = cardW.clamp(
                    AppSizes.featuredCardMinW,
                    AppSizes.featuredCardMaxW,
                  );

                  final cardH = cardW * AppSizes.featuredCardAspect;
                  final rowH = cardH + AppSpacing.lg;

                  return SizedBox(
                    height: rowH,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: featuredCount,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.md),
                      itemBuilder: (context, i) {
                        final listing = _items[i];
                        final priceText = fmtMoneyCompact(
                          listing.price,
                          currencyCode: listing.currency,
                        );

                        final heroTag = _heroTag(
                          section: 'featured',
                          listing: listing,
                          index: i,
                        );

                        final verified = _verifiedById[listing.id] ?? false;
                        final badge = verified ? 'Verified' : 'Hot';

                        return _FeaturedCard(
                          width: cardW,
                          height: cardH,
                          heroTag: heroTag,
                          title: listing.title,
                          location: listing.location,
                          price: priceText,
                          badge: badge,
                          gradient: AppColors.demoCardGradientA,
                          onTap: () => _openListing(listing, heroTag: heroTag),
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
                  TextButton(
                    onPressed: _hasMore ? _loadMore : null,
                    child: Text(
                      _loadingMore
                          ? 'Loading…'
                          : (_hasMore ? 'Load more  ›' : 'No more'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              if (_error != null) ...[
                _InlineError(text: _error!),
                const SizedBox(height: AppSpacing.sm),
              ],

              // ✅ SavedStore is the source of truth for hearts
              ListenableBuilder(
                listenable: SavedStore.I,
                builder: (context, _) {
                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) {
                      final listing = _items[i];

                      final meta =
                          (listing.beds == null && listing.baths == null)
                              ? 'Details not set'
                              : '${listing.beds ?? 0} Beds • ${listing.baths ?? 0} Baths';

                      final priceText = fmtMoneyCompact(
                        listing.price,
                        currencyCode: listing.currency,
                      );

                      final heroTag = _heroTag(
                        section: 'nearby',
                        listing: listing,
                        index: i,
                      );

                      final isSaved = SavedStore.I.isSaved(listing);

                      return _ListingRowCard(
                        heroTag: heroTag,
                        title: listing.title,
                        location: listing.location,
                        price: priceText,
                        meta: meta,
                        onTap: () => _openListing(listing, heroTag: heroTag),
                        onToggleSaved: () => SavedStore.I.toggle(listing),
                        isSaved: isSaved,
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),
              if (_hasMore) ...[
                Center(
                  child: FilledButton(
                    onPressed: _loadingMore ? null : _loadMore,
                    child: Text(_loadingMore ? 'Loading…' : 'Load more'),
                  ),
                ),
              ],
            ],

            const SizedBox(height: AppSpacing.lg),
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
          color: AppColors.surface(context).withValues(alpha: alphaSurfaceStrong),
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
              alpha: AppSpacing.xs / AppSpacing.xxxl,
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
                            color: AppColors.white.withValues(alpha: 0.85),
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
                        color: AppColors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(AppRadii.button),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.20),
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
                  color: AppColors.brandBlueSoft.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(color: AppColors.overlay(context, alphaBorder)),
                ),
                child: const Icon(Icons.home_rounded, color: AppColors.brandBlueSoft),
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
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted(context),
                ),
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
            'Could not load listings',
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

class _InlineError extends StatelessWidget {
  const _InlineError({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.danger,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}