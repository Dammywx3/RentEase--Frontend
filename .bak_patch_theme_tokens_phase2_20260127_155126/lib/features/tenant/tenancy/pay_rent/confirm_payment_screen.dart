import "package:flutter/material.dart";

import 'package:rentease_frontend/core/ui/scaffold/app_top_bar.dart';
import "payment_success_screen.dart";
import 'package:rentease_frontend/core/ui/scaffold/app_scaffold.dart';

import 'package:rentease_frontend/core/theme/app_colors.dart';

class ConfirmPaymentScreen extends StatefulWidget {
  const ConfirmPaymentScreen({
    super.key,
    required this.title,
    required this.amountNgn,
    required this.includeServiceCharge,
    required this.methodLabel,
  });

  final String title;
  final int amountNgn;
  final bool includeServiceCharge;
  final String methodLabel;

  @override
  State<ConfirmPaymentScreen> createState() => _ConfirmPaymentScreenState();
}

class _ConfirmPaymentScreenState extends State<ConfirmPaymentScreen> {
  bool _full = true;

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

  int get _fee =>
      widget.includeServiceCharge ? 0 : 0; // demo (keep ₦0 like mock)
  int get _total => widget.amountNgn + _fee;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Confirm Payment'),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1F3F8), Color(0xFFE9ECF4)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    Expanded(
                      child: Text(
                        "Confirm Payment",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.navy,
                            ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 120),
                  children: [
                    _Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Rent",
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.navy,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _RowLine(
                              left: "Tenancy:",
                              right: _fmt(widget.amountNgn),
                            ),
                            const SizedBox(height: 10),
                            _RowLine(left: "Tenancy", right: widget.title),
                            const SizedBox(height: 10),
                            _RowLine(left: "Fees:", right: _fmt(_fee)),
                            const SizedBox(height: 10),
                            _RowLine(left: "Total:", right: _fmt(_total)),
                            const SizedBox(height: 10),
                            _RowLine(
                              left: "Method:",
                              right: widget.methodLabel,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Choose what to pay",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _Choice(
                      label: "Full rent (${_fmt(widget.amountNgn)})",
                      selected: _full,
                      onTap: () => setState(() => _full = true),
                    ),
                    const SizedBox(height: 10),
                    _Choice(
                      label: "Part payment",
                      selected: !_full,
                      onTap: () => setState(() => _full = false),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => PaymentSuccessScreen(
                                receiptId: "6300121679",
                                title: widget.title,
                                amountNgn: _total,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6E8E7A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Confirm & Pay",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowLine extends StatelessWidget {
  const _RowLine({required this.left, required this.right});
  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textMutedLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            right,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
        ),
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
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

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: 0.62),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.surface(context).withValues(alpha: 0.55),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: AppColors.overlay(context, 0.08),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
