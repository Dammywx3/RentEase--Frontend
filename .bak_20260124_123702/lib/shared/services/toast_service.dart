import 'package:flutter/material.dart';

class ToastService {
  static void show(
    BuildContext context,
    String message, {
    bool success = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final theme = Theme.of(context);
    final bg = success ? theme.colorScheme.secondary : theme.colorScheme.primary;

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void error(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
