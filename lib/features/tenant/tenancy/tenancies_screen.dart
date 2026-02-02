// lib/features/tenant/tenancies/tenancies_screen.dart
// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import '../maintenance/create_request_screen.dart';
import 'pay_rent/pay_rent_sheet.dart';

class TenanciesScreen extends StatefulWidget {
  const TenanciesScreen({
    super.key,
    required this.active,
    required this.past,
    this.title,
    this.subtitle,
    this.initialTenancyId,
  });

  final List<TenancyCardVM> active;
  final List<TenancyCardVM> past;

  final String? title;
  final String? subtitle;

  // Optional: if passed, open details for that tenancy after first frame
  final String? initialTenancyId;

  @override
  State<TenanciesScreen> createState() => _TenanciesScreenState();
}

class _TenanciesScreenState extends State<TenanciesScreen> {
  int _tab = 0; // 0=Active, 1=Past

  // ---------- Explore-style helpers (no hardcoded alphas) ----------
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaSurface =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  double get _alphaMutedText => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = widget.initialTenancyId;
      if (!mounted || id == null) return;

      final found = widget.active.where((e) => e.id == id).toList();
      if (found.isEmpty) return;

      _openDetails(found.first);
    });
  }

  void _openDetails(TenancyCardVM t) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _TenancyDetailsScreen(tenancy: t)),
    );
  }

  void _openPaySheet(TenancyCardVM t) {
    PayRentSheet.open(context, title: t.title, amountNgn: t.rentNgn);
  }

  @override
  Widget build(BuildContext context) {
    final list = _tab == 0 ? widget.active : widget.past;
    final activeCount = widget.active.length;
    final featuredActive = widget.active.isNotEmpty ? widget.active.first : null;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: AppTopBar(title: widget.title ?? 'My Tenancies'),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenV,
            AppSpacing.sm,
            AppSpacing.screenV,
            AppSizes.screenBottomPad,
          ),
          children: [
            if ((widget.subtitle ?? '').trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  widget.subtitle!.trim(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted(context)
                            .withValues(alpha: _alphaMutedText),
                      ),
                ),
              ),

            if (featuredActive != null) ...[
              _ActiveTenancyHeroCard(
                tenancy: featuredActive,
                alphaBorderSoft: _alphaBorderSoft,
                alphaSurfaceStrong: _alphaSurfaceStrong,
                alphaShadowSoft: _alphaShadowSoft,
                onTap: () => _openDetails(featuredActive),
                onPayTap: () => _openPaySheet(featuredActive),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            _SegmentTabs(
              left: 'Active ($activeCount)',
              right: 'Past',
              value: _tab,
              alphaSurfaceStrong: _alphaSurfaceStrong,
              alphaBorderSoft: _alphaBorderSoft,
              onChanged: (v) => setState(() => _tab = v),
            ),
            const SizedBox(height: AppSpacing.md),

            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xxl),
                child: Center(
                  child: Text(
                    'No tenancies',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textMuted(context),
                        ),
                  ),
                ),
              )
            else
              ...list.map((t) {
                final isActive = _tab == 0;

                final statusColor = isActive
                    ? AppColors.brandGreenDeep
                    : AppColors.textMuted(context);

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _FrostCard(
                    alphaSurface: _alphaSurface,
                    alphaBorderSoft: _alphaBorderSoft,
                    alphaShadowSoft: _alphaShadowSoft,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.sm),
                                child: Container(
                                  height: AppSizes.listThumbSize,
                                  width: AppSizes.listThumbSize + AppSpacing.md,
                                  color: AppColors.surface(context).withValues(
                                    alpha: _alphaSurfaceStrong,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.home_rounded,
                                    color: AppColors.brandBlueSoft,
                                    size: AppSpacing.xxl,
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color:
                                                AppColors.textPrimary(context),
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      '${t.location} • ${t.startLabel} – ${t.endLabel}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textMuted(context)
                                                .withValues(
                                                    alpha: _alphaMutedText),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s10,
                                  vertical: AppSpacing.s6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(
                                    alpha:
                                        AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs),
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.pill),
                                  border: Border.all(
                                    color: statusColor.withValues(
                                      alpha:
                                          AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  t.statusLabel,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s10),
                          Row(
                            children: [
                              _MiniInfo(
                                icon: Icons.payments_rounded,
                                text: '${t.rentText()} / month',
                                alphaMutedText: _alphaMutedText,
                              ),
                              const SizedBox(width: AppSpacing.s10),
                              _MiniInfo(
                                icon: Icons.event_rounded,
                                text: isActive
                                    ? 'Next due: ${t.dueLabel}'
                                    : '${t.startLabel} – ${t.endLabel}',
                                alphaMutedText: _alphaMutedText,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: _PillButton(
                                  text: isActive
                                      ? (t.dealType == TenancyDealType.rent
                                          ? 'Pay rent'
                                          : 'View details')
                                      : 'View details',
                                  filled: true,
                                  color: isActive
                                      ? AppColors.brandBlueSoft
                                      : AppColors.brandGreenDeep,
                                  alphaBorderSoft: _alphaBorderSoft,
                                  alphaSurfaceStrong: _alphaSurfaceStrong,
                                  alphaMutedText: _alphaMutedText,
                                  onTap: () => isActive &&
                                          t.dealType == TenancyDealType.rent
                                      ? _openPaySheet(t)
                                      : _openDetails(t),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s10),
                              Expanded(
                                child: _PillButton(
                                  text: 'View details',
                                  filled: false,
                                  color: AppColors.brandBlueSoft,
                                  alphaBorderSoft: _alphaBorderSoft,
                                  alphaSurfaceStrong: _alphaSurfaceStrong,
                                  alphaMutedText: _alphaMutedText,
                                  onTap: () => _openDetails(t),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s10),
                          Wrap(
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.sm,
                            children: [
                              if (t.dealType == TenancyDealType.buyLand)
                                _LinkChip(
                                  icon: Icons.gavel_rounded,
                                  text: 'Deed of agreement',
                                  alphaSurface: _alphaSurface,
                                  alphaBorderSoft: _alphaBorderSoft,
                                  alphaMutedText: _alphaMutedText,
                                  onTap: () {},
                                )
                              else
                                _LinkChip(
                                  icon: Icons.build_rounded,
                                  text: 'Request maintenance',
                                  alphaSurface: _alphaSurface,
                                  alphaBorderSoft: _alphaBorderSoft,
                                  alphaMutedText: _alphaMutedText,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CreateMaintenanceRequestScreen(
                                          addressLabel: t.location,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              _LinkChip(
                                icon: Icons.chat_rounded,
                                text: t.dealType == TenancyDealType.buyLand
                                    ? 'Contact landowner/agent'
                                    : 'Contact landlord/agent',
                                alphaSurface: _alphaSurface,
                                alphaBorderSoft: _alphaBorderSoft,
                                alphaMutedText: _alphaMutedText,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

/* ---------------------- View Model ---------------------- */

enum TenancyDealType { rent, buyLand }

class TenancyCardVM {
  const TenancyCardVM({
    required this.id,
    required this.title,
    required this.location,
    required this.rentNgn,
    required this.dueLabel,
    required this.startLabel,
    required this.endLabel,
    required this.statusLabel,
    this.dealType = TenancyDealType.rent,
  });

  final String id;
  final String title;
  final String location;
  final int rentNgn;
  final String dueLabel;
  final String startLabel;
  final String endLabel;
  final String statusLabel;
  final TenancyDealType dealType;

  String rentText() {
    final s = rentNgn.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return '₦$buf';
  }
}

/* ---------------------- Top Featured Card ---------------------- */

class _ActiveTenancyHeroCard extends StatelessWidget {
  const _ActiveTenancyHeroCard({
    required this.tenancy,
    required this.alphaBorderSoft,
    required this.alphaSurfaceStrong,
    required this.alphaShadowSoft,
    required this.onTap,
    required this.onPayTap,
  });

  final TenancyCardVM tenancy;
  final double alphaBorderSoft;
  final double alphaSurfaceStrong;
  final double alphaShadowSoft;
  final VoidCallback onTap;
  final VoidCallback onPayTap;

  @override
  Widget build(BuildContext context) {
    final border = AppColors.overlay(context, alphaBorderSoft);
    final shadow = AppShadows.lift(
      context,
      blur: AppSpacing.xxxl + AppSpacing.lg,
      y: AppSpacing.xl,
      alpha: alphaShadowSoft,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: shadow,
          border: Border.all(color: border),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.brandBlueSoft.withValues(alpha: alphaBorderSoft),
              AppColors.brandGreenDeep.withValues(alpha: alphaBorderSoft),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.s6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context)
                          .withValues(alpha: alphaSurfaceStrong),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                        color: AppColors.overlay(context, alphaBorderSoft),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: AppColors.brandGreenDeep.withValues(
                            alpha: alphaSurfaceStrong,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Active tenancy',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary(context),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted(context)
                        .withValues(alpha: alphaSurfaceStrong),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                tenancy.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary(context),
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                tenancy.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted(context)
                          .withValues(alpha: alphaSurfaceStrong),
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _HeroChip(
                      icon: Icons.payments_rounded,
                      text: '${tenancy.rentText()}/mo',
                      alphaSurfaceStrong: alphaSurfaceStrong,
                      alphaBorderSoft: alphaBorderSoft,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _HeroChip(
                      icon: Icons.event_rounded,
                      text: 'Next due ${tenancy.dueLabel}',
                      alphaSurfaceStrong: alphaSurfaceStrong,
                      alphaBorderSoft: alphaBorderSoft,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _HeroChip(
                      icon: Icons.info_rounded,
                      text: tenancy.statusLabel,
                      alphaSurfaceStrong: alphaSurfaceStrong,
                      alphaBorderSoft: alphaBorderSoft,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _PillButton(
                      text: tenancy.dealType == TenancyDealType.rent
                          ? 'Pay rent'
                          : 'View details',
                      filled: true,
                      color: AppColors.brandBlueSoft,
                      alphaBorderSoft: alphaBorderSoft,
                      alphaSurfaceStrong: alphaSurfaceStrong,
                      alphaMutedText: alphaSurfaceStrong,
                      onTap: tenancy.dealType == TenancyDealType.rent
                          ? onPayTap
                          : onTap,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s10),
                  Expanded(
                    child: _PillButton(
                      text: 'View details',
                      filled: false,
                      color: AppColors.brandGreenDeep,
                      alphaBorderSoft: alphaBorderSoft,
                      alphaSurfaceStrong: alphaSurfaceStrong,
                      alphaMutedText: alphaSurfaceStrong,
                      onTap: onTap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.text,
    required this.alphaSurfaceStrong,
    required this.alphaBorderSoft,
  });

  final IconData icon;
  final String text;
  final double alphaSurfaceStrong;
  final double alphaBorderSoft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: alphaSurfaceStrong),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.overlay(context, alphaBorderSoft)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.textMuted(context)
                .withValues(alpha: alphaSurfaceStrong),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------------- Details Screen ---------------------- */

class _TenancyDetailsScreen extends StatelessWidget {
  const _TenancyDetailsScreen({required this.tenancy});
  final TenancyCardVM tenancy;

  // Explore-style helpers
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaSurface =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  double get _alphaMutedText => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: AppTopBar(title: tenancy.title),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenV,
            AppSpacing.sm,
            AppSpacing.screenV,
            AppSizes.screenBottomPad,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                tenancy.location,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted(context)
                          .withValues(alpha: _alphaMutedText),
                    ),
              ),
            ),
            _FrostCard(
              alphaSurface: _alphaSurface,
              alphaBorderSoft: _alphaBorderSoft,
              alphaShadowSoft: _alphaShadowSoft,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary(context),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${tenancy.startLabel} – ${tenancy.endLabel}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary(context),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Rent & Payments',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary(context),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _KVRow(
                      label: 'Monthly rent',
                      value: '${tenancy.rentText()} / month',
                      alphaMutedText: _alphaMutedText,
                    ),
                    _KVRow(
                      label: 'Next due date',
                      value: tenancy.dueLabel,
                      alphaMutedText: _alphaMutedText,
                    ),
                    _KVRow(
                      label: 'Status',
                      value: tenancy.statusLabel,
                      alphaMutedText: _alphaMutedText,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _PillButton(
                      text: tenancy.dealType == TenancyDealType.rent
                          ? 'Pay now'
                          : 'View details',
                      filled: true,
                      color: AppColors.brandGreenDeep,
                      alphaBorderSoft: _alphaBorderSoft,
                      alphaSurfaceStrong: _alphaSurfaceStrong,
                      alphaMutedText: _alphaMutedText,
                      onTap: tenancy.dealType == TenancyDealType.rent
                          ? () => PayRentSheet.open(
                                context,
                                title: tenancy.title,
                                amountNgn: tenancy.rentNgn,
                              )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------------- UI Bits ---------------------- */

class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs({
    required this.left,
    required this.right,
    required this.value,
    required this.alphaSurfaceStrong,
    required this.alphaBorderSoft,
    required this.onChanged,
  });

  final String left;
  final String right;
  final int value;
  final double alphaSurfaceStrong;
  final double alphaBorderSoft;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.pillButtonHeight,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: alphaSurfaceStrong),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.overlay(context, alphaBorderSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegBtn(
              text: left,
              active: value == 0,
              alphaBorderSoft: alphaBorderSoft,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: AppSpacing.s6),
          Expanded(
            child: _SegBtn(
              text: right,
              active: value == 1,
              alphaBorderSoft: alphaBorderSoft,
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
    required this.alphaBorderSoft,
    required this.onTap,
  });

  final String text;
  final bool active;
  final double alphaBorderSoft;
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
          color: active ? blue.withValues(alpha: alphaBorderSoft) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(
            color: active ? blue.withValues(alpha: alphaBorderSoft) : Colors.transparent,
          ),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary(context),
              ),
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  const _MiniInfo({
    required this.icon,
    required this.text,
    required this.alphaMutedText,
  });

  final IconData icon;
  final String text;
  final double alphaMutedText;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSpacing.lg,
            color: AppColors.textMuted(context).withValues(alpha: alphaMutedText),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
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
  }
}

class _LinkChip extends StatelessWidget {
  const _LinkChip({
    required this.icon,
    required this.text,
    required this.alphaSurface,
    required this.alphaBorderSoft,
    required this.alphaMutedText,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final double alphaSurface;
  final double alphaBorderSoft;
  final double alphaMutedText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface(context).withValues(alpha: alphaSurface),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AppColors.overlay(context, alphaBorderSoft)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppSpacing.lg,
              color: AppColors.textMuted(context).withValues(alpha: alphaMutedText),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              text,
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

class _KVRow extends StatelessWidget {
  const _KVRow({
    required this.label,
    required this.value,
    required this.alphaMutedText,
  });

  final String label;
  final String value;
  final double alphaMutedText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted(context)
                        .withValues(alpha: alphaMutedText),
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary(context),
                ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.text,
    required this.onTap,
    required this.filled,
    required this.color,
    required this.alphaBorderSoft,
    required this.alphaSurfaceStrong,
    required this.alphaMutedText,
  });

  final String text;
  final VoidCallback? onTap;
  final bool filled;
  final Color color;

  final double alphaBorderSoft;
  final double alphaSurfaceStrong;
  final double alphaMutedText;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.button),
      child: Container(
        height: AppSizes.minTap,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: disabled
              ? AppColors.overlay(context, alphaBorderSoft)
              : (filled
                  ? color.withValues(alpha: alphaSurfaceStrong)
                  : Colors.transparent),
          borderRadius: BorderRadius.circular(AppRadii.button),
          border: Border.all(
            color: disabled
                ? AppColors.overlay(context, alphaBorderSoft)
                : color.withValues(alpha: alphaBorderSoft),
          ),
          boxShadow: filled && !disabled
              ? AppShadows.soft(
                  context,
                  blur: AppSpacing.xxxl,
                  y: AppSpacing.xl,
                  alpha: AppSpacing.xs / AppSpacing.xxxl,
                )
              : null,
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: disabled
                    ? AppColors.textMuted(context)
                        .withValues(alpha: alphaMutedText)
                    : (filled ? AppColors.white : AppColors.textPrimary(context)),
              ),
        ),
      ),
    );
  }
}

class _FrostCard extends StatelessWidget {
  const _FrostCard({
    required this.child,
    required this.alphaSurface,
    required this.alphaBorderSoft,
    required this.alphaShadowSoft,
  });

  final Widget child;
  final double alphaSurface;
  final double alphaBorderSoft;
  final double alphaShadowSoft;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: alphaSurface),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.overlay(context, alphaBorderSoft)),
        boxShadow: AppShadows.lift(
          context,
          blur: AppSpacing.xxxl + AppSpacing.lg,
          y: AppSpacing.xl,
          alpha: alphaShadowSoft,
        ),
      ),
      child: child,
    );
  }
}