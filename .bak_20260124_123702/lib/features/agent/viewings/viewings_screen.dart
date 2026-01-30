import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../core/ui/states/empty_state.dart';
import '../../../shared/widgets/status_badge.dart';
import 'viewing_detail_screen.dart';

class ViewingsScreen extends StatefulWidget {
  const ViewingsScreen({super.key});

  @override
  State<ViewingsScreen> createState() => _ViewingsScreenState();
}

class _ViewingsScreenState extends State<ViewingsScreen> {
  String _tab = 'Pending';

  final _items = const [
    _Row(id: 'vw1', title: 'Modern 2 Bedroom Apartment', date: 'Jan 25, 2026 • 2:00 PM', status: 'pending', mode: 'In-person'),
    _Row(id: 'vw2', title: 'Family Duplex (4 Beds)', date: 'Jan 26, 2026 • 11:00 AM', status: 'approved', mode: 'Virtual'),
    _Row(id: 'vw3', title: 'Cozy Studio', date: 'Jan 20, 2026 • 4:30 PM', status: 'rejected', mode: 'In-person'),
    _Row(id: 'vw4', title: 'Old Listing (Needs renew)', date: 'Jan 10, 2026 • 9:00 AM', status: 'completed', mode: 'In-person'),
    _Row(id: 'vw5', title: 'Rejected Listing', date: 'Dec 30, 2025 • 1:00 PM', status: 'cancelled', mode: 'Virtual'),
  ];

  List<_Row> get _filtered {
    switch (_tab) {
      case 'Pending':
        return _items.where((x) => x.status == 'pending').toList();
      case 'Approved':
        return _items.where((x) => x.status == 'approved').toList();
      case 'Rejected':
        return _items.where((x) => x.status == 'rejected').toList();
      case 'Completed':
        return _items.where((x) => x.status == 'completed').toList();
      case 'Cancelled':
        return _items.where((x) => x.status == 'cancelled').toList();
      default:
        return _items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return AppScaffold(
      topBar: const AppTopBar(title: 'Viewings', subtitle: 'Approve / reschedule / complete'),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TabChip(label: 'Pending', active: _tab == 'Pending', onTap: () => setState(() => _tab = 'Pending')),
                _TabChip(label: 'Approved', active: _tab == 'Approved', onTap: () => setState(() => _tab = 'Approved')),
                _TabChip(label: 'Rejected', active: _tab == 'Rejected', onTap: () => setState(() => _tab = 'Rejected')),
                _TabChip(label: 'Completed', active: _tab == 'Completed', onTap: () => setState(() => _tab = 'Completed')),
                _TabChip(label: 'Cancelled', active: _tab == 'Cancelled', onTap: () => setState(() => _tab = 'Cancelled')),
                _TabChip(label: 'All', active: _tab == 'All', onTap: () => setState(() => _tab = 'All')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    title: 'No viewings here',
                    message: 'New viewing requests will show up here.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final x = items[i];

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ViewingDetailScreen(
                              viewingId: x.id,
                              title: x.title,
                              status: x.status,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.35)),
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.15),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(child: Icon(Icons.event_available_rounded)),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            x.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        StatusBadge(domain: StatusDomain.viewing, status: x.status, compact: true),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(x.date, style: Theme.of(context).textTheme.bodySmall),
                                    const SizedBox(height: 4),
                                    Text('Mode: ${x.mode}', style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
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

class _Row {
  const _Row({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
    required this.mode,
  });

  final String id;
  final String title;
  final String date;
  final String status;
  final String mode;
}
