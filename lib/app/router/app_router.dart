// lib/app/router/app_router.dart
import 'package:flutter/material.dart';

import '../../core/constants/user_role.dart';

// AUTH
import '../../features/auth/ui/login/login_screen.dart' as login;
import '../../features/auth/ui/register/register_screen.dart' as reg;
import '../../features/auth/ui/verify_email/verify_email_screen.dart' as verify;
import '../../features/auth/ui/verify_email/verify_purpose.dart';
import '../../features/auth/ui/register/choose_account_type_screen.dart'
    as choose;
import '../../features/auth/welcome/post_login_welcome_screen.dart' as welcome;

// ✅ NEW: SPLASH + ONBOARDING
import '../../features/auth/ui/splash/splash_screen.dart' as splash;
import '../../features/auth/ui/onboarding/onboarding_screen.dart' as onboarding;

// FORGOT PASSWORD
import '../../features/auth/ui/forgot_password/forgot_password_screen.dart'
    as fp;
import '../../features/auth/ui/forgot_password/reset_verify_code_screen.dart'
    as fpverify;
import '../../features/auth/ui/forgot_password/reset_new_password_screen.dart'
    as fpnew;

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
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.tenant;
  }
}

Map<String, dynamic> _args(RouteSettings settings) {
  return (settings.arguments is Map)
      ? Map<String, dynamic>.from(settings.arguments as Map)
      : <String, dynamic>{};
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ✅ NEW: Splash as first route
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const splash.SplashScreen());

      // ✅ NEW: Onboarding
      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const onboarding.OnboardingScreen(),
        );

      // ---- Auth ----
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const login.LoginScreen());

      case AppRoutes.chooseAccountType:
        return MaterialPageRoute(
          builder: (_) => const choose.ChooseAccountTypeScreen(),
        );

      case AppRoutes.register:
        {
          final args = _args(settings);
          final role = _parseRole(args['role']);
          return MaterialPageRoute(
            builder: (_) => reg.RegisterScreen(role: role),
          );
        }

      case AppRoutes.verifyEmail:
        {
          final args = _args(settings);

          final email = (args['email'] ?? '').toString();
          final fullName = (args['fullName'] ?? 'User').toString();
          final role = _parseRole(args['role']);

          // purpose string: email_verify | password_reset | phone_verify | login
          final purposeStr = (args['purpose'] ?? 'email_verify').toString();
          final purpose = VerifyPurposeX.fromBackendValue(purposeStr);

          final channel = (args['channel'] ?? 'email').toString();

          return MaterialPageRoute(
            builder: (_) => verify.VerifyEmailScreen(
              email: email,
              fullName: fullName,
              role: role,
              purpose: purpose,
              channel: channel,
            ),
          );
        }

      case AppRoutes.welcome:
        {
          final args = _args(settings);
          final fullName = (args['fullName'] ?? 'User').toString();
          final role = _parseRole(args['role']);

          return MaterialPageRoute(
            builder: (_) =>
                welcome.PostLoginWelcomeScreen(fullName: fullName, role: role),
          );
        }

      // ---- Forgot password flow ----
      case AppRoutes.forgotPassword:
        {
          final args = _args(settings);
          final String? email =
              (args['email'] is String) ? (args['email'] as String) : null;

          return MaterialPageRoute(
            builder: (_) => fp.ForgotPasswordScreen(prefillEmail: email),
          );
        }

      case AppRoutes.resetVerifyCode:
        {
          final args = _args(settings);
          final email = (args['email'] ?? '').toString();

          return MaterialPageRoute(
            builder: (_) => fpverify.ResetVerifyCodeScreen(email: email),
          );
        }

      case AppRoutes.resetNewPassword:
        {
          final args = _args(settings);

          final email = (args['email'] ?? '').toString();

          // ✅ NEW FLOW: verify step returns resetToken
          final resetToken = (args['resetToken'] ?? args['code'] ?? '').toString();

          return MaterialPageRoute(
            builder: (_) => fpnew.ResetNewPasswordScreen(
              email: email,
              resetToken: resetToken, // ✅ correct param
            ),
          );
        }

      // ---- Tenant routes ----
      case AppRoutes.tenant:
        return MaterialPageRoute(builder: (_) => const TenantShell());

      case AppRoutes.tenantExplore:
        return MaterialPageRoute(builder: (_) => const TenantShell());

      // ---- Agent/Landlord shells ----
      case AppRoutes.agent:
        return MaterialPageRoute(builder: (_) => const AgentAppShell());

      case AppRoutes.landlord:
        return MaterialPageRoute(builder: (_) => const LandlordAppShell());

      // ---- Fallback ----
      default:
        // If unknown route -> go Login
        return MaterialPageRoute(builder: (_) => const login.LoginScreen());
    }
  }
}

class AppRoutes {
  // ✅ NEW
  static const splash = '/';
  static const onboarding = '/onboarding';

  // auth
  static const login = '/login';
  static const chooseAccountType = '/choose-account-type';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const welcome = '/welcome';

  // forgot password
  static const forgotPassword = '/forgot-password';
  static const resetVerifyCode = '/forgot-password/verify';
  static const resetNewPassword = '/forgot-password/new';

  // shells
  static const tenant = '/tenant';
  static const tenantExplore = '/tenant/explore';
  static const agent = '/agent';
  static const landlord = '/landlord';
}