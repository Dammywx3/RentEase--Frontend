// ignore_for_file: unused_import, dead_code, dead_null_aware_expression, unnecessary_underscores

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/utils/money_format.dart';
import '../../../shared/models/listing_model.dart';

enum ListingKind { rent, buy, land, commercial }

ListingKind listingKindFromType(String? type) {
  final s = (type ?? '').toLowerCase();
  if (s.contains('rent')) return ListingKind.rent;
  if (s.contains('land')) return ListingKind.land;
  if (s.contains('comm')) return ListingKind.commercial;
  return ListingKind.buy;
}

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key, required this.listing, this.heroTag});

  final ListingModel listing;
  final String? heroTag;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late final ListingKind _kind = listingKindFromType(widget.listing.type);
  final PageController _page = PageController();
  int _pageIndex = 0;
  bool _saved = false;

  List<String> get _photos {
    final urls = widget.listing.mediaUrls;
    if (urls.isNotEmpty) return urls;

    // Fallback: keep compile-safe even if no images yet
    return const ['__fallback__'];
  }

  String get _badgeText {
    // If your model has flags later, map them here.
    // For now: use listing.status or propertyStatus as rough signal.
    final s = widget.listing.status.toLowerCase();
    if (s.contains('verified')) return 'Verified';
    return 'Featured';
  }

  bool get _showBadge {
    final s = widget.listing.status.toLowerCase();
    return s.contains('verified') || s.contains('featured');
  }

  String _priceText() {
    final price = widget.listing.price;
    if (_kind == ListingKind.rent) {
      // If you store "/yr" etc later, wire it. For now keep simple.
      return '${fmtNairaCompact(price)} /yr';
    }
    return fmtNairaCompact(price);
  }

  String _primaryCtaLabel() {
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

  String? _secondaryCtaLabel() {
    switch (_kind) {
      case ListingKind.rent:
        return 'Apply Now';
      case ListingKind.buy:
        return null; // optional later: "Make Offer"
      case ListingKind.land:
        return 'Request Documents';
      case ListingKind.commercial:
        return 'Contact Agent';
    }
  }

  void _onPrimaryCta() {
    // TODO: route to your real flows
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('TODO: ${_primaryCtaLabel()}')));
  }

  void _onSecondaryCta() {
    final label = _secondaryCtaLabel();
    if (label == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('TODO: $label')));
  }

  void _onMessage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('TODO: Message')));
  }

  void _onCall() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('TODO: Call')));
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;

    return AppScaffold(
      backgroundColor: Colors.transparent,
      safeAreaTop: false, // ✅ gallery should reach the top edge
      safeAreaBottom: false,
      scroll: false,
      padding: EdgeInsets.zero,

      // ✅ Use AppScaffold, but ListingDetails owns its header.
      child: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.pageBgGradient(context),
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _HeroGallery(
                    photos: _photos,
                    heroTag: widget.heroTag,
                    badgeText: _badgeText,
                    showBadge: _showBadge,
                    saved: _saved,
                    pageIndex: _pageIndex,
                    pageCount: _photos.length,
                    onBack: () => Navigator.of(context).maybePop(),
                    onToggleSaved: () => setState(() => _saved = !_saved),
                    onShare: () {},
                    controller: _page,
                    onPageChanged: (i) => setState(() => _pageIndex = i),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenH,
                      AppSpacing.md,
                      AppSpacing.screenH,
                      140, // ✅ leave space for sticky bar
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PriceKeyInfoCard(
                          kind: _kind,
                          title: listing.title,
                          location: listing.location,
                          priceText: _priceText(),
                          beds: listing.beds,
                          baths: listing.baths,
                          sizeLabel: _sizeLabelFallback(listing),
                          landTitleType: _landTitleTypeFallback(listing),
                          commercialType: _commercialTypeFallback(listing),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        _SectionTitle('Overview'),
                        const SizedBox(height: AppSpacing.sm),
                        _OverviewText(text: _overviewFallback(listing)),

                        const SizedBox(height: AppSpacing.lg),

                        _SectionTitle('Features / Amenities'),
                        const SizedBox(height: AppSpacing.sm),
                        _FeaturesGrid(items: _featuresFallback(listing)),

                        const SizedBox(height: AppSpacing.lg),

                        _SectionTitle('Location'),
                        const SizedBox(height: AppSpacing.sm),
                        _LocationCard(
                          address: listing.location,
                          onOpenMaps: () {},
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        _SectionTitle('Agent / Landlord'),
                        const SizedBox(height: AppSpacing.sm),
                        _AgentCard(
                          name: listing.ownerName ?? 'Verified Agent',
                          verified: true,
                          onChat: _onMessage,
                          onCall: _onCall,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        _SectionTitle('Fees / Payment Info'),
                        const SizedBox(height: AppSpacing.sm),
                        _FeesCard(kind: _kind),

                        const SizedBox(height: AppSpacing.lg),

                        _SectionTitle('Similar listings'),
                        const SizedBox(height: AppSpacing.sm),
                        _SimilarListingsRow(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Sticky bottom actions
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomActionsBar(
              primaryLabel: _primaryCtaLabel(),
              secondaryLabel: _secondaryCtaLabel(),
              onMessage: _onMessage,
              onCall: _onCall,
              onPrimary: _onPrimaryCta,
              onSecondary: _onSecondaryCta,
            ),
          ),

          // Optional: a slim top bar overlay ONLY if you want
          // (but your hero already has back/share/heart)
        ],
      ),
    );
  }

  String _overviewFallback(ListingModel l) {
    return 'A premium listing with modern finishing, great access roads, and secure environment. Tap Read more when we wire backend description.';
  }

  List<String> _featuresFallback(ListingModel l) {
    if (_kind == ListingKind.land) {
      return const [
        'Survey available',
        'Good access road',
        'Gated estate',
        'Dry land',
      ];
    }
    if (_kind == ListingKind.commercial) {
      return const ['Parking', 'Security', 'Generator', 'Elevator'];
    }
    return const [
      '24/7 Security',
      'Parking',
      'Water supply',
      'Balcony',
      'CCTV',
      'Generator',
    ];
  }

  String _sizeLabelFallback(ListingModel l) {
    // You can map sqft from real field later.
    if (_kind == ListingKind.land) return 'Plot size • 500sqm';
    if (_kind == ListingKind.commercial) return 'Size • 320sqm';
    return 'Size • 1,800 sqft';
  }

  String _landTitleTypeFallback(ListingModel l) {
    return 'Title: C of O';
  }

  String _commercialTypeFallback(ListingModel l) {
    return 'Type: Office space';
  }
}

