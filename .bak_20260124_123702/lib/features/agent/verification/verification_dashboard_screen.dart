import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/widgets/primary_button.dart';
import 'property_verification_detail_screen.dart';
import 'document_review_list_screen.dart';

class VerificationDashboardScreen extends StatelessWidget {
  const VerificationDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Verification', subtitle: 'Properties & documents'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.md),
          const Text('MVP: only UI. Wire permissions + endpoints later.'),
          const SizedBox(height: AppSpacing.lg),

          PrimaryButton(
            label: 'Property verification',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PropertyVerificationDetailScreen())),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DocumentReviewListScreen())),
            icon: const Icon(Icons.fact_check_rounded),
            label: const Text('Document reviews'),
          ),
        ],
      ),
    );
  }
}
