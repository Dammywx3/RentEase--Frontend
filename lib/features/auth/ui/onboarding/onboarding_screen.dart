// lib/features/auth/ui/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';

import 'package:rentease_frontend/app/router/app_router.dart';
import 'package:rentease_frontend/core/storage/app_prefs.dart';
import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_typography.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _index = 0;

  final _pages = const [
    _OnboardPageData(
      title: 'Find a place fast',
      subtitle: 'Browse verified listings for rent and sale in minutes.',
      imageAsset: 'assets/images/tenant.png',
      fallbackIcon: Icons.search_rounded,
    ),
    _OnboardPageData(
      title: 'Work with trusted agents',
      subtitle: 'Chat, schedule viewings, and get help closing faster.',
      imageAsset: 'assets/images/agent.png',
      fallbackIcon: Icons.verified_user_rounded,
    ),
    _OnboardPageData(
      title: 'Manage tenants smoothly',
      subtitle: 'Track rent, requests, and property updates in one place.',
      imageAsset: 'assets/images/landlord.png',
      fallbackIcon: Icons.apartment_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await AppPrefs.setOnboardingDone(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  void _next() {
    if (_index >= _pages.length - 1) {
      _finish();
      return;
    }
    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = AppColors.textPrimary(context);
    final textMuted = AppColors.textMuted(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),

              // Top row: Skip
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Skip',
                        style: AppTypography.body(context).copyWith(
                          color: AppColors.brandBlueSoft,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) {
                    final p = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ImageCard(
                            assetPath: p.imageAsset,
                            fallbackIcon: p.fallbackIcon,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            p.title,
                            style: AppTypography.h1(context).copyWith(
                              color: textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            p.subtitle,
                            style: AppTypography.body(context).copyWith(
                              color: textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Dots + button
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    _Dots(count: _pages.length, index: _index),
                    const SizedBox(height: AppSpacing.lg),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.brandGreenDeep.withValues(alpha: 0.95),
                          foregroundColor: AppColors.textLight,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                          ),
                        ),
                        child: Text(
                          _index == _pages.length - 1 ? 'Get started' : 'Next',
                          style: AppTypography.button(context).copyWith(
                            color: AppColors.textLight,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      'You can change roles anytime later.',
                      style: AppTypography.caption(context).copyWith(
                        color: AppColors.textMuted(context),
                        fontWeight: FontWeight.w700,
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

class _OnboardPageData {
  const _OnboardPageData({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.fallbackIcon,
  });

  final String title;
  final String subtitle;
  final String imageAsset;
  final IconData fallbackIcon;
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({
    required this.assetPath,
    required this.fallbackIcon,
  });

  final String assetPath;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.surface(context).withValues(alpha: 0.72);
    final border = AppColors.border(context).withValues(alpha: 0.70);

    return Container(
      height: 230, // ✅ bigger card
      width: 230,  // ✅ bigger card
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs), // ✅ less padding
          child: Transform.scale(
            scale: 1.18, // ✅ zoom the PNG a bit
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain, // ✅ no cropping, just bigger
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) {
                return Center(
                  child: Icon(
                    fallbackIcon,
                    size: 70,
                    color: AppColors.textSecondary(context),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          height: 8,
          width: active ? 22 : 8,
          decoration: BoxDecoration(
            color: active
                ? AppColors.brandBlueSoft
                : AppColors.divider(context).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}