class _HeroGallery extends StatelessWidget {
  const _HeroGallery({
    required this.photos,
    required this.heroTag,
    required this.badgeText,
    required this.showBadge,
    required this.saved,
    required this.pageIndex,
    required this.pageCount,
    required this.onBack,
    required this.onShare,
    required this.onToggleSaved,
    required this.controller,
    required this.onPageChanged,
  });

  final List<String> photos;
  final String? heroTag;
  final String badgeText;
  final bool showBadge;
  final bool saved;
  final int pageIndex;
  final int pageCount;

  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onToggleSaved;

  final PageController controller;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final heroH = (w * 0.70).clamp(260.0, 360.0);

        return SizedBox(
          height: heroH + topPad,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(top: topPad),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadii.lg),
                      bottomRight: Radius.circular(AppRadii.lg),
                    ),
                    child: PageView.builder(
                      controller: controller,
                      onPageChanged: onPageChanged,
                      itemCount: photos.length,
                      itemBuilder: (context, i) {
                        final src = photos[i];

                        final img = (src == '__fallback__')
                            ? Container(
                                decoration: BoxDecoration(
                                  gradient: AppColors.brandGradient,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.home_rounded,
                                    color: Colors.white,
                                    size: 54,
                                  ),
                                ),
                              )
                            : Image.network(src, fit: BoxFit.cover);

                        if (heroTag == null) return img;

                        return Hero(tag: heroTag!, child: img);
                      },
                    ),
                  ),
                ),
              ),

              // top buttons
              Positioned(
                left: AppSpacing.screenH,
                top: topPad + AppSpacing.sm,
                child: _CircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack,
                ),
              ),
              Positioned(
                right: AppSpacing.screenH,
                top: topPad + AppSpacing.sm,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CircleIconButton(
                      icon: Icons.ios_share_rounded,
                      onTap: onShare,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _CircleIconButton(
                      icon: saved
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      onTap: onToggleSaved,
                    ),
                  ],
                ),
              ),

              // counter + badge
              Positioned(
                left: AppSpacing.screenH,
                bottom: AppSpacing.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.s6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppRadii.chip),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    '${pageIndex + 1}/$pageCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              if (showBadge)
                Positioned(
                  right: AppSpacing.screenH,
                  bottom: AppSpacing.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.s6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(AppRadii.chip),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _PriceKeyInfoCard extends StatelessWidget {
  const _PriceKeyInfoCard({
    required this.kind,
    required this.title,
    required this.location,
    required this.priceText,
    required this.beds,
    required this.baths,
    required this.sizeLabel,
    required this.landTitleType,
    required this.commercialType,
  });

  final ListingKind kind;
  final String title;
  final String location;
  final String priceText;
  final int? beds;
  final int? baths;
  final String sizeLabel;
  final String landTitleType;
  final String commercialType;

  @override
  Widget build(BuildContext context) {
    final meta = switch (kind) {
      ListingKind.buy =>
        '${beds ?? 0} Bed  •  ${baths ?? 0} Bath  •  $sizeLabel',
      ListingKind.rent =>
        '${beds ?? 1} Bed  •  ${baths ?? 1} Bath  •  $sizeLabel',
      ListingKind.land => '$sizeLabel  •  $landTitleType',
      ListingKind.commercial => '$commercialType  •  $sizeLabel',
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
        boxShadow: AppShadows.lift(context, blur: 18, y: 10, alpha: 0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                priceText,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.brandGreenDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            meta,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary(context),
      ),
    );
  }
}

class _OverviewText extends StatefulWidget {
  const _OverviewText({required this.text});
  final String text;

  @override
  State<_OverviewText> createState() => _OverviewTextState();
}

class _OverviewTextState extends State<_OverviewText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final maxLines = _expanded ? 10 : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Read less' : 'Read more',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.brandBlueSoft,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // ✅ responsive grid count without hardcoding
        final w = c.maxWidth;
        final cols = w >= 520 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 3.6,
          ),
          itemBuilder: (context, i) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface(context).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(AppRadii.button),
                border: Border.all(color: AppColors.overlay(context, 0.06)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppColors.brandGreenDeep,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      items[i],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.brandBlueSoft.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: AppColors.overlay(context, 0.06)),
            ),
            child: const Center(
              child: Icon(
                Icons.map_rounded,
                color: AppColors.brandBlueSoft,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            address,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onOpenMaps,
              child: const Text('Open in Maps  ›'),
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
    required this.onChat,
    required this.onCall,
  });

  final String name;
  final bool verified;
  final VoidCallback onChat;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white),
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    if (verified) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.s6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandGreenDeep.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(AppRadii.chip),
                          border: Border.all(
                            color: AppColors.brandGreenDeep.withValues(
                              alpha: 0.22,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Verified',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.brandGreenDeep,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  'Agent / Landlord',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            onPressed: onChat,
            icon: const Icon(Icons.chat_bubble_outline_rounded),
          ),
          IconButton(onPressed: onCall, icon: const Icon(Icons.call_outlined)),
        ],
      ),
    );
  }
}

