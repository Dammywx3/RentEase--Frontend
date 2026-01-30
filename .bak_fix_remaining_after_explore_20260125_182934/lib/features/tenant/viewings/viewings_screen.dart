import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../core/ui/states/empty_state.dart';
import '../../../shared/widgets/card_widgets/viewing_card.dart';
import 'viewing_detail_screen.dart';

class ViewingsScreen extends StatefulWidget {
  const ViewingsScreen({super.key});

  @override
  State<ViewingsScreen> createState() => _ViewingsScreenState();
}

class _ViewingsScreenState extends State<ViewingsScreen> {
  String _tab = 'Upcoming';

  final _items = const [
    _ViewingRow(
      id: 'v1',
      title: 'Modern 2 Bedroom Apartment',
      when: 'Jan 25 • 2:00 PM',
      mode: 'In-person',
      status: 'approved',
    ),
    _ViewingRow(
      id: 'v2',
      title: 'Studio (Close to Road)',
      when: 'Jan 26 • 11:00 AM',
      mode: 'Virtual',
      status: 'pending',
    ),
    _ViewingRow(
      id: 'v3',
      title: 'Family Duplex (4 Beds)',
      when: 'Jan 02 • 3:00 PM',
      mode: 'In-person',
      status: 'completed',
    ),
  ];

  List<_ViewingRow> get _filtered {
    // MVP: map tabs to statuses loosely
    switch (_tab) {
      case 'Pending':
        return _items.where((x) => x.status == 'pending').toList();
      case 'Completed':
        return _items.where((x) => x.status == 'completed').toList();
      case 'Cancelled':
        return _items.where((x) => x.status == 'cancelled').toList();
      default:
        return _items
            .where((x) => x.status == 'approved' || x.status == 'pending')
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return AppScaffold(
      scroll: false,

      topBar: const AppTopBar(
        title: 'My Viewings',
        subtitle: 'Manage your schedule',
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TabChip(
                  label: 'Upcoming',
                  active: _tab == 'Upcoming',
                  onTap: () => setState(() => _tab = 'Upcoming'),
                ),
                _TabChip(
                  label: 'Pending',
                  active: _tab == 'Pending',
                  onTap: () => setState(() => _tab = 'Pending'),
                ),
                _TabChip(
                  label: 'Completed',
                  active: _tab == 'Completed',
                  onTap: () => setState(() => _tab = 'Completed'),
                ),
                _TabChip(
                  label: 'Cancelled',
                  active: _tab == 'Cancelled',
                  onTap: () => setState(() => _tab = 'Cancelled'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    title: 'No viewings yet',
                    message: 'Book a viewing from any listing.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    itemCount: items.length,
                    separatorBuilder: (_, i) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final x = items[i];
                      return ViewingCard(
                        propertyTitle: x.title,
                        dateTimeText: x.when,
                        modeText: x.mode,
                        status: x.status,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ViewingDetailScreen(
                                viewingId: x.id,
                                title: x.title,
                                status: x.status,
                              ),
                            ),
                          );
                        },
                        primaryActionText: x.status == 'pending'
                            ? 'Cancel'
                            : 'View',
                        onPrimaryAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ViewingDetailScreen(
                                viewingId: x.id,
                                title: x.title,
                                status: x.status,
                              ),
                            ),
                          );
                        },
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
  const _TabChip({
    required this.label,
    required this.active,
    required this.onTap,
  });
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

class _ViewingRow {
  const _ViewingRow({
    required this.id,
    required this.title,
    required this.when,
    required this.mode,
    required this.status,
  });
  final String id;
  final String title;
  final String when;
  final String mode;
  final String status;
}
