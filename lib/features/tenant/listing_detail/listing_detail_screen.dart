// lib/features/tenant/listing_detail/listing_detail_screen.dart
// ignore_for_file: dead_code, dead_null_aware_expression, unnecessary_non_null_assertion, unnecessary_null_comparison

import 'package:flutter/material.dart';

// ✅ Shared booking screen (same folder)
import 'schedule_visit_screen.dart';

// ✅ Apply flow
import '../applications/apply_flow_screens.dart' show ApplyPreCheckScreen;
import '../../../shared/models/application_form_models.dart' show ApplyListingVM;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';

import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/utils/money_format.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/stores/saved_store.dart';
import '../../../shared/widgets/secondary_button.dart';

enum ListingKind { buy, rent, land, commercial }

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({
    super.key,
    required this.listing,
    required this.heroTag,
    this.heroGradient,
    this.isVerified = false,
    this.priceLabelOverride,
  });

  final ListingModel listing;
  final String heroTag;
  final Gradient? heroGradient;
  final bool isVerified;

  /// Optional (useful for demo rent/commercial “/yr” labels)
  final String? priceLabelOverride;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final PageController _page = PageController();
  int _pageIndex = 0;

  ListingKind get _kind {
    final t = (widget.listing.type ?? '').toString().toLowerCase();
    if (t.contains('rent')) return ListingKind.rent;
    if (t.contains('land')) return ListingKind.land;
    if (t.contains('commercial')) return ListingKind.commercial;
    if (t.contains('buy')) return ListingKind.buy;
    return ListingKind.buy;
  }

  // ✅ Map listing kind -> VisitType (shared booking screen)
  VisitType get _visitType {
    switch (_kind) {
      case ListingKind.rent:
        return VisitType.rent;
      case ListingKind.buy:
        return VisitType.buy;
      case ListingKind.land:
        return VisitType.land;
      case ListingKind.commercial:
        return VisitType.commercial;
    }
  }

  String get _primaryAction {
    switch (_kind) {
      case ListingKind.rent:
        return 'Schedule Viewing';
      case ListingKind.buy:
        return 'Request Inspection';
      case ListingKind.land:
        return 'Request Inspection';
      case ListingKind.commercial:
        return 'Schedule Tour';
    }
  }

  bool get _showSecondaryRentApply => _kind == ListingKind.rent;

  /// ✅ Use listing currency code (NGN/USD/EUR...) instead of forcing NGN.
  String get _priceText {
    final override = widget.priceLabelOverride;
    if (override != null && override.trim().isNotEmpty) return override;

    return fmtMoneyCompact(
      widget.listing.price,
      currencyCode: widget.listing.currency,
    );
  }

  List<String> get _media {
    final urls = widget.listing.mediaUrls;
    return urls.where((e) => e.trim().isNotEmpty).toList();
  }

  /// ✅ Pull amenities from backend (ListingModel must carry it)
  List<String> get _amenities {
    try {
      final dynamic any = widget.listing;
      final v = any.amenities;
      if (v is List) {
        return v
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  /// ✅ Pull description from backend (ListingModel must carry it)
  String get _description {
    try {
      final dynamic any = widget.listing;
      final v = any.description;
      if (v is String) return v.trim();
    } catch (_) {}
    return '';
  }

  // ✅ IMPORTANT:
  // Backend requires property_listings.id as listingId.
  // We try listing.listingId if it exists; otherwise fallback to listing.id.
  String _safeListingId() {
    try {
      final dynamic any = widget.listing;
      final v = any.listingId;
      if (v is String && v.trim().isNotEmpty) return v.trim();
    } catch (_) {}
    return widget.listing.id.trim();
  }

  // ✅ Property id (if you have it). If not available yet, we safely fallback to listingId.
  String _safePropertyId({required String fallbackListingId}) {
    try {
      final dynamic any = widget.listing;
      final v = any.propertyId ?? any.property_id ?? any.propertyID;
      if (v is String && v.trim().isNotEmpty) return v.trim();
      if (v != null) {
        final s = v.toString().trim();
        if (s.isNotEmpty) return s;
      }
    } catch (_) {}
    return fallbackListingId;
  }

  int _priceToIntNgn() {
    final p = widget.listing.price;
    if (p == null) return 0;
    if (p is int) return p;
    if (p is double) return p.round();
    final s = p.toString();
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  // ✅ Open shared booking screen (ScheduleVisitScreen)
  void _openBooking() {
    final title = widget.listing.title.trim();
    final location = widget.listing.location.trim();

    // ✅ Cover image (first media)
    final cover = _media.isNotEmpty ? _media.first.trim() : '';
    final isAsset = cover.startsWith('assets/');
    final isUrl = cover.startsWith('http://') || cover.startsWith('https://');

    final listingId = _safeListingId().trim();

    // If listingId is empty somehow, do nothing (avoid sending bad request)
    if (listingId.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScheduleVisitScreen(
          visitType: _visitType,
          listing: VisitListingCardVM(
            title: title.isEmpty ? 'Listing' : title,
            location: location.isEmpty ? 'Location' : location,
            priceLine: _priceText,
            photoAssetPath: isAsset ? cover : null,
            photoUrl: isUrl ? cover : null,
            locationTitle: location.isEmpty ? 'Location' : location,
            addressLine: location.isEmpty ? 'Open in Maps to view address' : location,

            // ✅ REQUIRED by booking + backend
            listingId: listingId,

            // ✅ Optional now (backend derives propertyId)
            propertyId: "",
          ),
          instantBooking: false,
        ),
      ),
    );
  }

  // ✅ APPLY NOW (Rent only) -> Apply flow
  void _openApplyNow() {
    if (_kind != ListingKind.rent) return;

    final listingId = _safeListingId().trim();
    if (listingId.isEmpty) return;

    final propertyId = _safePropertyId(fallbackListingId: listingId);

    final title = widget.listing.title.trim().isEmpty ? "Listing" : widget.listing.title.trim();
    final location =
        widget.listing.location.trim().isEmpty ? "Location" : widget.listing.location.trim();

    // ✅ Use actual rent price (numeric) if you have it, else parse from UI text
    final rentNgn = _priceToIntNgn();

    // ✅ For ApplyListingVM, we keep priceText as your formatted price line
    final priceText = _priceText.trim().isEmpty ? "₦0" : _priceText.trim();

    // ✅ Cover image -> ApplyListingVM expects ASSET path only (so use it if it’s an asset).
    final cover = _media.isNotEmpty ? _media.first.trim() : '';
    final photoAssetPath = cover.startsWith('assets/') ? cover : null;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ApplyPreCheckScreen(
          listing: ApplyListingVM(
            listingId: listingId,
            propertyId: propertyId,
            title: title,
            location: location,
            rentPerMonthNgn: rentNgn,
            priceText: priceText,
            photoAssetPath: photoAssetPath,
          ),
          guarantorRequiredThresholdNgn: 500000,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    // ✅ If no media, still show 1 placeholder page
    final galleryTotal = _media.isEmpty ? 1 : _media.length;

    final galleryGradient = widget.heroGradient ?? AppColors.demoCardGradientA;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.pageBgGradient(context),
            ),
          ),
        ),
        AppScaffold(
          backgroundColor: Colors.transparent,
          safeAreaTop: false,
          safeAreaBottom: false,
          scroll: false,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ListenableBuilder(
                      listenable: SavedStore.I,
                      builder: (context, _) {
                        final isSaved = SavedStore.I.isSaved(widget.listing);

                        return _GalleryHeader(
                          topPad: topPad,
                          heroTag: widget.heroTag,
                          gradient: galleryGradient,
                          isVerified: widget.isVerified,
                          isSaved: isSaved,
                          index: _pageIndex,
                          total: galleryTotal,
                          controller: _page,
                          mediaUrls: _media,
                          onPageChanged: (i) => setState(() => _pageIndex = i),
                          onBack: () => Navigator.of(context).maybePop(),
                          onShare: () {},
                          onToggleSave: () => SavedStore.I.toggle(widget.listing),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenH,
                        AppSpacing.lg,
                        AppSpacing.screenH,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PriceInfoCard(
                            kind: _kind,
                            title: widget.listing.title.trim().isEmpty
                                ? 'Listing'
                                : widget.listing.title.trim(),
                            location: widget.listing.location.trim(),
                            priceText: _priceText,
                            beds: widget.listing.beds,
                            baths: widget.listing.baths,
                            sizeLabel: _kind == ListingKind.commercial ? 'Size' : 'Sqft',
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          _SectionTitle(title: 'Overview'),
                          const SizedBox(height: AppSpacing.sm),
                          _SurfaceCard(
                            child: _ExpandableText(
                              text: _description,
                              emptyFallback: 'No description yet.',
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),
                          _SectionTitle(title: 'Features / Amenities'),
                          const SizedBox(height: AppSpacing.sm),
                          _FeatureGrid(items: _amenities),

                          const SizedBox(height: AppSpacing.lg),
                          _SectionTitle(title: 'Location'),
                          const SizedBox(height: AppSpacing.sm),
                          _LocationCard(
                            address: widget.listing.location.trim(),
                            onOpenMaps: () {},
                          ),

                          const SizedBox(height: AppSpacing.lg),
                          _SectionTitle(title: 'Agent / Landlord'),
                          const SizedBox(height: AppSpacing.sm),
                          _AgentCard(
                            name: (widget.listing.ownerName ?? '').trim().isEmpty
                                ? 'Agent'
                                : (widget.listing.ownerName ?? '').trim(),
                            verified: false,
                            onMessage: () {},
                            onCall: () {},
                          ),

                          const SizedBox(height: AppSpacing.lg),
                          _SectionTitle(title: 'Fees / Payment info'),
                          const SizedBox(height: AppSpacing.sm),
                          _FeesCard(kind: _kind),

                          const SizedBox(height: AppSpacing.lg),
                          _SectionTitle(title: 'Similar listings'),
                          const SizedBox(height: AppSpacing.sm),
                          _SimilarRow(onTap: () {}),

                          const SizedBox(height: AppSizes.screenBottomPad),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _StickyActions(
                  primaryText: _primaryAction,
                  showSecondaryRentApply: _showSecondaryRentApply,
                  onMessage: () {},
                  onCall: () {},
                  onPrimary: _openBooking,

                  // ✅ APPLY NOW wired to Apply flow
                  onSecondary: _openApplyNow,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------- Header ----------------

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader({
    required this.topPad,
    required this.heroTag,
    required this.gradient,
    required this.isVerified,
    required this.isSaved,
    required this.index,
    required this.total,
    required this.controller,
    required this.mediaUrls,
    required this.onPageChanged,
    required this.onBack,
    required this.onShare,
    required this.onToggleSave,
  });

  final double topPad;
  final String heroTag;
  final Gradient gradient;
  final bool isVerified;
  final bool isSaved;
  final int index;
  final int total;
  final PageController controller;
  final List<String> mediaUrls;
  final ValueChanged<int> onPageChanged;

  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onToggleSave;

  double get _alphaBtnSurface => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);
  double get _alphaBtnBorder => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  Widget build(BuildContext context) {
    final headerH =
        (MediaQuery.of(context).size.width * AppSizes.featuredCardAspect) + (AppSpacing.xxxl + AppSpacing.lg);

    final countText = '${(index + 1).clamp(1, total)}/$total';

    return SizedBox(
      height: headerH,
      child: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadii.xl),
                  bottomRight: Radius.circular(AppRadii.xl),
                ),
                child: _GalleryBody(
                  gradient: gradient,
                  controller: controller,
                  mediaUrls: mediaUrls,
                  total: total,
                  onPageChanged: onPageChanged,
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.screenH,
            right: AppSpacing.screenH,
            top: topPad + AppSpacing.md,
            child: Row(
              children: [
                _CircleIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: onBack,
                  alphaSurface: _alphaBtnSurface,
                  alphaBorder: _alphaBtnBorder,
                ),
                const Spacer(),
                _CircleIconButton(
                  icon: Icons.ios_share_rounded,
                  onTap: onShare,
                  alphaSurface: _alphaBtnSurface,
                  alphaBorder: _alphaBtnBorder,
                ),
                const SizedBox(width: AppSpacing.sm),
                _CircleIconButton(
                  icon: isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  onTap: onToggleSave,
                  alphaSurface: _alphaBtnSurface,
                  alphaBorder: _alphaBtnBorder,
                ),
              ],
            ),
          ),
          Positioned(
            left: AppSpacing.screenH,
            right: AppSpacing.screenH,
            bottom: AppSpacing.md,
            child: Row(
              children: [
                if (isVerified)
                  const _GlassPill(
                    text: 'Verified',
                    icon: Icons.verified_rounded,
                  ),
                const Spacer(),
                _GlassPill(text: countText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryBody extends StatelessWidget {
  const _GalleryBody({
    required this.gradient,
    required this.controller,
    required this.mediaUrls,
    required this.total,
    required this.onPageChanged,
  });

  final Gradient gradient;
  final PageController controller;
  final List<String> mediaUrls;
  final int total;
  final ValueChanged<int> onPageChanged;

  bool _isUrl(String s) => s.startsWith('http://') || s.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(decoration: BoxDecoration(gradient: gradient)),
        ),
        Positioned.fill(
          child: PageView.builder(
            controller: controller,
            itemCount: total,
            onPageChanged: onPageChanged,
            itemBuilder: (context, i) {
              final path = (i < mediaUrls.length) ? mediaUrls[i].trim() : '';
              if (path.isEmpty) return _GalleryPlaceholder(index: i);

              if (path.startsWith('assets/')) {
                return Image.asset(path, fit: BoxFit.cover);
              }

              if (_isUrl(path)) {
                return Image.network(
                  path,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return _GalleryPlaceholder(index: i);
                  },
                  errorBuilder: (_, __, ___) => _GalleryPlaceholder(index: i),
                );
              }

              return _GalleryPlaceholder(index: i);
            },
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: AppSpacing.xs / AppSpacing.xxxl),
                  Colors.transparent,
                  Colors.black.withValues(alpha: AppSpacing.sm / AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GalleryPlaceholder extends StatelessWidget {
  const _GalleryPlaceholder({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final iconA = AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: iconA),
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.white.withValues(alpha: iconA)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_rounded, color: AppColors.white),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Gallery',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Main cards / sections / sticky actions ----------------

class _PriceInfoCard extends StatelessWidget {
  const _PriceInfoCard({
    required this.kind,
    required this.title,
    required this.location,
    required this.priceText,
    required this.beds,
    required this.baths,
    required this.sizeLabel,
  });

  final ListingKind kind;
  final String title;
  final String location;
  final String priceText;
  final int? beds;
  final int? baths;
  final String sizeLabel;

  @override
  Widget build(BuildContext context) {
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
    final showBedsBaths = (kind == ListingKind.buy || kind == ListingKind.rent);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: alphaSurface),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.overlay(context, alphaBorder)),
        boxShadow: AppShadows.lift(
          context,
          blur: AppSpacing.xxxl + AppSpacing.lg,
          y: AppSpacing.xl,
          alpha: AppSpacing.xs / AppSpacing.xxxl,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            priceText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.brandGreenDeep,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary(context),
                ),
          ),
          const SizedBox(height: AppSpacing.s2),
          if (location.isNotEmpty)
            Text(
              location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (showBedsBaths) _MiniChip(icon: Icons.bed_rounded, text: '${beds ?? 0} Beds'),
              if (showBedsBaths)
                _MiniChip(icon: Icons.bathtub_rounded, text: '${baths ?? 0} Baths'),
              _MiniChip(icon: Icons.square_foot_rounded, text: sizeLabel),
              if (kind == ListingKind.land)
                const _MiniChip(icon: Icons.description_rounded, text: 'Title docs'),
              if (kind == ListingKind.rent)
                const _MiniChip(icon: Icons.receipt_long_rounded, text: 'Deposit & fees'),
              if (kind == ListingKind.commercial)
                const _MiniChip(icon: Icons.apartment_rounded, text: 'Commercial'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final alphaSurface = AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.overlay(context, alphaSurface),
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: AppColors.overlay(context, alphaSurface)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSpacing.xl - AppSpacing.s2, color: AppColors.textPrimary(context)),
          const SizedBox(width: AppSpacing.sm),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
            color: AppColors.textPrimary(context),
          ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: alphaSurface),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.overlay(context, alphaBorder)),
        boxShadow: AppShadows.soft(
          context,
          blur: AppSpacing.xxxl,
          y: AppSpacing.xl,
          alpha: AppSpacing.xs / AppSpacing.xxxl,
        ),
      ),
      child: child,
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText({required this.text, required this.emptyFallback});
  final String text;
  final String emptyFallback;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasText = widget.text.trim().isNotEmpty;
    final text = hasText ? widget.text.trim() : widget.emptyFallback;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: _expanded ? null : AppSpacing.s6.toInt(),
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(AppRadii.chip),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            child: Text(
              _expanded ? 'Read less' : 'Read more',
              style: const TextStyle(
                color: AppColors.brandBlue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _SurfaceCard(
        child: Text(
          'No amenities yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w700,
              ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final minTileW = AppSizes.featuredCardMinW / AppSpacing.s2;
        final cols = (c.maxWidth / minTileW).floor().clamp(2, 3);
        final gap = AppSpacing.sm.toDouble();

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items.map((t) {
            final w = (c.maxWidth - (gap * (cols - 1))) / cols;
            return SizedBox(
              width: w,
              child: _SurfaceCard(
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.success, size: AppSpacing.xl),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        t,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.address, required this.onOpenMaps});
  final String address;
  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: AppSizes.listThumbSize * (AppSpacing.lg / AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.overlay(context, AppSpacing.sm / AppSpacing.xxxl),
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: AppColors.overlay(context, AppSpacing.xs / AppSpacing.xxxl)),
            ),
            child: Center(
              child: Icon(
                Icons.map_rounded,
                color: AppColors.textMuted(context),
                size: AppSpacing.xxxl,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            address.isEmpty ? 'Address not available' : address,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onOpenMaps,
              child: const Text('Open in Maps'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  const _AgentCard({
    required this.name,
    required this.verified,
    required this.onMessage,
    required this.onCall,
  });

  final String name;
  final bool verified;
  final VoidCallback onMessage;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: [
          Container(
            height: AppSizes.listThumbSize,
            width: AppSizes.listThumbSize,
            decoration: BoxDecoration(
              color: AppColors.brandBlueSoft.withValues(
                alpha: AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md),
              ),
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: AppColors.overlay(context, AppSpacing.xs / AppSpacing.xxxl)),
            ),
            child: Icon(Icons.person_rounded, color: AppColors.textPrimary(context)),
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
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary(context),
                            ),
                      ),
                    ),
                    if (verified) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Icon(Icons.verified_rounded, color: AppColors.info, size: AppSpacing.xl),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  verified ? 'Verified' : 'Agent',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted(context),
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _SmallAction(icon: Icons.chat_bubble_rounded, onTap: onMessage),
          const SizedBox(width: AppSpacing.sm),
          _SmallAction(icon: Icons.call_rounded, onTap: onCall),
        ],
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alpha = AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        height: AppSizes.iconButtonBox,
        width: AppSizes.iconButtonBox,
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: alpha),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.overlay(context, AppSpacing.xs / AppSpacing.xxxl)),
        ),
        child: Icon(icon, color: AppColors.textPrimary(context)),
      ),
    );
  }
}

class _FeesCard extends StatelessWidget {
  const _FeesCard({required this.kind});
  final ListingKind kind;

  @override
  Widget build(BuildContext context) {
    final rows = <_FeeRowData>[
      if (kind == ListingKind.rent) const _FeeRowData('Deposit', 'See breakdown'),
      if (kind == ListingKind.rent) const _FeeRowData('Agency / Legal', 'See breakdown'),
      if (kind == ListingKind.buy) const _FeeRowData('Escrow', 'Protected checkout'),
      if (kind == ListingKind.buy) const _FeeRowData('Inspection', 'Schedule with agent'),
      if (kind == ListingKind.land) const _FeeRowData('Documents', 'Survey / C of O'),
      if (kind == ListingKind.land) const _FeeRowData('Inspection', 'Request inspection'),
      if (kind == ListingKind.commercial) const _FeeRowData('Lease terms', 'Request details'),
      if (kind == ListingKind.commercial) const _FeeRowData('Service charge', 'Request details'),
    ];

    return _SurfaceCard(
      child: Column(
        children: rows
            .map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.label,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      r.value,
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(Icons.chevron_right_rounded, color: AppColors.textMuted(context)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _FeeRowData {
  const _FeeRowData(this.label, this.value);
  final String label;
  final String value;
}

class _SimilarRow extends StatelessWidget {
  const _SimilarRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: [
          Icon(Icons.view_carousel_rounded, color: AppColors.textMuted(context)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Similar listings will appear here.',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted(context)),
        ],
      ),
    );
  }
}

// ---------------- Sticky actions ----------------

class _StickyActions extends StatelessWidget {
  const _StickyActions({
    required this.primaryText,
    required this.showSecondaryRentApply,
    required this.onMessage,
    required this.onCall,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String primaryText;
  final bool showSecondaryRentApply;

  final VoidCallback onMessage;
  final VoidCallback onCall;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.md,
          AppSpacing.screenH,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: alphaSurface),
          border: Border(top: BorderSide(color: AppColors.overlay(context, alphaBorder))),
          boxShadow: AppShadows.soft(
            context,
            blur: AppSpacing.xxxl,
            y: -AppSpacing.s2.toDouble(),
            alpha: AppSpacing.xs / AppSpacing.xxxl,
          ),
        ),
        child: Row(
          children: [
            _StickyIcon(icon: Icons.chat_bubble_rounded, onTap: onMessage),
            const SizedBox(width: AppSpacing.sm),
            _StickyIcon(icon: Icons.call_rounded, onTap: onCall),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _PrimaryActionButton(
                label: primaryText,
                onTap: onPrimary,
              ),
            ),
            if (showSecondaryRentApply) ...[
              const SizedBox(width: 12),
              SecondaryButton(
                label: 'Apply Now',
                onPressed: onSecondary, // ✅ now wired
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alphaFill = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

    return Material(
      color: AppColors.brandGreenDeep.withValues(alpha: alphaFill),
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: SizedBox(
          height: AppSizes.pillButtonHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StickyIcon extends StatelessWidget {
  const _StickyIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final a = AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        height: AppSizes.iconButtonBox,
        width: AppSizes.iconButtonBox,
        decoration: BoxDecoration(
          color: AppColors.overlay(context, a),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.overlay(context, AppSpacing.xs / AppSpacing.xxxl)),
        ),
        child: Icon(icon, color: AppColors.textPrimary(context)),
      ),
    );
  }
}

// ---------------- small UI helpers ----------------

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.alphaSurface,
    required this.alphaBorder,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double alphaSurface;
  final double alphaBorder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        height: AppSizes.iconButtonBox,
        width: AppSizes.iconButtonBox,
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: alphaSurface),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.overlay(context, alphaBorder)),
        ),
        child: Icon(icon, color: AppColors.white),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.text, this.icon});
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final a = AppSpacing.sm / (AppSpacing.xxxl + AppSpacing.sm);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: a),
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: AppColors.white.withValues(alpha: a)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSpacing.xl, color: AppColors.white),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            text,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}