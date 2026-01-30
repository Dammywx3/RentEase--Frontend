import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../core/ui/states/empty_state.dart';
import '../../../shared/services/toast_service.dart';
import '../../../shared/widgets/primary_button.dart';
import 'tenancy_detail_screen.dart';

class TenanciesScreen extends StatefulWidget {
  const TenanciesScreen({super.key});

  @override
  State<TenanciesScreen> createState() => _TenanciesScreenState();
}

class _TenanciesScreenState extends State<TenanciesScreen> {
  String _tab = 'Active';

  final _items = const [
    _Row(
      id: 't1',
      title: 'Modern 2 Bedroom Apartment',
      status: 'active',
      meta: 'Tenant: John • Next due: Feb 01',
    ),
    _Row(
      id: 't2',
      title: 'Cozy Studio',
      status: 'ending_soon',
      meta: 'Tenant: Ada • Ends: Feb 10',
    ),
    _Row(
      id: 't3',
      title: 'Family Duplex',
      status: 'ended',
      meta: 'Tenant: Kemi • Ended: Jan 01',
    ),
  ];

  List<_Row> get _filtered {
    switch (_tab) {
      case 'Ending Soon':
        return _items.where((x) => x.status == 'ending_soon').toList();
      case 'Ended':
        return _items.where((x) => x.status == 'ended').toList();
      default:
        return _items.where((x) => x.status == 'active').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return AppScaffold(
      scroll: false,

      topBar: const AppTopBar(
        title: 'Tenancies',
        subtitle: 'Active & ending soon',
      ),
      child: Column(
        children: [
          PrimaryButton(
            label: 'Create tenancy (from approved application)',
            onPressed: () => ToastService.show(
              context,
              'Create tenancy flow (demo)',
              success: true,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(
                  label: 'Active',
                  active: _tab == 'Active',
                  onTap: () => setState(() => _tab = 'Active'),
                ),
                _Chip(
                  label: 'Ending Soon',
                  active: _tab == 'Ending Soon',
                  onTap: () => setState(() => _tab = 'Ending Soon'),
                ),
                _Chip(
                  label: 'Ended',
                  active: _tab == 'Ended',
                  onTap: () => setState(() => _tab = 'Ended'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    title: 'No tenancies',
                    message: 'Tenancies will appear here.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    itemCount: items.length,
                    separatorBuilder: (_, i) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final x = items[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          child: Icon(Icons.home_work_rounded),
                        ),
                        title: Text(
                          x.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(x.meta),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TenancyDetailScreen(
                              tenancyId: x.id,
                              title: x.title,
                              status: x.status,
                            ),
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

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});
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
    required this.status,
    required this.meta,
  });
  final String id;
  final String title;
  final String status;
  final String meta;
}
