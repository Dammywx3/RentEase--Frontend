import 'package:flutter/material.dart';

import '../../core/constants/user_role.dart';

// AUTH
import '../../features/auth/ui/login/login_screen.dart' as login;
import '../../features/auth/ui/register/register_screen.dart' as reg;
import '../../features/auth/ui/verify_email/verify_email_screen.dart' as verify;
import '../../features/auth/ui/register/choose_account_type_screen.dart' as choose;
import '../../features/auth/welcome/post_login_welcome_screen.dart' as welcome;

// FORGOT PASSWORD (new)
import '../../features/auth/ui/forgot_password/forgot_password_screen.dart' as fp;
import '../../features/auth/ui/forgot_password/reset_verify_code_screen.dart' as fpverify;
import '../../features/auth/ui/forgot_password/reset_new_password_screen.dart' as fpnew;

// SHELLS
import '../../features/tenant/shell/tenant_shell.dart';
import '../../features/agent/shell/agent_shell.dart';
import '../../features/landlord/shell/landlord_app_shell.dart';

UserRole _parseRole(dynamic v) {
  if (v is UserRole) return v;
  final s = (v ?? '').toString().toLowerCase().trim();
  switch (s) {
    case 'tenant':
      return UserRole.tenant;
    case 'agent':
      return UserRole.agent;
    case 'landlord':
      return UserRole.landlord;
    default:
      return UserRole.tenant;
  }
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ---- Auth ----
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const login.LoginScreen());

      case AppRoutes.chooseAccountType:
        return MaterialPageRoute(
          builder: (_) => const choose.ChooseAccountTypeScreen(),
        );

      case AppRoutes.register:
        final args = settings.arguments;
        final role = (args is Map) ? _parseRole(args['role']) : UserRole.tenant;
        return MaterialPageRoute(builder: (_) => reg.RegisterScreen(role: role));

      case AppRoutes.verifyEmail:
        final args = settings.arguments;
        final email =
            (args is Map && args['email'] is String) ? args['email'] as String : '';
        final fullName = (args is Map && args['fullName'] is String)
            ? args['fullName'] as String
            : 'User';
        final role = (args is Map) ? _parseRole(args['role']) : UserRole.tenant;

        return MaterialPageRoute(
          builder: (_) => verify.VerifyEmailScreen(
            email: email,
            fullName: fullName,
            role: role,
          ),
        );

      case AppRoutes.welcome:
        final args = settings.arguments;
        final fullName = (args is Map && args['fullName'] is String)
            ? args['fullName'] as String
            : 'User';
        final role = (args is Map) ? _parseRole(args['role']) : UserRole.tenant;

        return MaterialPageRoute(
          builder: (_) => welcome.PostLoginWelcomeScreen(
            fullName: fullName,
            role: role,
          ),
        );

      // ---- Forgot password flow (new) ----
      case AppRoutes.forgotPassword:
        final args = settings.arguments;
        final email =
            (args is Map && args['email'] is String) ? args['email'] as String : null;

        return MaterialPageRoute(
          builder: (_) => fp.ForgotPasswordScreen(prefillEmail: email),
        );

      case AppRoutes.resetVerifyCode:
        final args = settings.arguments;
        final email =
            (args is Map && args['email'] is String) ? args['email'] as String : '';

        return MaterialPageRoute(
          builder: (_) => fpverify.ResetVerifyCodeScreen(email: email),
        );

      case AppRoutes.resetNewPassword:
        final args = settings.arguments;
        final email =
            (args is Map && args['email'] is String) ? args['email'] as String : '';

        return MaterialPageRoute(
          builder: (_) => fpnew.ResetNewPasswordScreen(email: email),
        );

      // ---- Role shells ----
      case AppRoutes.tenant:
        return MaterialPageRoute(builder: (_) => const TenantShell());

      case AppRoutes.agent:
        return MaterialPageRoute(builder: (_) => const AgentAppShell());

      case AppRoutes.landlord:
        return MaterialPageRoute(builder: (_) => const LandlordAppShell());

      // ---- Fallback ----
      default:
        return MaterialPageRoute(builder: (_) => const login.LoginScreen());
    }
  }
}

class AppRoutes {
  // auth
  static const login = '/';
  static const chooseAccountType = '/choose-account-type';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const welcome = '/welcome';

  // forgot password (new)
  static const forgotPassword = '/forgot-password';
  static const resetVerifyCode = '/forgot-password/verify';
  static const resetNewPassword = '/forgot-password/new';

  // shells
  static const tenant = '/tenant';
  static const agent = '/agent';
  static const landlord = '/landlord';
}