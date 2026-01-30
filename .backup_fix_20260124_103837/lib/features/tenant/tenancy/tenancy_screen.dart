import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/widgets/primary_button.dart';
import 'tenancy_detail_screen.dart';

class TenancyScreen extends StatelessWidget {
  const TenancyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Tenancy', subtitle: 'Overview & lease docs'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active Tenancy', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.md),
          const Text('Property: Modern 2 Bedroom Apartment\nNext Due: Feb 01, 2026\nRent: NGN 1,200,000'),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'View tenancy details',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TenancyDetailScreen()));
            },
          ),
        ],
      ),
    );
  }
}
