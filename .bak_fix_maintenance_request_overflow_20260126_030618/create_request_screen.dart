// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/toast_service.dart';

class CreateMaintenanceRequestScreen extends StatefulWidget {
  const CreateMaintenanceRequestScreen({super.key});

  @override
  State<CreateMaintenanceRequestScreen> createState() =>
      _CreateMaintenanceRequestScreenState();
}

class _CreateMaintenanceRequestScreenState
    extends State<CreateMaintenanceRequestScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _category = 'Plumbing';
  String _priority = 'Medium';
  String _visit = 'Anytime';
  bool _permissionToEnter = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(
        title: 'New Maintenance Request',
        subtitle: 'Create and submit a request',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _H('Category'),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  value: _category,
                  items: const [
                    DropdownMenuItem(
                      value: 'Plumbing',
                      child: Text('Plumbing'),
                    ),
                    DropdownMenuItem(
                      value: 'Electrical',
                      child: Text('Electrical'),
                    ),
                    DropdownMenuItem(value: 'AC', child: Text('AC')),
                    DropdownMenuItem(
                      value: 'Security',
                      child: Text('Security'),
                    ),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _category = v ?? 'Plumbing'),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                _H('Title'),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'e.g. Leaking kitchen pipe',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                _H('Description'),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _descCtrl,
                  minLines: 4,
                  maxLines: 7,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Describe the issue...',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                _H('Priority'),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  value: _priority,
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                  ],
                  onChanged: (v) => setState(() => _priority = v ?? 'Medium'),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _H('Photos'),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 92,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.75),
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Preview (wire later)',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.black.withValues(alpha: 0.55),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: () => ToastService.show(
                        context,
                        'Add photo(s) (wire later)',
                        success: true,
                      ),
                      icon: const Icon(Icons.add_a_photo_rounded),
                      label: const Text('Add Photo(s)'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _H('Preferred Visit Time'),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ChoiceChip(
                      label: 'Anytime',
                      active: _visit == 'Anytime',
                      onTap: () => setState(() => _visit = 'Anytime'),
                    ),
                    _ChoiceChip(
                      label: 'Morning',
                      active: _visit == 'Morning',
                      onTap: () => setState(() => _visit = 'Morning'),
                    ),
                    _ChoiceChip(
                      label: 'Afternoon',
                      active: _visit == 'Afternoon',
                      onTap: () => setState(() => _visit = 'Afternoon'),
                    ),
                    _ChoiceChip(
                      label: 'Evening',
                      active: _visit == 'Evening',
                      onTap: () => setState(() => _visit = 'Evening'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Permission to enter if not home',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Switch(
                      value: _permissionToEnter,
                      onChanged: (v) => setState(() => _permissionToEnter = v),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (_titleCtrl.text.trim().isEmpty ||
                    _descCtrl.text.trim().isEmpty) {
                  ToastService.show(
                    context,
                    'Please enter title + description',
                    success: false,
                  );
                  return;
                }

                ToastService.show(
                  context,
                  'Submitted (demo) • $_category • $_priority • $_visit',
                  success: true,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Submit Request'),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/* -------------- UI helpers -------------- */

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.55),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}

class _H extends StatelessWidget {
  const _H(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: active
              ? primary.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.55),
          border: Border.all(
            color: active
                ? primary.withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
