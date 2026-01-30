import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';
import '../../features/auth/ui/login/login_screen.dart';
import '../../features/auth/ui/register/register_screen.dart';
import '../../features/tenant/shell/tenant_app_shell.dart';
import '../../features/agent/shell/agent_app_shell.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
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

      // IMPORTANT: After login/register, go here so bottom nav shows
      GoRoute(
        path: AppRoutes.tenantShell,
        builder: (context, state) => const TenantAppShell(),
      ),
      GoRoute(
        path: AppRoutes.agentShell,
        builder: (context, state) => const AgentAppShell(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Route error: ${state.error}'),
        ),
      ),
    ),
  );
}
