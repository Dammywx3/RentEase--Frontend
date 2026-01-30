import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/constants/status_badge_map.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({
    super.key,
    required this.listing,
    required this.saved,
    required this.onToggleSaved,
  });

  final ListingModel listing;
  final bool saved;
  final VoidCallback onToggleSaved;

  bool get _ctaDisabled {
    final ps = (listing.propertyStatus ?? '').toLowerCase();
    return ps == 'occupied' || ps == 'maintenance' || ps == 'unavailable';
  }

  String get _ctaDisabledReason {
    final ps = (listing.propertyStatus ?? '').toLowerCase();
    if (ps == 'occupied') {
      return 'Occupied';
    }
    if (ps == 'maintenance') {
      return 'Under maintenance';
    }
    if (ps == 'unavailable') {
      return 'Unavailable';
    }
    return 'Not available';
  }

  @override
  Widget build(BuildContext context) {
    final priceText =
        '${listing.currency} ${listing.price.toStringAsFixed(0)} / year';

    return AppScaffold(
      topBar: AppTopBar(
        title: 'Listing Detail',
        subtitle: listing.location,
        actions: [
          IconButton(
            onPressed: onToggleSaved,
            icon: Icon(
              saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media carousel placeholder
          Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: Text(
                'Media Carousel (MVP)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: Text(
                  listing.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              StatusBadge(
                domain: StatusDomain.listing,
                status: listing.status,
                compact: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            priceText,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),

          if ((listing.propertyStatus ?? '').isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Availability: ${listing.propertyStatus}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Amenities placeholder
          Text(
            'Amenities',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              Chip(label: Text('Parking')),
              Chip(label: Text('Security')),
              Chip(label: Text('Water')),
              Chip(label: Text('Power backup')),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // CTA row
          if (_ctaDisabled) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.error.withAlpha(18),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withAlpha(90),
                ),
              ),
              child: Text('CTAs disabled: $_ctaDisabledReason'),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          PrimaryButton(
            label: _ctaDisabled ? 'Apply (Disabled)' : 'Apply',
            onPressed: _ctaDisabled
                ? null
                : () => ToastService.show(
                    context,
                    'Apply entry (wire to backend)',
                    success: true,
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: _ctaDisabled ? 'Book Viewing (Disabled)' : 'Book Viewing',
            onPressed: _ctaDisabled
                ? null
                : () => ToastService.show(
                    context,
                    'Book viewing entry (wire to backend)',
                    success: true,
                  ),
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => ToastService.show(
                    context,
                    'Chat entry (Phase 2)',
                    success: true,
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  label: const Text('Chat'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onToggleSaved,
                  icon: Icon(
                    saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                  ),
                  label: Text(saved ? 'Saved' : 'Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
