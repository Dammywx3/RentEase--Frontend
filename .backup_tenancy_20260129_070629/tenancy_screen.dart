import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import '../../../shared/widgets/primary_button.dart';

import 'tenancy_detail_screen.dart';
import 'pay_rent/pay_rent_sheet.dart';

class TenancyScreen extends StatelessWidget {
  const TenancyScreen({
    super.key,
    required this.tenancy,
  });

  final TenancyOverviewVM tenancy;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: AppTopBar(
        title: tenancy.title ?? 'Tenancy',
        subtitle: tenancy.subtitle ?? 'Overview & lease docs',
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenH,
          AppSpacing.sm,
          AppSpacing.screenH,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tenancy.sectionTitle ?? 'Active Tenancy',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary(context),
                  ),
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              tenancy.summary ?? '—',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary(context),
                  ),
            ),

            const SizedBox(height: AppSpacing.lg),

            PrimaryButton(
              label: 'Pay rent',
              onPressed: tenancy.payAmountNgn == null
                  ? null
                  : () {
                      PayRentSheet.open(
                        context,
                        title: tenancy.payTitle ?? 'Rent',
                        amountNgn: tenancy.payAmountNgn!,
                      );
                    },
            ),
            const SizedBox(height: AppSpacing.md),

            PrimaryButton(
              label: 'View tenancy details',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TenancyDetailScreen(
                      tenancy: TenancyVM(
                        id: tenancy.id,
                        title: tenancy.payTitle ?? tenancy.title ?? 'Tenancy Detail',
                        subtitle: tenancy.subtitle,
                        leaseDocName: tenancy.leaseDocName,
                        nextRentAmountNgn: tenancy.payAmountNgn,
                      ),
                    ),
                  ),
                );
              },
            ),

            const Spacer(),
            SizedBox(height: AppSizes.screenBottomPad / (AppSpacing.xxxl / AppSpacing.md)),
          ],
        ),
      ),
    );
  }
}

/* ----------------- VM ----------------- */

class TenancyOverviewVM {
  const TenancyOverviewVM({
    required this.id,
    this.title,
    this.subtitle,
    this.sectionTitle,
    this.summary,
    this.payTitle,
    this.payAmountNgn,
    this.leaseDocName,
  });

  final String id;

  final String? title;
  final String? subtitle;

  final String? sectionTitle;
  final String? summary;

  final String? payTitle;
  final int? payAmountNgn;

  final String? leaseDocName;
}