import 'package:flutter/material.dart';
import 'package:rentease_frontend/app/router/app_router.dart';
import 'package:rentease_frontend/core/theme/app_theme.dart';

class HomeSteadApp extends StatelessWidget {
  const HomeSteadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RentEase',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),

      // Default to LIGHT so it won’t look dark.
      // Later you can change this to ThemeMode.system or user setting.
      themeMode: ThemeMode.light,

      routerConfig: AppRouter.router,
    );
  }
}
