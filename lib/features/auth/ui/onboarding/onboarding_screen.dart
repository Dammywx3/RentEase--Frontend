// lib/features/auth/ui/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';

import 'package:rentease_frontend/app/router/app_router.dart';
import 'package:rentease_frontend/core/storage/app_prefs.dart';
import 'package:rentease_frontend/core/theme/app_colors.dart';
import 'package:rentease_frontend/core/theme/app_radii.dart';
import 'package:rentease_frontend/core/theme/app_shadows.dart';
import 'package:rentease_frontend/core/theme/app_spacing.dart';
import 'package:rentease_frontend/core/theme/app_sizes.dart';

import 'package:rentease_frontend/core/ui/scaffold/app_scaffold.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _index = 0;

  // ---------- Explore-style alpha helpers ----------
  double get _alphaSurfaceStrong =>
      AppSpacing.xxxl / (AppSpacing.xxxl + AppSpacing.xs);

  double get _alphaBorderSoft =>
      AppSpacing.xs / (AppSpacing.xxxl + AppSpacing.xs);

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

    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppColors.pageBgGradient(context)),
      child: AppScaffold(
        backgroundColor: Colors.transparent,
        safeAreaTop: true,
        safeAreaBottom: false,
        topBar: null,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),

              // Top row: Skip
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenH, // Standard padding
                ),
                child: Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Skip',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                        horizontal: AppSpacing.screenH,
                        vertical: AppSpacing.lg,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ImageCard(
                            assetPath: p.imageAsset,
                            fallbackIcon: p.fallbackIcon,
                            alphaSurface: _alphaSurfaceStrong,
                            alphaBorder: _alphaBorderSoft,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            p.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w900,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            p.subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: textMuted,
                                  height: 1.4,
                                  fontWeight: FontWeight.w700,
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
                  AppSpacing.screenH,
                  0,
                  AppSpacing.screenH,
                  AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    _Dots(count: _pages.length, index: _index),
                    const SizedBox(height: AppSpacing.lg),

                    _PrimaryButton(
                      text:
                          _index == _pages.length - 1 ? 'Get started' : 'Next',
                      onPressed: _next,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Text(
                      'You can change roles anytime later.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textMuted.withValues(alpha: 0.7),
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
    required this.alphaSurface,
    required this.alphaBorder,
  });

  final String assetPath;
  final IconData fallbackIcon;
  final double alphaSurface;
  final double alphaBorder;

  @override
  Widget build(BuildContext context) {
    // Frost style logic matching Explore cards
    final bg = AppColors.surface(context).withValues(alpha: alphaSurface);
    final border = AppColors.overlay(context, alphaBorder);

    return Container(
      height: 260,
      width: 260,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: border),
        boxShadow: AppShadows.lift(
          context,
          blur: AppSpacing.xxxl,
          y: AppSpacing.xl,
          alpha: AppSpacing.xs / AppSpacing.xxxl,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Transform.scale(
            scale: 1.1,
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) {
                return Center(
                  child: Icon(
                    fallbackIcon,
                    size: 80,
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
          width: active ? 24 : 8,
          decoration: BoxDecoration(
            // Matches brand green used in auth buttons
            color: active
                ? AppColors.brandGreenDeep
                : AppColors.overlay(context, 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.brandGreenDeep.withValues(alpha: 0.95);
    final fg = AppColors.textLight;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
        ),
      ),
    );
  }
}