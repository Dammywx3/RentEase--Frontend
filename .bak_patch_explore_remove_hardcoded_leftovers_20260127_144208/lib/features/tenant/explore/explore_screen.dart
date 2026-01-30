import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';

import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import '../../../shared/models/listing_model.dart';
import '../listing_detail/listing_detail_screen.dart';
import '../viewings/viewings_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const _bgTop = AppColors.lightBg;
  static const _bgBottom = AppColors.mist;

  static const _green = AppColors.brandGreen;
  static const _blue = AppColors.brandBlueSoft;
  static const _muted = AppColors.textMutedLight;
  final PageController _featuredController = PageController(
    viewportFraction: 0.92,
  );
  int _featuredIndex = 0;

  // local saved state (later you’ll wire to backend + Saved tab)
  final Set<String> _savedIds = <String>{};

  // ✅ 15 sponsored items
  late final List<_DemoListing> _featured = List.generate(
    15,
    (i) => _DemoListing(
      id: 'sponsored_$i',
      title: 'Premium Villa ${i + 1}',
      price: 115000000 + (i * 2500000),
      location: _ngLocations[i % _ngLocations.length],
      beds: 4 + (i % 3),
      baths: 3 + (i % 2),
      sqft: 2600 + (i * 20),
      verified: i % 2 == 0,
      sponsored: true,
      type: 'Apartment',
    ),
  );

  // ✅ Latest listing rows: max 3 rows, each row scrollable horizontally
  late final List<_DemoListing> _latestA = List.generate(
    10,
    (i) => _DemoListing(
      id: 'latest_a_$i',
      title: 'Modern Apartment',
      price: 90000000 + (i * 1500000),
      location: _ngLocations[(i + 2) % _ngLocations.length],
      beds: 3 + (i % 2),
      baths: 2 + (i % 2),
      sqft: 1900 + (i * 15),
      verified: i % 3 == 0,
      type: 'Apartment',
    ),
  );

  late final List<_DemoListing> _latestB = List.generate(
    10,
    (i) => _DemoListing(
      id: 'latest_b_$i',
      title: 'Family Duplex',
      price: 129000000 + (i * 1800000),
      location: _ngLocations[(i + 5) % _ngLocations.length],
      beds: 4 + (i % 2),
      baths: 3 + (i % 2),
      sqft: 2200 + (i * 12),
      verified: i % 4 == 0,
      type: 'Duplex',
    ),
  );

  late final List<_DemoListing> _latestC = List.generate(
    10,
    (i) => _DemoListing(
      id: 'latest_c_$i',
      title: 'Prime Land Plot',
      price: 45000000 + (i * 1200000),
      location: _ngLocations[(i + 1) % _ngLocations.length],
      beds: 0,
      baths: 0,
      sqft: 5000 + (i * 120),
      verified: i % 5 == 0,
      type: 'Land',
    ),
  );

  @override
  void dispose() {
    _featuredController.dispose();
    super.dispose();
  }

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

  ListingModel _toListingModel(_DemoListing l) {
    // Use a safe status that won’t crash badges (you can align later with your enum map)
    // If your badge map expects something else, tell me what values you use.
    return ListingModel(
      id: l.id,
      title: l.title,
      price: l.price,
      currency: '₦',
      location: l.location,
      status: 'published',
      beds: l.beds == 0 ? null : l.beds,
      baths: l.baths == 0 ? null : l.baths,
      type: l.type,
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

  void _openListing(_DemoListing l) {
    final listing = _toListingModel(l);
    final saved = _savedIds.contains(listing.id);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(
          listing: listing,
          saved: saved,
          onToggleSaved: () => _toggleSaved(listing.id),
        ),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: Colors.transparent,
      safeAreaTop: true,
      safeAreaBottom: false,
      topBar: const AppTopBar(
        title: 'Explore',
        subtitle: 'Find your next home',
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: const SizedBox.shrink(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 2),
                child: _SearchBar(onTap: () => _toast('Use bottom Search tab')),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ✅ Buttons restored
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ActionPill(
                            filled: true,
                            color: _blue,
                            icon: Icons.home_rounded,
                            text: 'Buy',
                            onTap: () => _toast('Buy'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionPill(
                            filled: true,
                            color: _green,
                            icon: Icons.verified_user_rounded,
                            text: 'Agents',
                            onTap: () => _toast('Agents'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionPill(
                            filled: true,
                            color: _green,
                            icon: Icons.key_rounded,
                            text: 'Rent',
                            onTap: () => _toast('Rent'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionPill(
                            filled: false,
                            color: _muted,
                            icon: Icons.terrain_rounded,
                            text: 'Land',
                            onTap: () => _toast('Land'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ActionPill(
                            filled: false,
                            color: _muted,
                            icon: Icons.apartment_rounded,
                            text: 'Commercial',
                            onTap: () => _toast('Commercial'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SmallPill(
                            icon: Icons.favorite_rounded,
                            text: 'Saved',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ViewingsScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SmallPill(
                            icon: Icons.calendar_month_rounded,
                            text: 'Viewings',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ViewingsScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SmallPill(
                            icon: Icons.notifications_rounded,
                            text: 'Alerts',
                            onTap: () => _toast('Use bottom Alerts tab'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: _SectionTitle('Featured Listings'),
              ),
            ),

            // ✅ Featured carousel (scroll left)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 286,
                child: PageView.builder(
                  controller: _featuredController,
                  itemCount: _featured.length,
                  onPageChanged: (i) => setState(() => _featuredIndex = i),
                  itemBuilder: (context, i) {
                    final l = _featured[i];
                    final saved = _savedIds.contains(l.id);
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _FeaturedCard(
                        listing: l,
                        priceText: _fmtNaira(l.price),
                        saved: saved,
                        onToggleSaved: () => _toggleSaved(l.id),
                        onTap: () => _openListing(l),
                      ),
                    );
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Dots(
                      count: _featured.length,
                      index: _featuredIndex,
                      active: _green,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: _SectionTitle('Latest Listings'),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // ✅ 3 rows max, each row scroll left
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: Column(
                  children: [
                    _LatestRow(
                      listings: _latestA,
                      price: _fmtNaira,
                      savedIds: _savedIds,
                      onToggleSaved: _toggleSaved,
                      onTap: _openListing,
                    ),
                    const SizedBox(height: 12),
                    _LatestRow(
                      listings: _latestB,
                      price: _fmtNaira,
                      savedIds: _savedIds,
                      onToggleSaved: _toggleSaved,
                      onTap: _openListing,
                    ),
                    const SizedBox(height: 12),
                    _LatestRow(
                      listings: _latestC,
                      price: _fmtNaira,
                      savedIds: _savedIds,
                      onToggleSaved: _toggleSaved,
                      onTap: _openListing,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        ),
      ),
    );
  }
}

// ---------------- UI widgets ----------------

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: AppColors.navy,
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.filled,
    required this.color,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final bool filled;
  final Color color;
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? color.withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.62);
    final fg = filled ? Colors.white : AppColors.navy;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.chip),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(width: 8),
            Text(
              text,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.chip),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppRadii.chip),
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF3C7C5A)),
            const SizedBox(width: 8),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.listing,
    required this.priceText,
    required this.saved,
    required this.onToggleSaved,
    required this.onTap,
  });

  final _DemoListing listing;
  final String priceText;
  final bool saved;
  final VoidCallback onToggleSaved;
  final VoidCallback onTap;

  static const _green = Color(0xFF3C7C5A);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        margin: const EdgeInsets.only(left: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: [
            BoxShadow(
              blurRadius: 22,
              offset: const Offset(0, 12),
              color: Colors.black.withValues(alpha: 0.10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFB9C7DD), Color(0xFF879BB8)],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.villa_rounded,
                          size: 54,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Heart toggle (no remove)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: onToggleSaved,
                        child: Icon(
                          saved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: Colors.white.withValues(alpha: 0.95),
                          size: 26,
                        ),
                      ),
                    ),

                    Positioned(
                      left: 14,
                      bottom: 42,
                      child: Text(
                        listing.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              blurRadius: 18,
                              color: Colors.black.withValues(alpha: 0.35),
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (listing.verified)
                      Positioned(
                        left: 14,
                        bottom: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _green.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Verified Deal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (listing.sponsored)
                      Positioned(
                        left: 14,
                        top: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2E5E9A,
                            ).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                          child: const Text(
                            'Sponsored',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priceText,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listing.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMutedLight,
                        fontWeight: FontWeight.w700,
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

class _LatestRow extends StatelessWidget {
  const _LatestRow({
    required this.listings,
    required this.price,
    required this.savedIds,
    required this.onToggleSaved,
    required this.onTap,
  });

  final List<_DemoListing> listings;
  final String Function(num) price;
  final Set<String> savedIds;
  final void Function(String id) onToggleSaved;
  final void Function(_DemoListing listing) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: listings.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final l = listings[i];
          final saved = savedIds.contains(l.id);
          return _LatestCard(
            listing: l,
            saved: saved,
            onToggleSaved: () => onToggleSaved(l.id),
            priceText: price(l.price),
            onTap: () => onTap(l),
          );
        },
      ),
    );
  }
}

class _LatestCard extends StatelessWidget {
  const _LatestCard({
    required this.listing,
    required this.saved,
    required this.onToggleSaved,
    required this.priceText,
    required this.onTap,
  });

  final _DemoListing listing;
  final bool saved;
  final VoidCallback onToggleSaved;
  final String priceText;
  final VoidCallback onTap;

  static const _text = Color(0xFF1E2A3A);
  static const _muted = Color(0xFF6F7785);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.button),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFC8D3E6), Color(0xFF93A8C6)],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          listing.beds == 0
                              ? Icons.terrain_rounded
                              : Icons.house_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Heart toggle
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: onToggleSaved,
                        child: Icon(
                          saved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: Colors.white.withValues(alpha: 0.95),
                          size: 24,
                        ),
                      ),
                    ),

                    if (listing.verified)
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF3C7C5A,
                            ).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                          child: const Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priceText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.beds == 0
                          ? 'Plot size ${listing.sqft} sqft'
                          : '${listing.beds} bds | ${listing.baths} ba | ${listing.sqft} sqft',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _muted.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _muted.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w700,
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

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index, required this.active});
  final int count;
  final int index;
  final Color active;

  @override
  Widget build(BuildContext context) {
    final maxDots = 7;
    final start = (index - (maxDots ~/ 2)).clamp(
      0,
      (count - maxDots).clamp(0, count),
    );
    final end = (start + maxDots).clamp(0, count);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = start; i < end; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: i == index ? 20 : 8,
            decoration: BoxDecoration(
              color: i == index ? active : const Color(0xFFB8C0CF),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

// ---------------- demo data ----------------

class _DemoListing {
  const _DemoListing({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.beds,
    required this.baths,
    required this.sqft,
    this.verified = false,
    this.sponsored = false,
    this.type,
  });

  final String id;
  final String title;
  final int price;
  final String location;
  final int beds;
  final int baths;
  final int sqft;
  final bool verified;
  final bool sponsored;
  final String? type;
}

const List<String> _ngLocations = [
  'Lekki Phase 1, Lagos',
  'Ikoyi, Lagos',
  'Victoria Island, Lagos',
  'Ikeja GRA, Lagos',
  'Ajah, Lagos',
  'Yaba, Lagos',
  'Gwarinpa, Abuja',
  'Wuse 2, Abuja',
  'Maitama, Abuja',
  'Asokoro, Abuja',
  'GRA, Port Harcourt',
  'New GRA, Benin City',
  'Jericho, Ibadan',
  'Independence Layout, Enugu',
];
