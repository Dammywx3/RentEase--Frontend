import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';

import '../../../shared/models/listing_model.dart';
import '../listing_detail/listing_detail_screen.dart';
import '../../../core/ui/nav/tenant_nav.dart';

enum SavedTab { listings, searches }

class SavedScreen extends StatefulWidget {
  const SavedScreen({
    super.key,
    this.initialTab = SavedTab.listings,
    this.savedListings = const [],
    this.savedSearches = const [],
    this.useDemoWhenEmpty = true,
    this.onExploreHomesTap,
  });

  final SavedTab initialTab;
  final List<ListingModel> savedListings;
  final List<SavedSearchVM> savedSearches;
  final bool useDemoWhenEmpty;
  final VoidCallback? onExploreHomesTap;

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late SavedTab _tab;

  late List<SavedSearchVM> _localSearches;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
    _localSearches = List.of(widget.savedSearches);
  }

  List<ListingModel> get _listings {
    if (widget.savedListings.isNotEmpty) return widget.savedListings;
    if (!widget.useDemoWhenEmpty) return const [];
    return _demoListings();
  }

  List<SavedSearchVM> get _searches {
    if (_localSearches.isNotEmpty) return _localSearches;
    if (!widget.useDemoWhenEmpty) return const [];
    return _demoSearches();
  }

  // ---------------- Demo data (remove when backend wired) ----------------

  List<ListingModel> _demoListings() {
    return const [
      ListingModel(
        id: 'L-1001',
        title: 'Lekki Phase 1 • Unit 3B',
        location: 'Lekki, Lagos',
        type: 'rent',
        price: 850000,
        currency: 'NGN',
        status: 'published',
        beds: 2,
        baths: 2,
        mediaUrls: ['assets/images/listing_011.png'],
        ownerName: 'Chinedu Okafor',
      ),
      ListingModel(
        id: 'L-1002',
        title: 'Ajah Prime • Plot 7A',
        location: 'Ajah, Lagos',
        type: 'land',
        price: 12500000,
        currency: 'NGN',
        status: 'published',
        beds: null,
        baths: null,
        mediaUrls: ['assets/images/listing_012.png'],
      ),
    ];
  }

  List<SavedSearchVM> _demoSearches() => [
        SavedSearchVM(
          id: 'S-1001',
          title: 'For Rent in Lekki',
          summary: '₦800k–₦1.2m • 2 beds • Verified agents',
          updatesText: '3 new listings since yesterday',
          alertsEnabled: true,
          filters: const {
            'type': 'rent',
            'city': 'Lekki',
            'min': 800000,
            'max': 1200000,
            'beds': 2,
            'verified': true,
          },
        ),
        SavedSearchVM(
          id: 'S-1002',
          title: 'Land in Ajah',
          summary: '₦10m–₦20m • 600–900sqm',
          updatesText: '1 new listing since yesterday',
          alertsEnabled: false,
          filters: const {
            'type': 'land',
            'city': 'Ajah',
            'min': 10000000,
            'max': 20000000,
            'sqm_min': 600,
            'sqm_max': 900,
          },
        ),
      ];

  // ---------------- Navigation ----------------

  void _openListing(ListingModel listing) {
    final heroTag = 'saved_${listing.id}';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(
          listing: listing,
          heroTag: heroTag,
          heroGradient: AppColors.demoCardGradientA,
          isVerified: true,
        ),
      ),
    );
  }

  void _openSearch(SavedSearchVM s) {
    // You said you only have SearchScreen, so go there.
    // Later, you can replace this with SearchResultsScreen when you build it.
    TenantNav.goToSearch(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opened Search (filters: ${s.title})')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listings = _listings;
    final searches = _searches;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        scroll: false,
        child: Column(
          children: [
            // ---------------- Top Bar ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                AppSpacing.md,
                AppSpacing.screenH,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Text(
                    'Saved',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.navy,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Manage saved (wire later)')),
                      );
                    },
                    icon: Icon(Icons.edit_rounded, color: AppColors.textMuted(context)),
                  ),
                ],
              ),
            ),

            // ---------------- Segmented Tabs ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH,
                0,
                AppSpacing.screenH,
                AppSpacing.md,
              ),
              child: _SegmentTabs(
                left: 'Listings',
                right: 'Searches',
                value: _tab == SavedTab.listings ? 0 : 1,
                onChanged: (v) => setState(() {
                  _tab = v == 0 ? SavedTab.listings : SavedTab.searches;
                }),
              ),
            ),

            Expanded(
              child: _tab == SavedTab.listings
                  ? _SavedListingsTab(
                      items: listings,
                      onExploreHomesTap: widget.onExploreHomesTap,
                      onOpenListing: _openListing,
                    )
                  : _SavedSearchesTab(
                      items: searches,
                      onCreateTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Create saved search (wire later)')),
                        );
                      },
                      onOpenSearch: _openSearch,
                      onToggleAlerts: (id, enabled) {
                        setState(() {
                          final idx = _localSearches.indexWhere((e) => e.id == id);
                          if (idx >= 0) {
                            _localSearches[idx] =
                                _localSearches[idx].copyWith(alertsEnabled: enabled);
                          } else {
                            // If using demo searches, modify a local copy
                            final demo = _demoSearches();
                            final dIdx = demo.indexWhere((e) => e.id == id);
                            if (dIdx >= 0) {
                              demo[dIdx] = demo[dIdx].copyWith(alertsEnabled: enabled);
                              _localSearches = demo;
                            }
                          }
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------------- Tab 1: Listings ---------------------- */

class _SavedListingsTab extends StatelessWidget {
  const _SavedListingsTab({
    required this.items,
    required this.onExploreHomesTap,
    required this.onOpenListing,
  });

  final List<ListingModel> items;
  final VoidCallback? onExploreHomesTap;
  final ValueChanged<ListingModel> onOpenListing;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState(
        title: 'No saved listings yet',
        buttonText: 'Explore homes',
        onTap: onExploreHomesTap,
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
        childAspectRatio: 0.74, // ✅ you asked where to put it
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _SavedListingCard(
        listing: items[i],
        onTap: () => onOpenListing(items[i]),
      ),
    );
  }
}

class _SavedListingCard extends StatelessWidget {
  const _SavedListingCard({
    required this.listing,
    required this.onTap,
  });

  final ListingModel listing;
  final VoidCallback onTap;

  bool get _isVerified => true; // wire later

  String get _intentLabel {
    final t = (listing.type ?? '').toLowerCase();
    if (t.contains('rent')) return 'Rent';
    if (t.contains('buy')) return 'Buy';
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

  String _priceText() {
    final s = listing.price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return '₦$buf';
  }

  String _factsLine() {
    final parts = <String>[];
    if (listing.beds != null) parts.add('${listing.beds} bd');
    if (listing.baths != null) parts.add('${listing.baths} ba');
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final media = listing.mediaUrls;
    final hasAsset = media.isNotEmpty && media.first.trim().startsWith('assets/');
    final thumb = hasAsset ? media.first.trim() : null;

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
                      Positioned.fill(
                        child: thumb != null
                            ? Image.asset(thumb, fit: BoxFit.cover)
                            : Container(
                                color: AppColors.tenantPanel.withValues(alpha: 0.85),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.home_rounded,
                                  size: AppSpacing.xxxl,
                                  color: AppColors.brandBlueSoft,
                                ),
                              ),
                      ),
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
                          child: const Icon(Icons.favorite_rounded,
                              size: 18, color: Colors.redAccent),
                        ),
                      ),
                      Positioned(
                        left: AppSpacing.sm,
                        bottom: AppSpacing.sm,
                        child: Row(
                          children: [
                            _BadgePill(text: _intentLabel, color: _intentColor),
                            const SizedBox(width: AppSpacing.s6),
                            if (_isVerified)
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
                      _priceText(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.navy,
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
                              color: AppColors.navy.withValues(alpha: 0.86),
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

/* ---------------------- Tab 2: Searches ---------------------- */

class _SavedSearchesTab extends StatelessWidget {
  const _SavedSearchesTab({
    required this.items,
    required this.onCreateTap,
    required this.onOpenSearch,
    required this.onToggleAlerts,
  });

  final List<SavedSearchVM> items;
  final VoidCallback onCreateTap;
  final ValueChanged<SavedSearchVM> onOpenSearch;
  final void Function(String id, bool enabled) onToggleAlerts;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState(
        title: 'No saved searches yet',
        buttonText: 'Create a saved search',
        onTap: onCreateTap,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.sm,
        AppSpacing.screenH,
        AppSizes.screenBottomPad,
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, i) {
        final s = items[i];
        return _FrostCard(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onOpenSearch(s),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      height: AppSizes.iconButtonBox,
                      width: AppSizes.iconButtonBox,
                      decoration: BoxDecoration(
                        color: AppColors.overlay(context, 0.05),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: Icon(Icons.bookmark_rounded,
                          color: AppColors.textMuted(context)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.navy,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.s2),
                          Text(
                            s.summary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMuted(context),
                                ),
                          ),
                          const SizedBox(height: AppSpacing.s6),
                          Text(
                            s.updatesText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brandGreenDeep,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () => onToggleAlerts(s.id, !s.alertsEnabled),
                          icon: Icon(
                            s.alertsEnabled
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_off_rounded,
                            color: s.alertsEnabled
                                ? AppColors.brandGreenDeep
                                : AppColors.textMuted(context),
                          ),
                        ),
                        Text(
                          s.alertsEnabled ? 'On' : 'Off',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.textMuted(context),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/* ---------------------- Shared UI ---------------------- */

class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs({
    required this.left,
    required this.right,
    required this.value,
    required this.onChanged,
  });

  final String left;
  final String right;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.pillButtonHeight,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.overlay(context, 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegBtn(
              text: left,
              active: value == 0,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: AppSpacing.s6),
          Expanded(
            child: _SegBtn(
              text: right,
              active: value == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegBtn extends StatelessWidget {
  const _SegBtn({
    required this.text,
    required this.active,
    required this.onTap,
  });

  final String text;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final blue = AppColors.brandBlueSoft;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? blue.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: active ? blue.withValues(alpha: 0.25) : Colors.transparent,
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
              ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.buttonText,
    required this.onTap,
  });

  final String title;
  final String buttonText;
  final VoidCallback? onTap;

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
              color: AppColors.navy,
            ),
      ),
    );
  }
}

/* ---------------------- Saved Search VM ---------------------- */

class SavedSearchVM {
  SavedSearchVM({
    required this.id,
    required this.title,
    required this.summary,
    required this.updatesText,
    required this.alertsEnabled,
    required this.filters,
  });

  final String id;
  final String title;
  final String summary;
  final String updatesText;
  final bool alertsEnabled;
  final Map<String, dynamic> filters;

  SavedSearchVM copyWith({bool? alertsEnabled}) {
    return SavedSearchVM(
      id: id,
      title: title,
      summary: summary,
      updatesText: updatesText,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      filters: filters,
    );
  }
}