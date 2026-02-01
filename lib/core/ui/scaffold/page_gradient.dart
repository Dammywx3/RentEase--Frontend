import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class PageGradient extends StatelessWidget {
  const PageGradient({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.pageBgGradient(context),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
