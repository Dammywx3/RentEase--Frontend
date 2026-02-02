// lib/features/tenant/renting_tools/renting_tools_screen.dart
// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import '../../../shared/models/viewing_model.dart';

import '../tenancy/pay_rent/pay_rent_sheet.dart';
import '../tenancy/tenancies_screen.dart';
import '../viewings/viewings_screen.dart';
import '../viewings/data/viewings_api.dart';

import '../applications/my_applications_screen.dart';

class RentingToolsScreen extends StatefulWidget {
  const RentingToolsScreen({super.key});

  @override
  State<RentingToolsScreen> createState() => _RentingToolsScreenState();
}

class _RentingToolsScreenState extends State<RentingToolsScreen> {
  // ---------- Explore-style alpha helpers ----------
  // Matches ExploreScreen & MoreScreen exactly
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaSurface =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  final PageController _pc = PageController(viewportFraction: 0.92);
  int _idx = 0;

  // -------- Viewings (REAL) --------
  final ViewingsApi _viewingsApi = ViewingsApi();
  bool _viewingsLoading = false;
  String? _viewingsError;
  List<ViewingModel> _myViewings = const [];

  int get _upcomingCount {
    return _myViewings.where((v) =>
        v.status == ViewingStatus.requested ||
        v.status == ViewingStatus.confirmed).length;
  }

  int get _completedCount {
    return _myViewings.where((v) =>
        v.status == ViewingStatus.completed ||
        v.status == ViewingStatus.cancelled ||
        v.status == ViewingStatus.rejected).length;
  }

  Future<void> _loadMyViewings() async {
    if (_viewingsLoading) return;

    setState(() {
      _viewingsLoading = true;
      _viewingsError = null;
    });

    try {
      final list = await _viewingsApi.listMy(limit: 50, offset: 0);
      if (!mounted) return;

      setState(() {
        _myViewings = list;
        _viewingsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _viewingsError = e.toString();
        _viewingsLoading = false;
      });
    }
  }

  // Demo (wire from backend later)
  late final List<TenancyCardVM> _active = const [
    TenancyCardVM(
      id: 't1',
      title: 'Lekki Phase 1 • Unit 3B',
      location: 'Lekki, Lagos',
      rentNgn: 50000,
      dueLabel: 'May 1',
      startLabel: 'Jan 2026',
      endLabel: 'Jan 2027',
      statusLabel: 'Active',
    ),
    TenancyCardVM(
      id: 't2',
      title: 'Marina Garden • Unit A9',
      location: 'Victoria Island, Lagos',
      rentNgn: 120000,
      dueLabel: 'May 3',
      startLabel: 'Feb 2026',
      endLabel: 'Feb 2027',
      statusLabel: 'Active',
    ),
    TenancyCardVM(
      id: 't3',
      title: 'Ikoyi Villa • Room 5C',
      location: 'Ikoyi, Lagos',
      rentNgn: 220000,
      dueLabel: 'May 10',
      startLabel: 'Mar 2026',
      endLabel: 'Mar 2027',
      statusLabel: 'Active',
    ),
  ];

  late final List<TenancyCardVM> _past = const [
    TenancyCardVM(
      id: 'p1',
      title: 'Yaba Heights • Flat 2A',
      location: 'Yaba, Lagos',
      rentNgn: 35000,
      dueLabel: '—',
      startLabel: 'Jan 2024',
      endLabel: 'Jan 2025',
      statusLabel: 'Completed',
    ),
    TenancyCardVM(
      id: 'p2',
      title: 'Ajah Prime • Unit 1C',
      location: 'Ajah, Lagos',
      rentNgn: 42000,
      dueLabel: '—',
      startLabel: 'Feb 2023',
      endLabel: 'Dec 2023',
      statusLabel: 'Terminated',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadMyViewings();
  }

  String _fmtNaira(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return '₦$buf';
  }

  void _openTenancies({String? focusId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TenanciesScreen(
          active: _active,
          past: _past,
          title: 'My Tenancies',
          subtitle: 'Active & past leases',
          initialTenancyId: focusId,
        ),
      ),
    );
  }

