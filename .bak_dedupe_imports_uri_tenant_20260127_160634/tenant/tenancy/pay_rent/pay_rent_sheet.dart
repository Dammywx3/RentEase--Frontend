import "package:flutter/material.dart";

import "select_payment_method_screen.dart";

import '../../../../core/theme/app_colors.dart';

import 'package:rentease_frontend/core/theme/app_colors.dart';

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

  String _fmt(int v) {
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

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F8),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.surface(context).withValues(alpha: 0.7),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                  color: AppColors.overlay(context, 0.12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 34),
                    Expanded(
                      child: Text(
                        "Pay Rent",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
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
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context).withValues(alpha: 0.60),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.surface(context).withValues(alpha: 0.55),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 54,
                          width: 54,
                          color: const Color(
                            0xFFCFDBEA,
                          ).withValues(alpha: 0.85),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.home_rounded,
                            color: AppColors.brandBlueSoft,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.navy,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Amount due",
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textMutedLight,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _fmt(widget.amountNgn),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
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
                const SizedBox(height: 14),

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
                const SizedBox(height: 10),

                _ChoiceTile(
                  label: "Full rent (${_fmt(widget.amountNgn)})",
                  selected: _full,
                  onTap: () => setState(() => _full = true),
                ),
                const SizedBox(height: 10),
                _ChoiceTile(
                  label: "Part payment",
                  selected: !_full,
                  onTap: () => setState(() => _full = false),
                ),
                if (!_full) ...[
                  const SizedBox(height: 10),
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

                const SizedBox(height: 14),
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
                const SizedBox(height: 12),

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
                      backgroundColor: const Color(0xFF6E87B8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
          ? const Color(0xFF6E87B8).withValues(alpha: 0.22)
          : AppColors.surface(context).withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                  color: selected
                      ? const Color(0xFF6E87B8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF6E87B8)
                        : const Color(0xFFB9C1CF),
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
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
