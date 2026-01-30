import 'package:rentease_frontend/core/constants/enums.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.emailOrPhone,
    required this.role,
    required this.token,
  });

  final String id;
  final String fullName;
  final String emailOrPhone;
  final UserRole role;
  final String token;

  /// Backwards-compat for screens that use user.email
  String get email => emailOrPhone;

  static UserRole _roleFrom(dynamic v) {
    final s = (v ?? 'tenant').toString().toLowerCase();
    switch (s) {
      case 'landlord':
        return UserRole.landlord;
      case 'agent':
        return UserRole.agent;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.tenant;
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      fullName: (json['fullName'] ?? json['full_name'] ?? json['name'] ?? '').toString(),
      emailOrPhone: (json['emailOrPhone'] ??
              json['email_or_phone'] ??
              json['email'] ??
              json['phone'] ??
              '')
          .toString(),
      role: _roleFrom(json['role']),
      token: (json['token'] ?? json['accessToken'] ?? json['access_token'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'emailOrPhone': emailOrPhone,
      'role': role.value,
      'token': token,
    };
  }
}
