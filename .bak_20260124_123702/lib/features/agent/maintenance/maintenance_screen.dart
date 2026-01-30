import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/widgets/card_widgets/maintenance_card.dart';
import 'maintenance_detail_screen.dart';

class AgentMaintenanceScreen extends StatelessWidget {
  const AgentMaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _Row(id: 'am1', title: 'Leaking tap in kitchen', cat: 'Plumbing', priority: 'High', status: 'open'),
      _Row(id: 'am2', title: 'AC not cooling', cat: 'Electrical', priority: 'Medium', status: 'in_progress'),
      _Row(id: 'am3', title: 'Door handle loose', cat: 'General', priority: 'Low', status: 'resolved'),
    ];

    return AppScaffold(
      topBar: const AppTopBar(title: 'Maintenance', subtitle: 'Assign & update status'),
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, i) {
          final x = items[i];
          return MaintenanceCard(
            title: x.title,
            categoryText: 'Category: ${x.cat}',
            priorityText: 'Priority: ${x.priority}',
            status: x.status,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MaintenanceDetailScreen(requestId: x.id, status: x.status))),
            primaryActionText: 'View',
            onPrimaryAction: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MaintenanceDetailScreen(requestId: x.id, status: x.status))),
          );
        },
      ),
    );
  }
}

class _Row {
  const _Row({required this.id, required this.title, required this.cat, required this.priority, required this.status});
  final String id;
  final String title;
  final String cat;
  final String priority;
  final String status;
}
