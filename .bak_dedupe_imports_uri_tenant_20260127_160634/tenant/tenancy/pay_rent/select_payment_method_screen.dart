import "package:flutter/material.dart";

import '../../../../core/ui/scaffold/app_top_bar.dart';
import "confirm_payment_screen.dart";
import '../../../../core/ui/scaffold/app_scaffold.dart';

import '../../../../core/theme/app_colors.dart';

import 'package:rentease_frontend/core/theme/app_colors.dart';

class SelectPaymentMethodScreen extends StatefulWidget {
  const SelectPaymentMethodScreen({
    super.key,
    required this.title,
    required this.amountNgn,
    required this.includeServiceCharge,
  });

  final String title;
  final int amountNgn;
  final bool includeServiceCharge;

  @override
  State<SelectPaymentMethodScreen> createState() =>
      _SelectPaymentMethodScreenState();
}

enum _Method { card, bank, wallet }

class _SelectPaymentMethodScreenState extends State<SelectPaymentMethodScreen> {
  _Method _method = _Method.card;

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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      topBar: const AppTopBar(title: 'Select Payment Method'),
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
                        "Select Payment Method",
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
                    _SelectTile(
                      title: "Card",
                      subtitle: "•••• 1234",
                      leading: Icons.credit_card_rounded,
                      selected: _method == _Method.card,
                      onTap: () => setState(() => _method = _Method.card),
                      trailing: _method == _Method.card
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF6E87B8),
                            )
                          : const Icon(Icons.chevron_right_rounded),
                    ),
                    const SizedBox(height: 12),
                    _SelectTile(
                      title: "Bank Transfer",
                      subtitle: "03 / 26",
                      leading: Icons.account_balance_rounded,
                      selected: _method == _Method.bank,
                      onTap: () => setState(() => _method = _Method.bank),
                      trailing: _method == _Method.bank
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF6E87B8),
                            )
                          : const Icon(Icons.chevron_right_rounded),
                    ),
                    const SizedBox(height: 12),
                    _SelectTile(
                      title: "Wallet",
                      subtitle: "₦0",
                      leading: Icons.account_balance_wallet_rounded,
                      selected: _method == _Method.wallet,
                      onTap: () => setState(() => _method = _Method.wallet),
                      trailing: _method == _Method.wallet
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF6E87B8),
                            )
                          : const Icon(Icons.chevron_right_rounded),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "Add new method",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _GhostTile(icon: Icons.credit_card_rounded, text: "Card"),
                    const SizedBox(height: 10),
                    _GhostTile(
                      icon: Icons.account_balance_rounded,
                      text: "Bank Transfer",
                    ),
                    const SizedBox(height: 10),
                    _GhostTile(
                      icon: Icons.account_balance_wallet_rounded,
                      text: "Wallet",
                    ),
                    const SizedBox(height: 10),
                    _GhostTile(icon: Icons.add_rounded, text: "New method"),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ConfirmPaymentScreen(
                              title: widget.title,
                              amountNgn: widget.amountNgn,
                              includeServiceCharge: widget.includeServiceCharge,
                              methodLabel: switch (_method) {
                                _Method.card => "Card •••• 1234",
                                _Method.bank => "Bank Transfer",
                                _Method.wallet => "Wallet",
                              },
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
                      child: Text(
                        "Pay ${_fmt(widget.amountNgn)}",
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.selected,
    required this.onTap,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData leading;
  final bool selected;
  final VoidCallback onTap;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: selected ? 0.80 : 0.60),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFCFDBEA).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(leading, color: AppColors.brandBlueSoft),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _GhostTile extends StatelessWidget {
  const _GhostTile({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context).withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: AppColors.brandBlueSoft),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
