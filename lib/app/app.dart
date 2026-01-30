import 'package:flutter/material.dart';

import 'router/app_router.dart';

class HomeSteadApp extends StatelessWidget {
  const HomeSteadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeStead',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRoutes.login,
      //themeMode: ThemeMode.system,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
    );
  }
}
