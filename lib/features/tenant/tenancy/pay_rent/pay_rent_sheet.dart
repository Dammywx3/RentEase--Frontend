import 'package:flutter/material.dart';

import 'select_payment_method_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_sizes.dart';

class PayRentSheet {
  static Future<void> open(
    BuildContext context, {
    required String title,
    required int amountNgn,
  }) async {
    final res = await showModalBottomSheet<_PayRentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PayRentBottomSheet(title: title, amountNgn: amountNgn),
    );

    if (res == null) return;

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SelectPaymentMethodScreen(
            title: title,
            amountNgn: res.amountNgn,
            includeServiceCharge: res.includeServiceCharge,
          ),
        ),
      );
    }
  }
}

class _PayRentBottomSheet extends StatefulWidget {
  const _PayRentBottomSheet({required this.title, required this.amountNgn});

  final String title;
  final int amountNgn;

  @override
  State<_PayRentBottomSheet> createState() => _PayRentBottomSheetState();
}

class _PayRentBottomSheetState extends State<_PayRentBottomSheet> {
  bool _full = true;
  bool _includeFee = false;

  final TextEditingController _partCtrl = TextEditingController();

  // ---- Explore-style computed alphas (no hardcoded numbers) ----
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaSurfaceSoft =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaShadowSoft => AppSpacing.xs / AppSpacing.xxxl;

  String _fmt(int v) {
    // keep your local formatter (no dependency changes)
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(",");
    }
    return "₦$buf";
  }

  int get _amount {
    if (_full) return widget.amountNgn;

    final raw = _partCtrl.text.replaceAll(RegExp(r"[^0-9]"), "");
    if (raw.isEmpty) return 0;
    return int.tryParse(raw) ?? 0;
  }

  @override
  void dispose() {
    _partCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amount = _amount;

    // Bottom sheet container uses Explore patterns:
    // - transparent background
    // - surface(context) with computed alpha
    // - overlay(context, computed alpha) borders
    // - AppShadows.lift with spacing-based params
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
            ),
            padding: const EdgeInsets.all(AppSpacing.screenV),
            decoration: BoxDecoration(
              color: AppColors.surface(context).withValues(alpha: _alphaSurfaceStrong),
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: AppColors.overlay(context, _alphaBorderSoft)),
              boxShadow: AppShadows.lift(
                context,
                blur: AppSpacing.xxxl + AppSpacing.lg,
                y: AppSpacing.xl,
                alpha: _alphaShadowSoft,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HeaderRow(
                  title: 'Pay Rent',
                  onClose: () => Navigator.of(context).pop(),
                ),

                const SizedBox(height: AppSpacing.md),

                _ListingSummaryCard(
                  title: widget.title,
                  amountText: _fmt(widget.amountNgn),
                  alphaSurfaceSoft: _alphaSurfaceSoft,
                  alphaBorderSoft: _alphaBorderSoft,
                ),

                const SizedBox(height: AppSpacing.lg),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Choose what to pay",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary(context),
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                _ChoiceTile(
                  label: "Full rent (${_fmt(widget.amountNgn)})",
                  selected: _full,
                  onTap: () => setState(() => _full = true),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ChoiceTile(
                  label: "Part payment",
                  selected: !_full,
                  onTap: () => setState(() => _full = false),
                ),

                if (!_full) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _AmountField(
                    controller: _partCtrl,
                    alphaSurfaceSoft: _alphaSurfaceSoft,
                    alphaBorderSoft: _alphaBorderSoft,
                    onChanged: (_) => setState(() {}),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                _ToggleRow(
                  title: "Include service charge",
                  value: _includeFee,
                  onChanged: (v) => setState(() => _includeFee = v),
                ),

                const SizedBox(height: AppSpacing.md),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: amount <= 0
                        ? null
                        : () {
                            Navigator.of(context).pop(
                              _PayRentResult(
                                amountNgn: amount,
                                includeServiceCharge: _includeFee,
                              ),
                            );
                          },
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -------------------- UI parts (Explore-consistent) --------------------

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // keep the title centered like your original hack, but in a clean way
        const SizedBox(width: AppSizes.iconButtonBox),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary(context),
                ),
          ),
        ),
        InkWell(
          onTap: onClose,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Container(
            height: AppSizes.iconButtonBox,
            width: AppSizes.iconButtonBox,
            decoration: BoxDecoration(
              color: AppColors.surface(context).withValues(
                alpha: AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs),
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.overlay(
                  context,
                  AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs),
                ),
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              color: AppColors.textMuted(context),
            ),
          ),
        ),
      ],
    );
  }
}

class _ListingSummaryCard extends StatelessWidget {
  const _ListingSummaryCard({
    required this.title,
    required this.amountText,
    required this.alphaSurfaceSoft,
    required this.alphaBorderSoft,
  });

  final String title;
  final String amountText;
  final double alphaSurfaceSoft;
  final double alphaBorderSoft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: alphaSurfaceSoft),
        borderRadius: BorderRadius.circular(AppRadii.button),
        border: Border.all(color: AppColors.overlay(context, alphaBorderSoft)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: Container(
              height: AppSizes.listThumbSize,
              width: AppSizes.listThumbSize,
              color: AppColors.brandBlueSoft.withValues(
                alpha: AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.home_rounded,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? 'Listing' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary(context),
                      ),
                ),
                const SizedBox(height: AppSpacing.s6),
                Text(
                  "Amount due",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted(context).withValues(alpha: 0.92),
                      ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  amountText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.brandGreenDeep,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.alphaSurfaceSoft,
    required this.alphaBorderSoft,
    required this.onChanged,
  });

  final TextEditingController controller;
  final double alphaSurfaceSoft;
  final double alphaBorderSoft;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface(context).withValues(alpha: alphaSurfaceSoft),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.overlay(context, alphaBorderSoft)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: "Enter amount",
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  double get _alphaSelectedBg => AppSpacing.md / (AppSpacing.xxxl + AppSpacing.md);
  double get _alphaSurface => AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.sm);
  double get _alphaBorder => AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.brandBlueSoft.withValues(alpha: _alphaSelectedBg)
        : AppColors.surface(context).withValues(alpha: _alphaSurface);

    final border = selected
        ? AppColors.brandBlueSoft.withValues(alpha: _alphaSelectedBg)
        : AppColors.overlay(context, _alphaBorder);

    final fg = AppColors.textPrimary(context);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: fg,
                      ),
                ),
              ),
              Container(
                height: AppSpacing.xl + AppSpacing.s2,
                width: AppSpacing.xl + AppSpacing.s2,
                decoration: BoxDecoration(
                  color: selected ? AppColors.brandBlueSoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.xxs),
                  border: Border.all(
                    color: selected
                        ? AppColors.brandBlueSoft
                        : AppColors.overlay(context, _alphaBorder),
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppColors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayRentResult {
  const _PayRentResult({
    required this.amountNgn,
    required this.includeServiceCharge,
  });

  final int amountNgn;
  final bool includeServiceCharge;
}