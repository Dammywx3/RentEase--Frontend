// lib/core/config/api_endpoints.dart
class ApiEndpoints {
  // Auth
  static const String register = '/v1/auth/register';
  static const String login = '/v1/auth/login';
  static const String loginConfirm = '/v1/auth/login/confirm';

  // Me
  static const String me = '/v1/me';

  // Password reset (2-step backend)
  static const String requestPasswordReset = '/v1/auth/password/request-reset';
  static const String verifyResetCode = '/v1/auth/password/verify-reset-code';
  static const String resetPassword = '/v1/auth/password/reset';

  // Verification (email/sms)
  static const String verificationRequest = '/v1/auth/verification/request';
  static const String verificationConfirm = '/v1/auth/verification/confirm';
    // Viewings
  static const String viewings = '/v1/viewings';
  static const String myViewings = '/v1/viewings/my';
  
  
}
