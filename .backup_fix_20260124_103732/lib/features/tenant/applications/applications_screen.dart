import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../core/ui/states/empty_state.dart';
import '../../../shared/widgets/card_widgets/application_card.dart';
import 'application_detail_screen.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  String _tab = 'All';

  final _items = const [
    _AppRow(id: 'a1', title: 'Modern 2 Bedroom Apartment', status: 'pending', date: 'Jan 10, 2026'),
    _AppRow(id: 'a2', title: 'Family Duplex (4 Beds)', status: 'approved', date: 'Jan 06, 2026'),
    _AppRow(id: 'a3', title: 'Studio (Close to Road)', status: 'rejected', date: 'Dec 29, 2025'),
  ];

  List<_AppRow> get _filtered {
    if (_tab == 'All') return _items;
    return _items.where((x) => x.status.toLowerCase() == _tab.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return AppScaffold(
      topBar: const AppTopBar(title: 'My Applications', subtitle: 'Track application status'),
      child: Column(
        children: [
          // tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _TabChip(label: 'All', active: _tab == 'All', onTap: () => setState(() => _tab = 'All')),
                _TabChip(label: 'pending', active: _tab == 'pending', onTap: () => setState(() => _tab = 'pending')),
                _TabChip(label: 'approved', active: _tab == 'approved', onTap: () => setState(() => _tab = 'approved')),
                _TabChip(label: 'rejected', active: _tab == 'rejected', onTap: () => setState(() => _tab = 'rejected')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    title: 'No applications yet',
                    message: 'Explore listings and apply to get started.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final x = items[i];
                      return ApplicationCard(
                        propertyTitle: x.title,
                        submittedDateText: x.date,
                        status: x.status,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ApplicationDetailScreen(appId: x.id, title: x.title, status: x.status),
                            ),
                          );
                        },
                        primaryActionText: x.status == 'approved' ? 'Pay Deposit' : 'View',
                        onPrimaryAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ApplicationDetailScreen(appId: x.id, title: x.title, status: x.status),
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

class _AppRow {
  const _AppRow({required this.id, required this.title, required this.status, required this.date});
  final String id;
  final String title;
  final String status;
  final String date;
}
