import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rentease_frontend/app/router/routes.dart';
import 'package:rentease_frontend/features/auth/ui/login/login_screen.dart';
import 'package:rentease_frontend/features/auth/ui/register/register_screen.dart';
import 'package:rentease_frontend/features/home/ui/agent_home_screen.dart';
import 'package:rentease_frontend/features/home/ui/tenant_home_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.tenantHome,
        builder: (context, state) => const TenantHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.agentHome,
        builder: (context, state) => const AgentHomeScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route error: ${state.error}')),
    ),
  );
}
