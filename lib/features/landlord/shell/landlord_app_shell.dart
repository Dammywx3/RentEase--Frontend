import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class LandlordAppShell extends StatelessWidget {
  const LandlordAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Center(
        child: Text(
          'Landlord Dashboard (stub)',
          style: AppTypography.h2(
            context,
          ).copyWith(color: AppColors.textPrimary(context)),
        ),
      ),
    );
  }
}
