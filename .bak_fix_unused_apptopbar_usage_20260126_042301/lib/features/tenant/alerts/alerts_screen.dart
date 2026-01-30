import 'package:flutter/material.dart';

import 'package:rentease_frontend/core/ui/scaffold/app_top_bar.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Alerts'),
        foregroundColor: cs.onSurface,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        itemBuilder: (context, i) => Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                offset: const Offset(0, 10),
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.notifications_rounded, color: Color(0xFF3C7C5A)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  i == 0
                      ? 'New listing alert: 3-bedroom in Lekki'
                      : 'Price drop alert: ₦95,000,000 in Ikeja',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemCount: 6,
      ),
    );
  }
}
