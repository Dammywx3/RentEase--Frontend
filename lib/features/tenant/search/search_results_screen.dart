import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/config/env.dart';
import '../../../core/network/marketplace_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../core/utils/money_format.dart';

import '../../../shared/models/listing_model.dart';
import '../../../shared/stores/saved_store.dart';
import '../listing_detail/listing_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({
    super.key,
    required this.title,
    required this.summary,
    required this.filters,
  });

  final String title;
  final String summary; // kept for compatibility
  final Map<String, dynamic> filters;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late final MarketplaceApi _api = MarketplaceApi(baseUrl: Env.baseUrl);

  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);
  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  final List<ListingModel> _items = <ListingModel>[];
  final Map<String, bool> _verifiedById = <String, bool>{};

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _offset = 0;
  static const int _limit = 20;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  // ----------------- helpers -----------------

  num? _asNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  String _modeLabel(String? mode) {
    final m = (mode ?? '').toLowerCase().trim();
    if (m.isEmpty) return 'buy';
    if (m == 'buy') return 'buy';
    if (m == 'rent') return 'rent';
    if (m == 'land') return 'land';
    return m;
  }

  String _locationLabel(String? query) {
    final q = (query ?? '').trim();
    return q.isEmpty ? 'Any location' : q;
  }

  // ✅ fixed comma formatting
  String _fmtNaira(num v) {
    final s = v.toInt().toString();
    final chars = s.split('');
    final out = <String>[];
    for (int i = 0; i < chars.length; i++) {
      out.add(chars[i]);
      final left = chars.length - i - 1;
      if (left > 0 && left % 3 == 0) out.add(',');
    }
    return '₦${out.join()}';
  }

  String _rangeLabel(num? min, num? max) {
    final a = min ?? 0;
    final b = max ?? 0;
    if (a <= 0 && b <= 0) return 'Any budget';
    if (a > 0 && b <= 0) return '${_fmtNaira(a)}+';
    if (a <= 0 && b > 0) return 'Up to ${_fmtNaira(b)}';
    return '${_fmtNaira(a)} – ${_fmtNaira(b)}';
  }

  bool _verifiedOnlyFromFilters() {
    final v = widget.filters['verified'];
    if (v is bool) return v;
    if (v is String) return v.toLowerCase().trim() == 'true';
    return false;
  }

  String _categoryFromFilters() {
    final cat = (widget.filters['category'] ?? '').toString().trim();
    if (cat.isNotEmpty) return cat;

    final pt = widget.filters['propertyTab'];
    if (pt is int) {
      return switch (pt) {
        0 => 'Residential',
        1 => 'Commercial',
        2 => 'Land',
        _ => 'Residential',
      };
    }
    return 'Residential';
  }

  /// DB uses `properties.type` = rent|sale|short_lease|long_lease
  List<String>? _typesFromFilters() {
    final mode = _modeLabel(widget.filters['mode']?.toString());

    if (mode == 'rent') return const ['rent', 'short_lease', 'long_lease'];
    if (mode == 'buy') return const ['sale'];

    // Land not supported in enum yet -> don't block results
    if (mode == 'land') return null;

    return null;
  }

  /// ✅ LOCAL FALLBACK FILTERING for query/location
  List<MarketplaceItem> _applyLocalQueryFilter(List<MarketplaceItem> rows) {
    final q = (widget.filters['query'] ?? '').toString().trim().toLowerCase();
    if (q.isEmpty) return rows;

    bool matches(MarketplaceItem x) {
      final hay = <String>[
        x.title,
        x.city ?? '',
        x.state ?? '',
        x.country ?? '',
        x.propertyType,
        x.kind,
      ].join(' ').toLowerCase();
      return hay.contains(q);
    }

    return rows.where(matches).toList();
  }

  // -------- mapping MarketplaceItem -> ListingModel --------

  String _countryName(String codeOrName) {
    final v = codeOrName.toUpperCase();
    if (v == 'NG') return 'Nigeria';
    if (v == 'US') return 'USA';
    if (v == 'GB') return 'UK';
    return codeOrName;
  }

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

  String _currencyCode(String? currency) {
    final c = (currency ?? 'NGN').toUpperCase();
    if (c.isEmpty) return 'NGN';
    return c;
  }

  bool _isVerifiedItem(MarketplaceItem x) {
    return x.verificationStatus.toLowerCase() == 'verified';
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

  // ----------------- SAVED (REAL) -----------------

  bool _isSavedId(String id) {
    return SavedStore.I.savedListings.any((x) => x.id == id);
  }

  void _toggleSavedListing(ListingModel listing) {
    SavedStore.I.toggle(listing);
  }

  // ----------------- FETCHING -----------------

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
      final rowsRaw = await _api.fetchListings(
        types: _typesFromFilters(),
        verifiedOnly: _verifiedOnlyFromFilters(),
        limit: _limit,
        offset: 0,

        // ✅ pass filters down
        queryText: widget.filters['query']?.toString(),
        mode: widget.filters['mode']?.toString(),
        category: widget.filters['category']?.toString(),
        min: _asNum(widget.filters['min'])?.toInt(),
        max: _asNum(widget.filters['max'])?.toInt(),
        beds: _asInt(widget.filters['beds']),
        baths: _asInt(widget.filters['baths']),
        plotMinSqft: _asInt(widget.filters['plotMinSqft']),
      );

      final rows = _applyLocalQueryFilter(rowsRaw);

      final mapped = <ListingModel>[];
      for (final x in rows) {
        mapped.add(_toListingModel(x));
        _verifiedById[x.listingId] = _isVerifiedItem(x);
      }

      setState(() {
        _items.addAll(mapped);
        _hasMore = rowsRaw.length >= _limit;
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

      final rowsRaw = await _api.fetchListings(
        types: _typesFromFilters(),
        verifiedOnly: _verifiedOnlyFromFilters(),
        limit: _limit,
        offset: nextOffset,

        // ✅ pass filters down
        queryText: widget.filters['query']?.toString(),
        mode: widget.filters['mode']?.toString(),
        category: widget.filters['category']?.toString(),
        min: _asNum(widget.filters['min'])?.toInt(),
        max: _asNum(widget.filters['max'])?.toInt(),
        beds: _asInt(widget.filters['beds']),
        baths: _asInt(widget.filters['baths']),
        plotMinSqft: _asInt(widget.filters['plotMinSqft']),
      );

      final rows = _applyLocalQueryFilter(rowsRaw);

      final mapped = <ListingModel>[];
      for (final x in rows) {
        mapped.add(_toListingModel(x));
        _verifiedById[x.listingId] = _isVerifiedItem(x);
      }

      setState(() {
        _offset = nextOffset;
        _items.addAll(mapped);
        _hasMore = rowsRaw.length >= _limit;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loadingMore = false;
      });
    }
  }

  // ----------------- navigation -----------------

  String _heroTag({
    required String section,
    required ListingModel listing,
    required int index,
  }) {
    return 'listingHero:search:$section:${listing.id}:$index';
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

  // ----------------- UI derived -----------------

  String get _subtitle {
    final mode = _modeLabel(widget.filters['mode']?.toString());
    final loc = _locationLabel(widget.filters['query']?.toString());
    final min = _asNum(widget.filters['min']);
    final max = _asNum(widget.filters['max']);
    return '$mode • $loc • ${_rangeLabel(min, max)}';
  }

  List<_FilterRow> _prettyFilters() {
    final rows = <_FilterRow>[];

    final mode = _modeLabel(widget.filters['mode']?.toString());
    final loc = _locationLabel(widget.filters['query']?.toString());
    final min = _asNum(widget.filters['min']);
    final max = _asNum(widget.filters['max']);

    rows.add(_FilterRow('Mode', mode));
    rows.add(_FilterRow('Location', loc));
    rows.add(_FilterRow('Budget', _rangeLabel(min, max)));

    final beds = widget.filters['beds'];
    if (beds != null) rows.add(_FilterRow('Min beds', '$beds'));

    final baths = widget.filters['baths'];
    if (baths != null) rows.add(_FilterRow('Min baths', '$baths'));

    final plot = widget.filters['plotMinSqft'];
    if (plot != null) rows.add(_FilterRow('Min plot', '$plot sqft'));

    if (kDebugMode) {
      final pt = widget.filters['propertyTab'];
      if (pt != null) rows.add(_FilterRow('propertyTab (debug)', '$pt'));
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ rebuild whenever saved changes
    return AnimatedBuilder(
      animation: SavedStore.I,
      builder: (_, __) {
        final category = _categoryFromFilters();
        final verifiedOnly = _verifiedOnlyFromFilters();
        final pretty = _prettyFilters();

        return DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
          child: AppScaffold(
            backgroundColor: Colors.transparent,
            safeAreaTop: true,
            safeAreaBottom: false,
            appBar: AppTopBar(
              title: widget.title,
              subtitle: _subtitle,
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).maybePop(),
              actions: const [],
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

                Text(
                  'Search results',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary(context),
                      ),
                ),
                const SizedBox(height: AppSpacing.s6),
                Text(
                  _subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted(context),
                      ),
                ),

                const SizedBox(height: AppSpacing.md),

                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _ChipPill(
                      text: category,
                      filled: false,
                      alphaSurfaceStrong: _alphaSurfaceStrong,
                      alphaBorderSoft: _alphaBorderSoft,
                    ),
                    _ChipPill(
                      text: verifiedOnly ? 'Verified only' : 'All listings',
                      filled: verifiedOnly,
                      alphaSurfaceStrong: _alphaSurfaceStrong,
                      alphaBorderSoft: _alphaBorderSoft,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                _FiltersPreview(
                  rows: pretty,
                  alphaSurfaceStrong: _alphaSurfaceStrong,
                  alphaBorderSoft: _alphaBorderSoft,
                  alphaShadowSoft: _alphaShadowSoft,
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
                    message:
                        'Try changing Mode, Budget, or turning off Verified only.\n\nTip: Search text matches title/city/state/country.',
                    onAction: _refresh,
                    actionText: 'Refresh',
                  ),
                ] else ...[
                  Row(
                    children: [
                      Text(
                        'Results',
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

                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) {
                      final listing = _items[i];

                      final meta = (listing.beds == null && listing.baths == null)
                          ? 'Details not set'
                          : '${listing.beds ?? 0} Beds • ${listing.baths ?? 0} Baths';

                      final priceText = fmtMoneyCompact(
                        listing.price,
                        currencyCode: listing.currency,
                      );

                      final heroTag = _heroTag(
                        section: 'results',
                        listing: listing,
                        index: i,
                      );

                      final isSaved = _isSavedId(listing.id);

                      return _ListingRowCard(
                        heroTag: heroTag,
                        title: listing.title,
                        location: listing.location,
                        price: priceText,
                        meta: meta,
                        onTap: () => _openListing(listing, heroTag: heroTag),
                        onToggleSaved: () => _toggleSavedListing(listing),
                        isSaved: isSaved,
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
      },
    );
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill({
    required this.text,
    required this.filled,
    required this.alphaSurfaceStrong,
    required this.alphaBorderSoft,
  });

  final String text;
  final bool filled;
  final double alphaSurfaceStrong;
  final double alphaBorderSoft;

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? AppColors.brandGreenDeep.withValues(alpha: alphaSurfaceStrong)
        : AppColors.surface(context).withValues(alpha: alphaSurfaceStrong);

    final fg = filled ? AppColors.white : AppColors.textPrimary(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: AppColors.overlay(context, alphaBorderSoft)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FilterRow {
  const _FilterRow(this.label, this.value);
  final String label;
  final String value;
}

class _FiltersPreview extends StatelessWidget {
  const _FiltersPreview({
    required this.rows,
    required this.alphaSurfaceStrong,
    required this.alphaBorderSoft,
    required this.alphaShadowSoft,
  });

  final List<_FilterRow> rows;
  final double alphaSurfaceStrong;
  final double alphaBorderSoft;
  final double alphaShadowSoft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: alphaSurfaceStrong),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.overlay(context, alphaBorderSoft)),
        boxShadow: AppShadows.soft(
          context,
          blur: AppSpacing.xxxl,
          y: AppSpacing.lg,
          alpha: alphaShadowSoft,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applied filters',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary(context),
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (rows.isEmpty)
            Text(
              'No filters passed.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted(context),
                  ),
            )
          else
            ...rows.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textMuted(context),
                            ),
                      ),
                    ),
                    Text(
                      r.value,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.brandGreenDeep,
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
                  border: Border.all(
                    color: AppColors.overlay(context, alphaBorder),
                  ),
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
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary(context),
                              ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onToggleSaved,
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
            'Could not load results',
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