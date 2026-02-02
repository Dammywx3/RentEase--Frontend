// lib/features/tenant/maintenance/create_request_screen.dart
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

  // ---------- Explore-style alpha helpers ----------
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaSurfaceSoft =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  @override
  void initState() {
    super.initState();

    _category = widget.defaultCategory ??
        (widget.categories.isNotEmpty ? widget.categories.first : '');
    _priority = widget.defaultPriority ??
        (widget.priorities.isNotEmpty ? widget.priorities.first : '');
    _visit = widget.defaultVisitWindow ??
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

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
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
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH, // Standard horizontal spacing
            AppSpacing.sm,
            AppSpacing.screenH,
            AppSizes.screenBottomPad,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Category'),
                      const SizedBox(height: AppSpacing.xs),
                      _StyledDropdown(
                        value: _category.isEmpty ? null : _category,
                        items: widget.categories,
                        onChanged: (v) => setState(() => _category = v ?? ''),
                        hintText:
                            widget.categories.isEmpty ? 'No categories' : null,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      const _Label('Title'),
                      const SizedBox(height: AppSpacing.xs),
                      _StyledTextField(
                        controller: _titleCtrl,
                        hintText: 'e.g. Leaking faucet',
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      const _Label('Description'),
                      const SizedBox(height: AppSpacing.xs),
                      _StyledTextField(
                        controller: _descCtrl,
                        hintText: 'Describe the issue...',
                        minLines: 3,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      const _Label('Priority'),
                      const SizedBox(height: AppSpacing.xs),
                      _StyledDropdown(
                        value: _priority.isEmpty ? null : _priority,
                        items: widget.priorities,
                        onChanged: (v) => setState(() => _priority = v ?? ''),
                        hintText:
                            widget.priorities.isEmpty ? 'No priorities' : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              _FrostCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('Photos'),
                      const SizedBox(height: AppSpacing.xs),
                      InkWell(
                        borderRadius: BorderRadius.circular(AppRadii.button),
                        onTap: () => ToastService.show(
                          context,
                          'Photo upload (wire later)',
                          success: true,
                        ),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            color: AppColors.overlay(context, 0.04),
                            border: Border.all(
                              color: AppColors.overlay(context, 0.08),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_a_photo_rounded,
                                  color: AppColors.textMuted(context),
                                  size: 28,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Tap to add photos',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textMuted(context),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      const _Label('Preferred visit time'),
                      const SizedBox(height: AppSpacing.sm),
                      if (widget.visitWindows.isEmpty)
                        Text(
                          'No visit windows available',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textMuted(context),
                                  ),
                        )
                      else
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: widget.visitWindows.map((w) {
                            return _SelectablePill(
                              text: w,
                              selected: _visit == w,
                              onTap: () => setState(() => _visit = w),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: AppSpacing.lg),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Permission to enter if not home',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary(context),
                                  ),
                            ),
                          ),
                          Switch(
                            value: _permissionToEnter,
                            activeColor: AppColors.brandGreenDeep,
                            onChanged: (v) =>
                                setState(() => _permissionToEnter = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              _PrimaryButton(
                text: 'Submit Request',
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
                    'Request Submitted',
                    success: true,
                  );

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => MaintenanceDetailScreen(
                        requestId: 'new_${now.millisecondsSinceEpoch}',
                        status: 'open',
                        title: title,
                        category: _category.isEmpty ? null : _category,
                        dateLabel: _formatShortDate(context, now),
                        address: widget.addressLabel,
                        priority: _priority.isEmpty ? null : _priority,
                        description: desc,
                        permissionToEnter: _permissionToEnter,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------- UI helpers ---------------- */

class _FrostCard extends StatelessWidget {
  const _FrostCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Standard Explore/Auth logic
    final alphaSurface = AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
    final alphaBorder = AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);
    final alphaShadow = AppSpacing.xs / AppSpacing.xxxl;

    return Material(
      color: AppColors.surface(context).withValues(alpha: alphaSurface),
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.overlay(context, alphaBorder)),
          boxShadow: AppShadows.lift(
            context,
            blur: AppSpacing.xxxl,
            y: AppSpacing.xl,
            alpha: alphaShadow,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.textMuted(context),
          ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.controller,
    required this.hintText,
    this.textInputAction,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputAction? textInputAction;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlay(context, 0.04),
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: AppColors.overlay(context, 0.08)),
      ),
      child: TextField(
        controller: controller,
        textInputAction: textInputAction,
        minLines: minLines,
        maxLines: maxLines,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
        cursorColor: AppColors.brandGreenDeep,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted(context).withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        ),
      ),
    );
  }
}

class _StyledDropdown extends StatelessWidget {
  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.overlay(context, 0.04),
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: AppColors.overlay(context, 0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: hintText != null
              ? Text(
                  hintText!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color:
                            AppColors.textMuted(context).withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                      ),
                )
              : null,
          items: items
              .map(
                (x) => DropdownMenuItem(
                  value: x,
                  child: Text(
                    x,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textMuted(context),
          ),
        ),
      ),
    );
  }
}

class _SelectablePill extends StatelessWidget {
  const _SelectablePill({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.brandGreenDeep;
    final bg = selected
        ? activeColor.withValues(alpha: 0.15)
        : AppColors.overlay(context, 0.04);
    final border = selected
        ? activeColor.withValues(alpha: 0.2)
        : AppColors.overlay(context, 0.08);
    final textC = selected
        ? activeColor
        : AppColors.textPrimary(context).withValues(alpha: 0.8);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.s10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          color: bg,
          border: Border.all(color: border),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: textC,
              ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandGreenDeep.withValues(alpha: 0.95),
          foregroundColor: AppColors.textLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textLight,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
        ),
      ),
    );
  }
}