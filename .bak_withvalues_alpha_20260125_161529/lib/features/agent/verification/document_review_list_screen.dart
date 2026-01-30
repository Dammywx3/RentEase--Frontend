import 'package:flutter/material.dart';
import '../../../core/constants/status_badge_map.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/widgets/status_badge.dart';
import 'document_detail_screen.dart';

class DocumentReviewListScreen extends StatefulWidget {
  const DocumentReviewListScreen({super.key});

  @override
  State<DocumentReviewListScreen> createState() =>
      _DocumentReviewListScreenState();
}

class _DocumentReviewListScreenState extends State<DocumentReviewListScreen> {
  String _tab = 'Pending';

  final _items = const [
    _Row(id: 'dr1', user: 'John Doe', type: 'ID Card', status: 'pending'),
    _Row(id: 'dr2', user: 'Ada K.', type: 'Utility Bill', status: 'verified'),
    _Row(id: 'dr3', user: 'Kemi A.', type: 'ID Card', status: 'rejected'),
  ];

  List<_Row> get _filtered {
    if (_tab == 'Pending')
      return _items.where((x) => x.status == 'pending').toList();
    if (_tab == 'Verified')
      return _items.where((x) => x.status == 'verified').toList();
    if (_tab == 'Rejected')
      return _items.where((x) => x.status == 'rejected').toList();
    return _items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return AppScaffold(
      topBar: const AppTopBar(
        title: 'Document Reviews',
        subtitle: 'Pending / verified / rejected',
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _Chip(
                  label: 'Pending',
                  active: _tab == 'Pending',
                  onTap: () => setState(() => _tab = 'Pending'),
                ),
                _Chip(
                  label: 'Verified',
                  active: _tab == 'Verified',
                  onTap: () => setState(() => _tab = 'Verified'),
                ),
                _Chip(
                  label: 'Rejected',
                  active: _tab == 'Rejected',
                  onTap: () => setState(() => _tab = 'Rejected'),
                ),
                _Chip(
                  label: 'All',
                  active: _tab == 'All',
                  onTap: () => setState(() => _tab = 'All'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              itemCount: items.length,
              separatorBuilder: (_, i) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) {
                final x = items[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.description_rounded),
                  ),
                  title: Text(
                    '${x.user} • ${x.type}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  trailing: StatusBadge(
                    domain: StatusDomain.verified,
                    status: x.status,
                    compact: true,
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DocumentDetailScreen(
                        docId: x.id,
                        userName: x.user,
                        docType: x.type,
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
    required this.user,
    required this.type,
    required this.status,
  });
  final String id;
  final String user;
  final String type;
  final String status;
}
