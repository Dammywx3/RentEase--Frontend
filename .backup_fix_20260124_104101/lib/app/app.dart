import 'package:flutter/material.dart';
import 'router/app_router.dart';

class HomeSteadApp extends StatelessWidget {
  const HomeSteadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      title: 'HomeStead',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
    );
  }
}
