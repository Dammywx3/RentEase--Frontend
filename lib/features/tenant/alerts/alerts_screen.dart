import 'package:flutter/material.dart';

import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Alerts'),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenV,
          AppSpacing.s10,
          AppSpacing.screenV,
          AppSpacing.screenV,
        ),
        itemBuilder: (context, i) => Container(
          padding: const EdgeInsets.all(AppSpacing.screenV),
          decoration: BoxDecoration(
            color: AppColors.surface(context).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(AppRadii.button),
            border: Border.all(color: AppColors.overlay(context, 0.06)),
            boxShadow: AppShadows.lift(context, blur: 18, y: 10, alpha: 0.08),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.notifications_rounded,
                color: AppColors.brandGreenDeep,
              ),
              const SizedBox(width: AppSpacing.s10),
              Expanded(
                child: Text(
                  i == 0
                      ? 'New listing alert: 3-bedroom in Lekki'
                      : 'Price drop alert: ₦95,000,000 in Ikeja',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.s10),
        itemCount: 6,
      ),
    );
  }
}
