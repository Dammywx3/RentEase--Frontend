// lib/features/auth/ui/verify_email/verify_purpose.dart

enum VerifyPurpose {
  emailVerify,
  phoneVerify,
  passwordReset,
  register,
  login,
}

extension VerifyPurposeX on VerifyPurpose {
  /// What the backend expects in `purpose`
  String get backendValue {
    switch (this) {
      case VerifyPurpose.emailVerify:
        return 'email_verify';
      case VerifyPurpose.phoneVerify:
        return 'phone_verify';
      case VerifyPurpose.passwordReset:
        return 'password_reset';
      case VerifyPurpose.register:
        return 'register';
      case VerifyPurpose.login:
        return 'login';
    }
  }

  /// Screen title
  String get title {
    switch (this) {
      case VerifyPurpose.login:
        return 'Confirm login';
      case VerifyPurpose.register:
      case VerifyPurpose.emailVerify:
        return 'Verify your email';
      case VerifyPurpose.phoneVerify:
        return 'Verify your phone';
      case VerifyPurpose.passwordReset:
        return 'Verify reset code';
    }
  }

  /// Screen subtitle
  String get subtitle {
    switch (this) {
      case VerifyPurpose.login:
        return 'Enter the code sent to';
      case VerifyPurpose.register:
      case VerifyPurpose.emailVerify:
        return 'We sent a code to';
      case VerifyPurpose.phoneVerify:
        return 'We sent an SMS code to';
      case VerifyPurpose.passwordReset:
        return 'Enter the reset code sent to';
    }
  }

  /// Convert backend string -> enum safely
  static VerifyPurpose fromBackendValue(String raw) {
    final v = raw.trim().toLowerCase();
    switch (v) {
      case 'email_verify':
      case 'email':
        return VerifyPurpose.emailVerify;
      case 'phone_verify':
      case 'phone':
      case 'sms':
        return VerifyPurpose.phoneVerify;
      case 'password_reset':
      case 'reset':
        return VerifyPurpose.passwordReset;
      case 'register':
        return VerifyPurpose.register;
      case 'login':
        return VerifyPurpose.login;
      default:
        return VerifyPurpose.emailVerify;
    }
  }
}