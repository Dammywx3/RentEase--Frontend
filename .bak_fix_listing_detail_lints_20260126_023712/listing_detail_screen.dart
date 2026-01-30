import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../shared/models/listing_model.dart';
import '../../../shared/services/toast_service.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({
    super.key,
    required this.listing,
    required this.saved,
    required this.onToggleSaved,
  });

  final ListingModel listing;
  final bool saved;
  final VoidCallback onToggleSaved;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  static const _bgTop = Color(0xFFF1F3F8);
  static const _bgBottom = Color(0xFFE9ECF4);

  static const _ink = Color(0xFF1E2A3A);
  static const _muted = Color(0xFF6F7785);

  static const _blue = Color(0xFF2E5E9A);
  static const _green = Color(0xFF3C7C5A);

  late final PageController _pageCtrl;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  // ---------------- Helpers ----------------

  String _fmtMoney(String currency, num v) {
    // Convert common NGN formats to the Naira symbol
    final c = currency.trim().toUpperCase();
    final symbol = (c == 'NGN' || c == 'NAIRA' || c == '₦')
        ? '₦'
        : currency.trim();

    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return symbol.isEmpty ? buf.toString() : '$symbol$buf';
  }

  bool get _ctaDisabled {
    final ps = (widget.listing.propertyStatus ?? '').toLowerCase();
    return ps == 'occupied' || ps == 'maintenance' || ps == 'unavailable';
  }

  String get _ctaDisabledReason {
    final ps = (widget.listing.propertyStatus ?? '').toLowerCase();
    if (ps == 'occupied') return 'Occupied';
    if (ps == 'maintenance') return 'Under maintenance';
    if (ps == 'unavailable') return 'Unavailable';
    return 'Not available';
  }

  bool _isVerifiedDeal(ListingModel l) {
    // Your ListingModel has no boolean, so infer from status text.
    final s = l.status.toLowerCase();
    return s.contains('verified') ||
        s.contains('approved') ||
        s.contains('active');
  }

  _ListingCategory _inferCategory(ListingModel l) {
    // Use `type` (since you have it) + fallbacks from title/status.
    final t = (l.type ?? '').toLowerCase().trim();
    final title = l.title.toLowerCase();
    final status = l.status.toLowerCase();

    // Land
    if (t.contains('land') ||
        title.contains('land') ||
        title.contains('plot')) {
      return _ListingCategory.land;
    }

    // Commercial
    if (t.contains('commercial') ||
        title.contains('office') ||
        title.contains('shop') ||
        title.contains('warehouse') ||
        title.contains('commercial')) {
      return _ListingCategory.commercial;
    }

    // Rent
    if (t.contains('rent') ||
        status.contains('rent') ||
        title.contains('/yr') ||
        title.contains('/mo')) {
      return _ListingCategory.rent;
    }

    // Default = Buy
    return _ListingCategory.buy;
  }

  String _primaryCtaLabel(_ListingCategory cat) {
    switch (cat) {
      case _ListingCategory.buy:
        return 'Buy Options';
      case _ListingCategory.rent:
        return 'Pay Rent';
      case _ListingCategory.land:
        return 'Request Inspection';
      case _ListingCategory.commercial:
        return 'Schedule Tour';
    }
  }

  void _toast(String msg) => ToastService.show(context, msg, success: true);

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    final l = widget.listing;

    final cat = _inferCategory(l);
    final isVerified = _isVerifiedDeal(l);

    final priceText = _fmtMoney(l.currency, l.price);

    final isRentLike =
        cat == _ListingCategory.rent || cat == _ListingCategory.commercial;
    final periodSuffix = isRentLike ? ' / yr' : '';

    final media = l.mediaUrls;
    final imageCount = media.isNotEmpty
        ? media.length
        : 8; // fallback placeholders

    // Top meta line under price
    final beds = l.beds ?? 0;
    final baths = l.baths ?? 0;
    final typeLabel = (l.type ?? '').trim();

    String metaLine() {
      if (cat == _ListingCategory.land) {
        return typeLabel.isNotEmpty ? typeLabel : 'Land';
      }
      if (cat == _ListingCategory.commercial) {
        return typeLabel.isNotEmpty ? typeLabel : 'Commercial';
      }
      // Houses (buy/rent)
      final parts = <String>[];
      if (beds > 0) parts.add('$beds Beds');
      if (baths > 0) parts.add('$baths Baths');
      if (typeLabel.isNotEmpty) parts.add(typeLabel);
      return parts.isEmpty ? '—' : parts.join(' • ');
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgTop, _bgBottom],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _HeroGallery(
                      title: l.title,
                      mediaUrls: media,
                      fallbackCount: imageCount,
                      pageCtrl: _pageCtrl,
                      page: _page,
                      onPage: (i) => setState(() => _page = i),
                      saved: widget.saved,
                      onToggleSaved: widget.onToggleSaved,
                      onBack: () => Navigator.of(context).maybePop(),
                      onShare: () => _toast('Share (wire later)'),
                      isVerified: isVerified,
                      isSponsored: false,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Price + key meta
                          _FrostCard(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$priceText$periodSuffix',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: _ink,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    metaLine(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: _muted,
                                        ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 18,
                                        color: _green,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          l.location,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: _ink,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if ((l.propertyStatus ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline_rounded,
                                          size: 18,
                                          color: _muted.withValues(alpha: 0.9),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Availability: ${l.propertyStatus}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: _muted,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Quick info chips
                          _QuickChipsRow(
                            verified: isVerified,
                            available: !_ctaDisabled,
                            furnished: false,
                            serviced: false,
                            agentListed: true,
                          ),
                          const SizedBox(height: 12),

                          // Overview
                          _Section(
                            title: 'Overview',
                            child: _OverviewBlock(
                              text:
                                  'Wire real description later from backend.\n\nOwner: ${(l.ownerName ?? '—')}\nType: ${(l.type ?? '—')}\nStatus: ${l.status}',
                              onReadMore: () =>
                                  _toast('Read more (wire later)'),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Features
                          _Section(
                            title: 'Features',
                            child: const _FeaturesGrid(
                              features: [
                                'Parking',
                                'Security',
                                'Water',
                                'Power backup',
                                'CCTV',
                                'Gate house',
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Location
                          _Section(
                            title: 'Location',
                            child: _MapCard(
                              locationLabel: l.location,
                              onOpenMaps: () =>
                                  _toast('Open in Maps (wire later)'),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Agent / Landlord card (trust)
                          _Section(
                            title: 'Agent / Landlord',
                            child: _AgentCard(
                              name: (l.ownerName ?? 'Agent'),
                              verified: true,
                              ratingText: '⭐ 4.8',
                              onChat: () => _toast('Chat (wire later)'),
                              onCall: () => _toast('Call (wire later)'),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Payment & Fees (context-aware)
                          _Section(
                            title: 'Payment & Fees',
                            child: _PaymentFeesCardSimple(
                              category: cat,
                              priceText: '$priceText$periodSuffix',
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Similar listings
                          _Section(
                            title: 'Similar listings',
                            child: _SimilarListingsRow(
                              onTap: () =>
                                  _toast('Open similar listing (wire later)'),
                            ),
                          ),

                          const SizedBox(height: 18),

                          if (_ctaDisabled) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Theme.of(
                                  context,
                                ).colorScheme.error.withAlpha(18),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.error.withAlpha(90),
                                ),
                              ),
                              child: Text('CTAs disabled: $_ctaDisabledReason'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Sticky actions bottom
              Align(
                alignment: Alignment.bottomCenter,
                child: _StickyActionBar(
                  primaryLabel: _primaryCtaLabel(cat),
                  disabled: _ctaDisabled,
                  onMessage: () => _toast('Message (wire later)'),
                  onCall: () => _toast('Call (wire later)'),
                  onPrimary: _ctaDisabled
                      ? null
                      : () => _toast('${_primaryCtaLabel(cat)} (wire later)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ListingCategory { buy, rent, land, commercial }

/* ======================== HERO ======================== */

class _HeroGallery extends StatelessWidget {
  const _HeroGallery({
    required this.title,
    required this.mediaUrls,
    required this.fallbackCount,
    required this.pageCtrl,
    required this.page,
    required this.onPage,
    required this.saved,
    required this.onToggleSaved,
    required this.onBack,
    required this.onShare,
    required this.isVerified,
    required this.isSponsored,
  });

  final String title;
  final List<String> mediaUrls;
  final int fallbackCount;

  final PageController pageCtrl;
  final int page;
  final ValueChanged<int> onPage;

  final bool saved;
  final VoidCallback onToggleSaved;

  final VoidCallback onBack;
  final VoidCallback onShare;

  final bool isVerified;
  final bool isSponsored;

  static const _ink = Color(0xFF1E2A3A);
  static const _green = Color(0xFF3C7C5A);

  @override
  Widget build(BuildContext context) {
    final count = mediaUrls.isNotEmpty ? mediaUrls.length : fallbackCount;

    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          PageView.builder(
            controller: pageCtrl,
            itemCount: count,
            onPageChanged: onPage,
            itemBuilder: (_, i) {
              if (mediaUrls.isNotEmpty) {
                final url = mediaUrls[i];
                return _NetworkImageHero(url: url);
              }
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFCFDBEA).withValues(alpha: 0.85),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.photo_rounded,
                  size: 60,
                  color: _ink.withValues(alpha: 0.55),
                ),
              );
            },
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Row(
                children: [
                  _CircleIcon(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: onBack,
                  ),
                  const Spacer(),
                  _CircleIcon(icon: Icons.share_rounded, onTap: onShare),
                  const SizedBox(width: 10),
                  _CircleIcon(
                    icon: saved
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    onTap: onToggleSaved,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 14,
            right: 14,
            bottom: 16,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 14,
                    color: Colors.black.withValues(alpha: 0.35),
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 14,
            bottom: 64,
            child: Row(
              children: [
                if (isVerified)
                  const _Badge(
                    icon: Icons.check_rounded,
                    text: 'Verified Deal',
                    color: _green,
                  ),
                if (isSponsored) ...[
                  if (isVerified) const SizedBox(width: 8),
                  const _Badge(
                    icon: Icons.campaign_rounded,
                    text: 'Sponsored',
                    color: _ink,
                    subtle: true,
                  ),
                ],
              ],
            ),
          ),

          Positioned(
            right: 14,
            top: 54,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${page + 1}/$count',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkImageHero extends StatelessWidget {
  const _NetworkImageHero({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFCFDBEA).withValues(alpha: 0.5),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Center(
            child: Icon(
              Icons.broken_image_rounded,
              size: 60,
              color: Colors.black.withValues(alpha: 0.35),
            ),
          );
        },
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Center(
            child: SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                value: progress.expectedTotalBytes == null
                    ? null
                    : progress.cumulativeBytesLoaded /
                          (progress.expectedTotalBytes ?? 1),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.text,
    required this.color,
    this.subtle = false,
  });

  final IconData icon;
  final String text;
  final Color color;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: subtle
            ? Colors.white.withValues(alpha: 0.55)
            : color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: subtle
              ? Colors.black.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: subtle ? color : Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: subtle ? color : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/* ======================== CHIPS ======================== */

class _QuickChipsRow extends StatelessWidget {
  const _QuickChipsRow({
    required this.verified,
    required this.available,
    required this.furnished,
    required this.serviced,
    required this.agentListed,
  });

  final bool verified;
  final bool available;
  final bool furnished;
  final bool serviced;
  final bool agentListed;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (verified)
        const _Chip(icon: Icons.check_circle_rounded, text: 'Verified'),
      _Chip(
        icon: available
            ? Icons.event_available_rounded
            : Icons.event_busy_rounded,
        text: available ? 'Available' : 'Unavailable',
      ),
      if (furnished)
        const _Chip(icon: Icons.weekend_rounded, text: 'Furnished'),
      if (serviced)
        const _Chip(icon: Icons.home_repair_service_rounded, text: 'Serviced'),
      _Chip(
        icon: agentListed ? Icons.verified_user_rounded : Icons.person_rounded,
        text: agentListed ? 'Agent listed' : 'Direct owner',
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips
            .map(
              (w) =>
                  Padding(padding: const EdgeInsets.only(right: 10), child: w),
            )
            .toList(),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  static const _ink = Color(0xFF1E2A3A);
  static const _muted = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _muted.withValues(alpha: 0.9)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w900, color: _ink),
          ),
        ],
      ),
    );
  }
}

/* ======================== SECTIONS ======================== */

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  static const _ink = Color(0xFF1E2A3A);

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: _ink,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _OverviewBlock extends StatelessWidget {
  const _OverviewBlock({required this.text, required this.onReadMore});
  final String text;
  final VoidCallback onReadMore;

  static const _muted = Color(0xFF6F7785);
  static const _green = Color(0xFF3C7C5A);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: _muted.withValues(alpha: 0.95),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: onReadMore,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Read more',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _green,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.chevron_right_rounded, size: 20, color: _green),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturesGrid extends StatelessWidget {
  const _FeaturesGrid({required this.features});
  final List<String> features;

  static const _muted = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    final items = features.take(10).toList();
    if (items.isEmpty) {
      return Text(
        'No features listed yet.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: _muted,
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((t) => _FeaturePill(text: t)).toList(),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.text});
  final String text;

  static const _ink = Color(0xFF1E2A3A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w900, color: _ink),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.locationLabel, required this.onOpenMaps});
  final String locationLabel;
  final VoidCallback onOpenMaps;

  static const _blue = Color(0xFF2E5E9A);
  static const _muted = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 150,
            color: const Color(0xFFCFDBEA).withValues(alpha: 0.85),
            alignment: Alignment.center,
            child: Text(
              'Map preview (wire later)\n$locationLabel',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: _muted,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: onOpenMaps,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _blue.withValues(alpha: 0.18)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.map_rounded, size: 18, color: _blue),
                  SizedBox(width: 8),
                  Text(
                    'Open in Maps',
                    style: TextStyle(fontWeight: FontWeight.w900, color: _blue),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AgentCard extends StatelessWidget {
  const _AgentCard({
    required this.name,
    required this.verified,
    required this.ratingText,
    required this.onChat,
    required this.onCall,
  });

  final String name;
  final bool verified;
  final String ratingText;
  final VoidCallback onChat;
  final VoidCallback onCall;

  static const _blue = Color(0xFF2E5E9A);
  static const _ink = Color(0xFF1E2A3A);
  static const _muted = Color(0xFF6F7785);
  static const _green = Color(0xFF3C7C5A);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xFFCFDBEA),
          child: Icon(Icons.person_rounded, color: _blue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (verified) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _green.withValues(alpha: 0.20),
                        ),
                      ),
                      child: const Text(
                        'Verified',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: _green,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    ratingText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _IconBtn(icon: Icons.chat_rounded, onTap: onChat),
        const SizedBox(width: 10),
        _IconBtn(icon: Icons.call_rounded, onTap: onCall),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  static const _blue = Color(0xFF2E5E9A);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Icon(icon, size: 18, color: _blue),
      ),
    );
  }
}

class _PaymentFeesCardSimple extends StatelessWidget {
  const _PaymentFeesCardSimple({
    required this.category,
    required this.priceText,
  });

  final _ListingCategory category;
  final String priceText;

  static const _muted = Color(0xFF6F7785);
  static const _ink = Color(0xFF1E2A3A);

  @override
  Widget build(BuildContext context) {
    final rows = <_KV>[];

    switch (category) {
      case _ListingCategory.rent:
        rows.add(_KV('Rent', priceText));
        rows.add(const _KV('Caution deposit', '— (wire later)'));
        rows.add(const _KV('Agency fee', '— (wire later)'));
        rows.add(const _KV('Service charge', '— (wire later)'));
        break;

      case _ListingCategory.buy:
        rows.add(_KV('Price', priceText));
        rows.add(const _KV('Escrow supported', 'Yes (wire later)'));
        break;

      case _ListingCategory.land:
        rows.add(_KV('Price', priceText));
        rows.add(
          const _KV('Documentation', 'C of O / Gazette / Deed (wire later)'),
        );
        break;

      case _ListingCategory.commercial:
        rows.add(_KV('Price', priceText));
        rows.add(const _KV('Power', '— (wire later)'));
        break;
    }

    return Column(
      children: rows
          .map(
            (kv) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      kv.k,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: _muted.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  Text(
                    kv.v,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: _ink,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _KV {
  const _KV(this.k, this.v);
  final String k;
  final String v;
}

class _SimilarListingsRow extends StatelessWidget {
  const _SimilarListingsRow({required this.onTap});
  final VoidCallback onTap;

  static const _muted = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 8,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) {
          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 170,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: const Color(0xFFCFDBEA).withValues(alpha: 0.85),
                        alignment: Alignment.center,
                        child: const Icon(Icons.home_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Similar listing',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap to open (wire later)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ======================== Sticky Bar ======================== */

class _StickyActionBar extends StatelessWidget {
  const _StickyActionBar({
    required this.primaryLabel,
    required this.disabled,
    required this.onMessage,
    required this.onCall,
    required this.onPrimary,
  });

  final String primaryLabel;
  final bool disabled;
  final VoidCallback onMessage;
  final VoidCallback onCall;
  final VoidCallback? onPrimary;

  static const _green = Color(0xFF3C7C5A);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.62),
            border: Border(
              top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                _MiniAction(
                  icon: Icons.message_rounded,
                  label: 'Message',
                  onTap: onMessage,
                ),
                const SizedBox(width: 10),
                _MiniAction(
                  icon: Icons.call_rounded,
                  label: 'Call',
                  onTap: onCall,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: disabled ? null : onPrimary,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: disabled
                            ? const Color(0xFFB9C1CF).withValues(alpha: 0.45)
                            : _green.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: disabled
                              ? Colors.black.withValues(alpha: 0.06)
                              : _green.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        disabled ? '$primaryLabel (Disabled)' : primaryLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: disabled
                              ? const Color(0xFF6F7785)
                              : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  static const _blue = Color(0xFF2E5E9A);
  static const _muted = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 86,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: _blue),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: _muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ======================== Frost Card ======================== */

class _FrostCard extends StatelessWidget {
  const _FrostCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: child,
    );
  }
}
