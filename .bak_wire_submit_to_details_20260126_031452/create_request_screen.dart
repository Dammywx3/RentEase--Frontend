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
  String _category = 'Plumbing';
  String _priority = 'Medium';
  String _visit = 'Anytime';
  bool _permissionToEnter = false;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

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
      // ✅ Key fix: make the whole page scrollable + keyboard safe
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              140, // extra bottom so it never overflows behind nav / keyboard
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
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
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _category = v ?? 'Plumbing'),
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
                            textInputAction: TextInputAction.next,
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
                              DropdownMenuItem(
                                value: 'Low',
                                child: Text('Low'),
                              ),
                              DropdownMenuItem(
                                value: 'Normal',
                                child: Text('Normal'),
                              ),
                              DropdownMenuItem(
                                value: 'Medium',
                                child: Text('Medium'),
                              ),
                              DropdownMenuItem(
                                value: 'High',
                                child: Text('High'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _priority = v ?? 'Medium'),
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
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                    ),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => ToastService.show(
                                      context,
                                      'Photo upload (wire later)',
                                      success: true,
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add_a_photo_rounded),
                                          SizedBox(height: 6),
                                          Text(
                                            'Add photos',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          _H('Preferred visit time'),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _ChoicePill(
                                text: 'Anytime',
                                selected: _visit == 'Anytime',
                                onTap: () => setState(() => _visit = 'Anytime'),
                              ),
                              _ChoicePill(
                                text: 'Morning',
                                selected: _visit == 'Morning',
                                onTap: () => setState(() => _visit = 'Morning'),
                              ),
                              _ChoicePill(
                                text: 'Afternoon',
                                selected: _visit == 'Afternoon',
                                onTap: () =>
                                    setState(() => _visit = 'Afternoon'),
                              ),
                              _ChoicePill(
                                text: 'Evening',
                                selected: _visit == 'Evening',
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
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w900),
                                ),
                              ),
                              Switch(
                                value: _permissionToEnter,
                                onChanged: (v) =>
                                    setState(() => _permissionToEnter = v),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
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

                    const Spacer(), // keeps layout stable on tall screens
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ---------------- UI helpers ---------------- */

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
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
      ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? base.primary.withValues(alpha: 0.14) : Colors.white,
          border: Border.all(
            color: selected
                ? base.primary.withValues(alpha: 0.45)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: selected ? base.primary : null,
          ),
        ),
      ),
    );
  }
}