class _FeesCard extends StatelessWidget {
  const _FeesCard({required this.kind});
  final ListingKind kind;

  @override
  Widget build(BuildContext context) {
    String text;
    switch (kind) {
      case ListingKind.rent:
        text =
            'Rent fees: Deposit + Agency + Caution (wire real amounts later).';
        break;
      case ListingKind.buy:
        text = 'Payment flow: escrow + installment options (wire later).';
        break;
      case ListingKind.land:
        text = 'Documents: Survey, C of O, deed of assignment (wire later).';
        break;
      case ListingKind.commercial:
        text = 'Tour + lease terms vary by property (wire later).';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.overlay(context, 0.06)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary(context),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SimilarListingsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, __) {
          return Container(
            width: 220,
            decoration: BoxDecoration(
              color: AppColors.surface(context).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: AppColors.overlay(context, 0.06)),
            ),
            child: const Center(child: Text('Similar (TODO)')),
          );
        },
      ),
    );
  }
}

class _BottomActionsBar extends StatelessWidget {
  const _BottomActionsBar({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onMessage,
    required this.onCall,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback onMessage;
  final VoidCallback onCall;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.sm,
        AppSpacing.screenH,
        bottomPad + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.92),
        border: Border(
          top: BorderSide(color: AppColors.overlay(context, 0.08)),
        ),
        boxShadow: AppShadows.lift(context, blur: 18, y: -8, alpha: 0.08),
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 380;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _MiniAction(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Message',
                      onTap: onMessage,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _MiniAction(
                      icon: Icons.call_outlined,
                      label: 'Call',
                      onTap: onCall,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _PrimaryButton(
                        label: primaryLabel,
                        onTap: onPrimary,
                      ),
                    ),
                  ],
                ),
                if (secondaryLabel != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: wide ? double.infinity : double.infinity,
                    child: _SecondaryButton(
                      label: secondaryLabel!,
                      onTap: onSecondary,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.brandBlueSoft.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(color: AppColors.overlay(context, 0.06)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.brandBlueSoft),
            const SizedBox(width: AppSpacing.s6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(AppRadii.button),
          boxShadow: AppShadows.soft(context, blur: 14, y: 8, alpha: 0.10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(color: AppColors.overlay(context, 0.10)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
