import 'package:flutter/material.dart';

import 'select_payment_method_screen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/app_spacing.dart';

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

    if (res == null) { return; }
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

  String _fmt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) { buf.write(","); }    }
    return "₦$buf";
  }

  int get _amount {
    if (_full) { return widget.amountNgn; }    final raw = _partCtrl.text.replaceAll(RegExp(r"[^0-9]"), "");
    if (raw.isEmpty) { return 0; }    return int.tryParse(raw) ?? 0;
  }

  @override
  void dispose() {
    _partCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amount = _amount;

    return SafeArea(
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenV,
              AppSpacing.screenV,
              AppSpacing.screenV,
              AppSpacing.screenV,
            ),
            decoration: BoxDecoration(
              color: AppColors.tenantBgTop,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(
                color: AppColors.surface(context).withValues(alpha: 0.7),
              ),
              boxShadow: AppShadows.lift(context, blur: 22, y: 10, alpha: 0.12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // ✅ FIX
                    const SizedBox(width: AppSpacing.s34),
                    Expanded(
                      child: Text(
                        "Pay Rent",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.navy,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context).withValues(alpha: 0.60),
                    borderRadius: BorderRadius.circular(AppRadii.button),
                    border: Border.all(
                      color: AppColors.surface(context).withValues(alpha: 0.55),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        child: Container(
                          height: 54,
                          width: 54,
                          color: const Color(0xFFCFDBEA).withValues(alpha: 0.85),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.home_rounded,
                            color: AppColors.brandBlueSoft,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.navy,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.s6),
                            Text(
                              "Amount due",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMutedLight,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.s2),
                            Text(
                              _fmt(widget.amountNgn),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.navy,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.screenV),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Choose what to pay",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s10),
                _ChoiceTile(
                  label: "Full rent (${_fmt(widget.amountNgn)})",
                  selected: _full,
                  onTap: () => setState(() => _full = true),
                ),
                const SizedBox(height: AppSpacing.s10),
                _ChoiceTile(
                  label: "Part payment",
                  selected: !_full,
                  onTap: () => setState(() => _full = false),
                ),
                if (!_full) ...[
                  const SizedBox(height: AppSpacing.s10),
                  TextField(
                    controller: _partCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Enter amount",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
                const SizedBox(height: AppSpacing.screenV),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Include service charge",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            ),
                      ),
                    ),
                    Switch(
                      value: _includeFee,
                      onChanged: (v) => setState(() => _includeFee = v),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.tenantActionBlue,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.screenV),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.tenantActionBlue.withValues(alpha: 0.22)
          : AppColors.surface(context).withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                ),
              ),
              Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  color: selected ? AppColors.tenantActionBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.xxs),
                  border: Border.all(
                    color: selected ? AppColors.tenantActionBlue : AppColors.tenantBorderMuted,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded, size: 16, color: AppColors.white)
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
