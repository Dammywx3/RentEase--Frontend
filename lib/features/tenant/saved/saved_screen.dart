// lib/features/tenant/saved/saved_screen.dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';

import '../../../core/utils/money_format.dart';
import '../../../shared/models/listing_model.dart';
import '../listing_detail/listing_detail_screen.dart';
import '../../../core/ui/nav/tenant_nav.dart';

import '../../../shared/stores/saved_store.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({
    super.key,
    this.onExploreHomesTap,
  });

  final VoidCallback? onExploreHomesTap;

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  void _openListing(ListingModel listing) {
    final heroTag = 'saved_${listing.id}';
    final verified = _isVerifiedListing(listing);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(
          listing: listing,
          heroTag: heroTag,
          heroGradient: AppColors.demoCardGradientA,
          isVerified: verified,
        ),
      ),
    );
  }

  bool _isVerifiedListing(ListingModel listing) {
    final s = (listing.status ?? '').toLowerCase().trim();
    return s == 'verified' || s.contains('verified');
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Manage Saved'),
        content: const Text('Clear all saved listings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              SavedStore.I.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        scroll: false,
        child: Column(
          children: [
            // ---------------- Top Bar (CENTERED title) ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.md,
                AppSpacing.screenH,
                AppSpacing.md,
              ),
              child: SizedBox(
                height: AppSizes.iconButtonBox,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Saved',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary(context),
                            ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        onPressed: _confirmClearAll,
                        icon: Icon(
                          Icons.tune_rounded,
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------------- Listings only ----------------
            Expanded(
              child: AnimatedBuilder(
                animation: SavedStore.I,
                builder: (_, __) {
                  final listings = SavedStore.I.savedListings;

                  return _SavedListingsGrid(
                    items: listings,
                    onExploreHomesTap: widget.onExploreHomesTap,
                    onOpenListing: _openListing,
                    isVerified: _isVerifiedListing,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------------- Listings Grid ---------------------- */

class _SavedListingsGrid extends StatelessWidget {
  const _SavedListingsGrid({
    required this.items,
    required this.onExploreHomesTap,
    required this.onOpenListing,
    required this.isVerified,
  });

  final List<ListingModel> items;
  final VoidCallback? onExploreHomesTap;
  final ValueChanged<ListingModel> onOpenListing;
  final bool Function(ListingModel) isVerified;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState(
        title: 'No saved listings yet',
        buttonText: 'Explore homes',
        onTap: onExploreHomesTap ?? () => TenantNav.goToExplore(context),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.sm,
        AppSpacing.screenH,
        AppSizes.screenBottomPad,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.74,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _SavedListingCard(
        listing: items[i],
        onTap: () => onOpenListing(items[i]),
        isVerified: isVerified(items[i]),
      ),
    );
  }
}

class _SavedListingCard extends StatelessWidget {
  const _SavedListingCard({
    required this.listing,
    required this.onTap,
    required this.isVerified,
  });

  final ListingModel listing;
  final VoidCallback onTap;
  final bool isVerified;

  String get _intentLabel {
    final t = (listing.type ?? '').toLowerCase();
    if (t.contains('sale') || t.contains('buy')) return 'Buy';
    if (t.contains('rent') || t.contains('lease')) return 'Rent';
    if (t.contains('land')) return 'Land';
    return 'Rent';
  }

  Color get _intentColor {
    switch (_intentLabel) {
      case 'Rent':
        return AppColors.brandBlueSoft;
      case 'Buy':
        return AppColors.brandGreenDeep;
      case 'Land':
        return AppColors.brandOrange;
      default:
        return AppColors.brandBlueSoft;
    }
  }

  String _factsLine() {
    final parts = <String>[];
    if (listing.beds != null) parts.add('${listing.beds} bd');
    if (listing.baths != null) parts.add('${listing.baths} ba');
    return parts.join(' • ');
  }

  bool get _hasMedia => listing.mediaUrls != null && listing.mediaUrls!.isNotEmpty;

  String? get _mediaFirst {
    if (!_hasMedia) return null;
    final v = listing.mediaUrls!.first.trim();
    return v.isEmpty ? null : v;
  }

  bool _isAssetPath(String v) => v.startsWith('assets/');
  bool _isNetworkUrl(String v) => v.startsWith('http://') || v.startsWith('https://');

  Widget _thumbWidget(BuildContext context) {
    final m = _mediaFirst;

    if (m != null && _isAssetPath(m)) {
      return Image.asset(m, fit: BoxFit.cover);
    }

    if (m != null && _isNetworkUrl(m)) {
      return Image.network(
        m,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _thumbFallback(context),
      );
    }

    return _thumbFallback(context);
  }

  Widget _thumbFallback(BuildContext context) {
    return Container(
      color: AppColors.tenantPanel.withValues(alpha: 0.85),
      alignment: Alignment.center,
      child: const Icon(
        Icons.home_rounded,
        size: AppSpacing.xxxl,
        color: AppColors.brandBlueSoft,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final priceText = fmtMoneyCompact(
      listing.price,
      currencyCode: (listing.currency ?? 'NGN').toUpperCase(),
    );

    return _FrostCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.card),
                child: AspectRatio(
                  aspectRatio: 1.25,
                  child: Stack(
                    children: [
                      Positioned.fill(child: _thumbWidget(context)),

                      // ✅ remove from saved
                      Positioned(
                        right: AppSpacing.sm,
                        top: AppSpacing.sm,
                        child: Container(
                          height: AppSizes.iconButtonBox,
                          width: AppSizes.iconButtonBox,
                          decoration: BoxDecoration(
                            color: AppColors.surface(context).withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.overlay(context, 0.06)),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => SavedStore.I.toggle(listing),
                            icon: Icon(
                              Icons.favorite_rounded,
                              size: 18,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: AppSpacing.sm,
                        bottom: AppSpacing.sm,
                        child: Row(
                          children: [
                            _BadgePill(text: _intentLabel, color: _intentColor),
                            const SizedBox(width: AppSpacing.s6),
                            if (isVerified)
                              const _BadgePill(
                                text: 'Verified',
                                color: AppColors.brandGreenDeep,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priceText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary(context),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    Text(
                      listing.location.trim().isEmpty ? 'Location' : listing.location.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted(context),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    if (_factsLine().isNotEmpty)
                      Text(
                        _factsLine(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary(context).withValues(alpha: 0.86),
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

/* ---------------------- Shared UI ---------------------- */

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.buttonText,
    required this.onTap,
  });

  final String title;
  final String buttonText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMuted(context),
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadii.button),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandBlueSoft.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(AppRadii.button),
                ),
                child: Text(
                  buttonText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
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

class _FrostCard extends StatelessWidget {
  const _FrostCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: 0.68),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.overlay(context, 0.05)),
          boxShadow: AppShadows.lift(context, blur: 18, y: 10, alpha: 0.08),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: child,
        ),
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary(context),
            ),
      ),
    );
  }
}