// lib/features/auth/ui/splash/splash_screen.dart
import 'package:flutter/material.dart';

import 'package:rentease_frontend/app/router/app_router.dart';
import 'package:rentease_frontend/core/storage/app_prefs.dart';
import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/ui/scaffold/app_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // Small delay so the splash is visible
    await Future.delayed(const Duration(milliseconds: 900));

    final done = await AppPrefs.isOnboardingDone();

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(
      done ? AppRoutes.login : AppRoutes.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: false, // Let content center naturally
        safeAreaBottom: false,
        topBar: null,
        child: Center(
          child: Image.asset(
            'assets/images/Splash_logo.png',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              // fallback if image path is wrong
              return Icon(
                Icons.home_rounded,
                size: 90,
                // Matches the brand green used in other auth screens
                color: AppColors.brandGreenDeep,
              );
            },
          ),
        ),
      ),
    );
  }
}