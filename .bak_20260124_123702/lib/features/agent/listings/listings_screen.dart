import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../core/ui/states/empty_state.dart';
import '../../../shared/widgets/card_widgets/listing_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/services/toast_service.dart';
import 'listing_detail_screen.dart';
import 'create_listing/create_listing_stepper.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  String _tab = 'Active';

  final _items = const [
    _ListingRow(id: 'al1', title: 'Modern 2 Bedroom Apartment', location: 'Lekki, Lagos', status: 'active', price: 'NGN 1,200,000', meta: 'Apartment • 2 bed • 2 bath'),
    _ListingRow(id: 'al2', title: 'Family Duplex (4 Beds)', location: 'Ikeja, Lagos', status: 'pending_owner_approval', price: 'NGN 3,500,000', meta: 'Duplex • 4 bed • 4 bath'),
    _ListingRow(id: 'al3', title: 'Cozy Studio', location: 'Yaba, Lagos', status: 'draft', price: 'NGN 450,000', meta: 'Studio • 1 bed • 1 bath'),
    _ListingRow(id: 'al4', title: 'Old Listing (Needs renew)', location: 'Surulere, Lagos', status: 'expired', price: 'NGN 900,000', meta: 'Flat • 2 bed • 1 bath'),
    _ListingRow(id: 'al5', title: 'Rejected Listing', location: 'Ajah, Lagos', status: 'rejected', price: 'NGN 700,000', meta: 'Flat • 1 bed • 1 bath'),
  ];

  List<_ListingRow> get _filtered {
    switch (_tab) {
      case 'Draft':
        return _items.where((x) => x.status == 'draft').toList();
      case 'Pending':
        return _items.where((x) => x.status == 'pending_owner_approval').toList();
      case 'Rejected':
        return _items.where((x) => x.status == 'rejected').toList();
      case 'Expired':
        return _items.where((x) => x.status == 'expired').toList();
      case 'Paused':
        return _items.where((x) => x.status == 'paused').toList();
      default:
        return _items.where((x) => x.status == 'active').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return AppScaffold(
      topBar: AppTopBar(
        title: 'Listings',
        subtitle: 'Create & manage listings',
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateListingStepper())),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      child: Column(
        children: [
          PrimaryButton(
            label: 'Create new listing',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateListingStepper())),
          ),
          const SizedBox(height: AppSpacing.lg),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TabChip(label: 'Draft', active: _tab == 'Draft', onTap: () => setState(() => _tab = 'Draft')),
                _TabChip(label: 'Pending', active: _tab == 'Pending', onTap: () => setState(() => _tab = 'Pending')),
                _TabChip(label: 'Active', active: _tab == 'Active', onTap: () => setState(() => _tab = 'Active')),
                _TabChip(label: 'Paused', active: _tab == 'Paused', onTap: () => setState(() => _tab = 'Paused')),
                _TabChip(label: 'Rejected', active: _tab == 'Rejected', onTap: () => setState(() => _tab = 'Rejected')),
                _TabChip(label: 'Expired', active: _tab == 'Expired', onTap: () => setState(() => _tab = 'Expired')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    title: 'No listings here',
                    message: 'Create a listing to get started.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    itemCount: items.length,
                    separatorBuilder: (_, i) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final x = items[i];

                      return ListingCard(
                        title: x.title,
                        location: x.location,
                        priceText: x.price,
                        status: x.status,
                        meta: x.meta,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: x.id, title: x.title, status: x.status)),
                        ),
                        primaryActionText: x.status == 'draft' ? 'Edit' : 'Manage',
                        onPrimaryAction: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: x.id, title: x.title, status: x.status)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        selected: active,
        label: Text(label),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _ListingRow {
  const _ListingRow({
    required this.id,
    required this.title,
    required this.location,
    required this.status,
    required this.price,
    required this.meta,
  });

  final String id;
  final String title;
  final String location;
  final String status;
  final String price;
  final String meta;
}
