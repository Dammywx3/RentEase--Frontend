import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';

// Screens
import 'package:rentease_frontend/features/auth/ui/login/login_screen.dart';
import 'package:rentease_frontend/features/auth/ui/register/register_screen.dart';
import 'package:rentease_frontend/features/tenant/shell/tenant_shell.dart';
import 'package:rentease_frontend/features/agent/shell/agent_app_shell.dart';

class AppRouter {
  static final GoRouter router = createRouter();
}

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

      // After login/register go here so bottom nav shows
      GoRoute(
        path: AppRoutes.tenantShell,
        builder: (context, state) => const TenantShell(),
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