  void _openApplications() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MyApplicationsScreen(
          initialTab: ApplicationsTab.pending,
        ),
      ),
    );
  }

  void _openViewings() async {
    if (_myViewings.isEmpty && !_viewingsLoading) {
      await _loadMyViewings();
    }

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ViewingsScreen(
          title: "My Visits",
          viewings: _myViewings,
          fetchWhenEmpty: false,
        ),
      ),
    );
  }

  void _payRent(TenancyCardVM t) {
    PayRentSheet.open(context, title: t.title, amountNgn: t.rentNgn);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _active.length;

    final carouselH = (AppSpacing.xxxl * 6) + AppSpacing.md;
    final thumbW = (AppSpacing.xxxl * 3) + AppSpacing.md;
    final thumbR = AppRadii.button;

    final viewingsPill = _viewingsLoading
        ? "Loading…"
        : (_viewingsError != null
            ? "Tap to retry"
            : "${_upcomingCount} Upcoming");

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: const AppTopBar(title: 'Renting Tools', subtitle: ''),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH, // ✅ Aligned to Explore (Horizontal spacing)
            AppSpacing.sm,
            AppSpacing.screenH, // ✅ Aligned to Explore (Horizontal spacing)
            AppSizes.screenBottomPad,
          ),
          children: [
            Text(
              'Active Tenancies ($activeCount)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
            ),
            const SizedBox(height: AppSpacing.s10),

            SizedBox(
              height: carouselH,
              child: PageView.builder(
                controller: _pc,
                onPageChanged: (i) => setState(() => _idx = i),
                itemCount: _active.length,
                itemBuilder: (_, i) {
                  final t = _active[i];

                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s10),
                    child: _FrostCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(thumbR),
                              child: Container(
                                width: thumbW,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.overlay(
                                    context,
                                    AppSpacing.sm / AppSpacing.xxxl,
                                  ),
                                  border: Border.all(
                                    color: AppColors.overlay(
                                      context,
                                      AppSpacing.xs / AppSpacing.xxxl,
                                    ),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.home_rounded,
                                  size: AppSpacing.xxxl,
                                  color: AppColors.textMuted(context),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textPrimary(context),
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.event_rounded,
                                        size: AppSpacing.lg,
                                        color: AppColors.textMuted(context),
                                      ),
                                      const SizedBox(width: AppSpacing.s6),
                                      Expanded(
                                        child: Text(
                                          'Due ${t.dueLabel}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: AppColors
                                                    .textPrimary(context)
                                                    .withValues(alpha: 0.92),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _PillButton(
                                          text: 'View  ›',
                                          tone: _PillTone.blue,
                                          onTap: () =>
                                              _openTenancies(focusId: t.id),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.s10),
                                      Expanded(
                                        child: _PillButton(
                                          text: 'Pay ${_fmtNaira(t.rentNgn)}',
                                          tone: _PillTone.green,
                                          onTap: () => _payRent(t),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(thumbR),
                              child: Container(
                                width: AppSpacing.xxxl + AppSpacing.sm,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.overlay(
                                    context,
                                    AppSpacing.xs / AppSpacing.xxxl,
                                  ),
                                  border: Border.all(
                                    color: AppColors.overlay(
                                      context,
                                      AppSpacing.xs / AppSpacing.xxxl,
                                    ),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.photo_rounded,
                                  color: AppColors.textMuted(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.sm),
            _Dots(count: _active.length, index: _idx),

            const SizedBox(height: AppSpacing.xxl),

            _ToolTile(
              icon: Icons.home_rounded,
              title: 'My Tenancies',
              subtitle: 'Lease status, rent due date, landlord/agent contact',
              pillText: '$activeCount Active',
              pillTone: _PillTone.green,
              onTap: _openTenancies,
            ),
            const SizedBox(height: AppSpacing.md),

            _ToolTile(
              icon: Icons.description_rounded,
              title: 'My Applications',
              subtitle: 'Submitted, In Review, Approved, Rejected',
              pillText: '2 Pending',
              pillTone: _PillTone.warning,
              onTap: _openApplications,
            ),

            const SizedBox(height: AppSpacing.md),
            _ToolTile(
              icon: Icons.remove_red_eye_rounded,
              title: 'My Viewings',
              subtitle: _viewingsError != null
                  ? 'Couldn’t load viewings'
                  : 'Upcoming  Completed',
              pillText: viewingsPill,
              pillTone: _PillTone.blue,
              onTap: () async {
                if (_viewingsError != null) {
                  await _loadMyViewings(); // ✅ tap to retry
                  if (!mounted) return;
                }
                _openViewings();
              },
            ),

            if (_viewingsError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _viewingsError!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          AppColors.textMuted(context).withValues(alpha: 0.92),
                    ),
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'My Viewings: ${_upcomingCount} upcoming • ${_completedCount} completed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color:
                          AppColors.textMuted(context).withValues(alpha: 0.92),
                    ),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            Text(
              'Shortcuts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
            ),
            const SizedBox(height: AppSpacing.s10),

            Row(
              children: [
                Expanded(
                  child: _ShortcutChip(
                    icon: Icons.saved_search_rounded,
                    label: 'Saved Searches',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _ShortcutChip(
                    icon: Icons.verified_rounded,
                    label: 'Proof of Payment',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _ShortcutChip(
              icon: Icons.chat_bubble_rounded,
              label: 'Contact Landlord / Agent',
              fullWidth: true,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

/* ------------------ Small reusable UI (Explore style) ------------------ */

class _FrostCard extends StatelessWidget {
  const _FrostCard({required this.child});
  final Widget child;

  double get _alphaSurface =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _alphaBorder => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
  double get _alphaShadow => AppSpacing.xs / AppSpacing.xxxl;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: _alphaSurface),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.overlay(context, _alphaBorder)),
          boxShadow: AppShadows.lift(
            context,
            blur: AppSpacing.xxxl,
            y: AppSpacing.xl,
            alpha: _alphaShadow,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.card),
          child: child,
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final active = AppColors.brandGreenDeep;
    final idle = AppColors.overlay(context, 0.18);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s6),
          height: AppSpacing.s10,
          width: AppSpacing.s10,
          decoration: BoxDecoration(
            color: i == index ? active.withValues(alpha: 0.55) : idle,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: i == index ? active.withValues(alpha: 0.55) : idle,
            ),
          ),
        ),
      ),
    );
  }
}

enum _PillTone { blue, green, warning }

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.text,
    required this.tone,
    required this.onTap,
  });

  final String text;
  final _PillTone tone;
  final VoidCallback onTap;

  Color _toneColor() {
    switch (tone) {
      case _PillTone.blue:
        return AppColors.brandBlueSoft;
      case _PillTone.green:
        return AppColors.brandGreenDeep;
      case _PillTone.warning:
        // Safe fallback if AppColors.brandOrange missing
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _toneColor();
    final aFill = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

    return Material(
      color: c.withValues(alpha: aFill),
      borderRadius: BorderRadius.circular(AppRadii.pill), // ✅ Aligned to Pill
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.pill), // ✅ Aligned to Pill
        onTap: onTap,
        child: SizedBox(
          height: AppSizes.pillButtonHeight,
          child: Center(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.pillText,
    required this.pillTone,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String pillText;
  final _PillTone pillTone;
  final VoidCallback onTap;

  Color _toneColor() {
    switch (pillTone) {
      case _PillTone.blue:
        return AppColors.brandBlueSoft;
      case _PillTone.green:
        return AppColors.brandGreenDeep;
      case _PillTone.warning:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _toneColor();

    final alphaSurfaceStrong =
        AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);
    final alphaBorderSoft = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

    return _FrostCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  height: AppSizes.iconButtonBox,
                  width: AppSizes.iconButtonBox,
                  decoration: BoxDecoration(
                    color: AppColors.surface(context)
                        .withValues(alpha: alphaSurfaceStrong),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(
                      color: AppColors.overlay(context, alphaBorderSoft),
                    ),
                  ),
                  child: Icon(icon, color: AppColors.brandGreenDeep),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary(context),
                            ),
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted(context)
                                  .withValues(alpha: 0.92),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.s10,
                  ),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(color: c.withValues(alpha: 0.22)),
                  ),
                  child: Text(
                    pillText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary(context),
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

class _ShortcutChip extends StatelessWidget {
  const _ShortcutChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return _FrostCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: fullWidth
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.textMuted(context)),
                const SizedBox(width: AppSpacing.md),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary(context),
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