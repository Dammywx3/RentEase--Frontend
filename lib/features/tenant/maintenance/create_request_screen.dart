// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_sizes.dart';

import '../../../core/ui/scaffold/app_scaffold.dart';
import '../../../core/ui/scaffold/app_top_bar.dart';
import '../../../shared/services/toast_service.dart';

import 'maintenance_detail_screen.dart';

class CreateMaintenanceRequestScreen extends StatefulWidget {
  const CreateMaintenanceRequestScreen({
    super.key,
    this.categories = const [],
    this.priorities = const [],
    this.visitWindows = const [],
    this.topTitle,
    this.topSubtitle,
    this.defaultCategory,
    this.defaultPriority,
    this.defaultVisitWindow,
    this.addressLabel,
  });

  final List<String> categories;
  final List<String> priorities;
  final List<String> visitWindows;

  final String? topTitle;
  final String? topSubtitle;

  final String? defaultCategory;
  final String? defaultPriority;
  final String? defaultVisitWindow;

  final String? addressLabel;

  @override
  State<CreateMaintenanceRequestScreen> createState() =>
      _CreateMaintenanceRequestScreenState();
}

class _CreateMaintenanceRequestScreenState
    extends State<CreateMaintenanceRequestScreen> {
  late String _category;
  late String _priority;
  late String _visit;

  bool _permissionToEnter = false;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  double get _surfaceA => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _borderA => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  void initState() {
    super.initState();

    _category =
        widget.defaultCategory ??
        (widget.categories.isNotEmpty ? widget.categories.first : '');
    _priority =
        widget.defaultPriority ??
        (widget.priorities.isNotEmpty ? widget.priorities.first : '');
    _visit =
        widget.defaultVisitWindow ??
        (widget.visitWindows.isNotEmpty ? widget.visitWindows.first : '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String _formatShortDate(BuildContext context, DateTime dt) {
    final loc = MaterialLocalizations.of(context);
    return loc.formatShortMonthDay(dt);
  }

  @override
  Widget build(BuildContext context) {
    final topTitle = (widget.topTitle ?? '').trim();
    final topSubtitle = (widget.topSubtitle ?? '').trim();

    return Stack(
      children: [
        // ✅ Fix: gradient behind the entire page (safe-area + top bar)
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.pageBgGradient(context),
            ),
          ),
        ),
        AppScaffold(
          backgroundColor: Colors.transparent,
          safeAreaTop: true,
          safeAreaBottom: false,
          topBar: AppTopBar(
            title: topTitle.isEmpty ? 'New Maintenance Request' : topTitle,
            subtitle: topSubtitle.isEmpty
                ? 'Create and submit a request'
                : topSubtitle,
            leadingIcon: Icons.arrow_back_rounded,
            onLeadingTap: () => Navigator.of(context).maybePop(),
            actions: const [],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.sm,
                  AppSpacing.screenH,
                  AppSizes.screenBottomPad,
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
                              const _H('Category'),
                              const SizedBox(height: AppSpacing.sm),
                              _Dropdown(
                                enabled: widget.categories.isNotEmpty,
                                value: _category.isEmpty ? null : _category,
                                items: widget.categories,
                                onChanged: (v) =>
                                    setState(() => _category = v ?? ''),
                                hintText: widget.categories.isEmpty
                                    ? 'No categories'
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.md),

                              const _H('Title'),
                              const SizedBox(height: AppSpacing.sm),
                              TextField(
                                controller: _titleCtrl,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  hintText: 'Title',
                                  hintStyle: TextStyle(
                                    color: AppColors.textMuted(
                                      context,
                                    ).withValues(alpha: 0.80),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),

                              const _H('Description'),
                              const SizedBox(height: AppSpacing.sm),
                              TextField(
                                controller: _descCtrl,
                                minLines: AppSpacing.lg ~/ AppSpacing.sm, // 2
                                maxLines: AppSpacing.xxxl ~/ AppSpacing.sm, // 4
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  hintText: 'Describe the issue...',
                                  hintStyle: TextStyle(
                                    color: AppColors.textMuted(
                                      context,
                                    ).withValues(alpha: 0.80),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),

                              const _H('Priority'),
                              const SizedBox(height: AppSpacing.sm),
                              _Dropdown(
                                enabled: widget.priorities.isNotEmpty,
                                value: _priority.isEmpty ? null : _priority,
                                items: widget.priorities,
                                onChanged: (v) =>
                                    setState(() => _priority = v ?? ''),
                                hintText: widget.priorities.isEmpty
                                    ? 'No priorities'
                                    : null,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _H('Photos'),
                              const SizedBox(height: AppSpacing.sm),
                              InkWell(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.button,
                                ),
                                onTap: () => ToastService.show(
                                  context,
                                  'Photo upload (wire later)',
                                  success: true,
                                ),
                                child: Container(
                                  height:
                                      AppSizes.listThumbSize + AppSpacing.xxxl,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.button,
                                    ),
                                    color: AppColors.surface(
                                      context,
                                    ).withValues(alpha: _surfaceA),
                                    border: Border.all(
                                      color: AppColors.overlay(
                                        context,
                                        _borderA,
                                      ),
                                    ),
                                    boxShadow: AppShadows.soft(
                                      context,
                                      blur: AppSpacing.xxxl,
                                      y: AppSpacing.lg,
                                      alpha: AppSpacing.xs / AppSpacing.xxxl,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo_rounded,
                                          color: AppColors.textMuted(context),
                                        ),
                                        const SizedBox(height: AppSpacing.s6),
                                        Text(
                                          'Add photos',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.textPrimary(
                                                  context,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),

                              const _H('Preferred visit time'),
                              const SizedBox(height: AppSpacing.sm),
                              if (widget.visitWindows.isEmpty)
                                Text(
                                  'No visit windows',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textMuted(context),
                                      ),
                                )
                              else
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.sm,
                                  children: widget.visitWindows.map((w) {
                                    return _ChoicePill(
                                      text: w,
                                      selected: _visit == w,
                                      onTap: () => setState(() => _visit = w),
                                    );
                                  }).toList(),
                                ),

                              const SizedBox(height: AppSpacing.md),

                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Permission to enter if not home',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textPrimary(
                                              context,
                                            ),
                                          ),
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
                          height: AppSizes.pillButtonHeight + AppSpacing.sm,
                          child: FilledButton(
                            onPressed: () {
                              final title = _titleCtrl.text.trim();
                              final desc = _descCtrl.text.trim();

                              if (title.isEmpty || desc.isEmpty) {
                                ToastService.show(
                                  context,
                                  'Please enter title + description',
                                  success: false,
                                );
                                return;
                              }

                              final now = DateTime.now();

                              ToastService.show(
                                context,
                                'Submitted',
                                success: true,
                              );

                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => MaintenanceDetailScreen(
                                    requestId:
                                        'new_${now.millisecondsSinceEpoch}',
                                    status: 'open',
                                    title: title,
                                    category: _category.isEmpty
                                        ? null
                                        : _category,
                                    dateLabel: _formatShortDate(context, now),
                                    address: widget.addressLabel,
                                    priority: _priority.isEmpty
                                        ? null
                                        : _priority,
                                    description: desc,
                                    permissionToEnter: _permissionToEnter,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Submit Request'),
                          ),
                        ),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/* ---------------- UI helpers ---------------- */

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  double get _surfaceA => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _borderA => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        color: AppColors.surface(context).withValues(alpha: _surfaceA),
        border: Border.all(color: AppColors.overlay(context, _borderA)),
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
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary(context),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.enabled,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  final bool enabled;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map(
            (x) => DropdownMenuItem(
              value: x,
              child: Text(x, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        isDense: true,
        hintText: hintText,
      ),
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

  double get _surfaceA => AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md);
  double get _borderA => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 260,
        ), // ✅ prevents tiny overflow
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenV,
          vertical: AppSpacing.s10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          color: selected
              ? base.primary.withValues(alpha: _surfaceA)
              : AppColors.surface(context).withValues(alpha: _surfaceA),
          border: Border.all(
            color: selected
                ? base.primary.withValues(alpha: _borderA)
                : AppColors.overlay(context, _borderA),
          ),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: selected ? base.primary : AppColors.textPrimary(context),
          ),
        ),
      ),
    );
  }
}
