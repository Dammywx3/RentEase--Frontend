import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';

import '../../../shared/services/dialog_service.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';

import 'pay_rent/pay_rent_sheet.dart';

class TenancyDetailScreen extends StatelessWidget {
  const TenancyDetailScreen({
    super.key,
    required this.tenancy,
  });

  final TenancyVM tenancy;

  @override
  Widget build(BuildContext context) {
    final title = tenancy.title.trim().isEmpty ? 'Tenancy Detail' : tenancy.title;

    return AppScaffold(
      topBar: AppTopBar(
        title: title,
        subtitle: tenancy.subtitle ?? 'Timeline & actions',
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
            _SectionTitle('Lease Documents'),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: tenancy.leaseDocName == null
                  ? null
                  : () => ToastService.show(
                        context,
                        'Open lease doc (wire later)',
                        success: true,
                      ),
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: Text(tenancy.leaseDocName ?? 'No document'),
            ),
            const SizedBox(height: AppSpacing.lg),

            _SectionTitle('Payments'),
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: 'Pay rent',
              onPressed: tenancy.nextRentAmountNgn == null
                  ? null
                  : () {
                      PayRentSheet.open(
                        context,
                        title: tenancy.title,
                        amountNgn: tenancy.nextRentAmountNgn!,
                      );
                    },
            ),
            const SizedBox(height: AppSpacing.lg),

            _SectionTitle('End Tenancy'),
            const SizedBox(height: AppSpacing.sm),
            PrimaryButton(
              label: 'Request end tenancy',
              onPressed: () => ToastService.show(
                context,
                'End tenancy form (wire later)',
                success: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Cancel request',
              onPressed: () async {
                final ok = await DialogService.confirm(
                  context,
                  title: 'Cancel end request?',
                  message: 'Your tenancy will remain active.',
                  confirmText: 'Cancel request',
                  danger: true,
                );
                if (ok && context.mounted) {
                  ToastService.show(context, 'Cancelled (demo)', success: true);
                }
              },
            ),

            const Spacer(),

            // Optional: subtle footer spacing (token-only)
            SizedBox(height: AppSizes.screenBottomPad / (AppSpacing.xxxl / AppSpacing.md)),
          ],
        ),
      ),
    );
  }
}

/* ----------------- VM ----------------- */

class TenancyVM {
  const TenancyVM({
    required this.id,
    required this.title,
    this.subtitle,
    this.leaseDocName,
    this.nextRentAmountNgn,
  });

  final String id;
  final String title;
  final String? subtitle;

  final String? leaseDocName;
  final int? nextRentAmountNgn;
}

/* ----------------- UI ----------------- */

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