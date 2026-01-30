import 'package:flutter/material.dart';
import 'package:rentease_frontend/app/router/app_router.dart';
import 'package:rentease_frontend/core/config/env.dart';

class HomeSteadApp extends StatelessWidget {
  const HomeSteadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RentEase',
      routerConfig: AppRouter.router,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E6EF7),
      ),
    );
  }
}

// If your main.dart calls a different App class name, keep this alias:
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeSteadApp();
  }
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
}
