import 'package:flutter/material.dart';

import 'router/app_router.dart';
import '../core/theme/theme_controller.dart';

class HomeSteadApp extends StatelessWidget {
  const HomeSteadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'HomeStead',
          debugShowCheckedModeBanner: false,
          onGenerateRoute: AppRouter.onGenerateRoute,

          // ✅ show splash first (NOT login)
          initialRoute: AppRoutes.splash,

          // ✅ Settings changes this
          themeMode: themeController.mode,

          theme: ThemeData(useMaterial3: true, brightness: Brightness.light),
          darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
        );
      },
    );
  }
}