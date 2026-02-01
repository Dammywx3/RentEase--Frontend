import 'package:rentease_frontend/core/constants/user_role.dart';

UserRole? _parseRole(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim().toLowerCase();
  switch (s) {
    case 'tenant':
      return UserRole.tenant;
    case 'landlord':
      return UserRole.landlord;
    case 'agent':
      return UserRole.agent;
    case 'admin':
      return UserRole.admin;
    default:
      return null;
  }
}

class UserModel {
  final String id;
  final String? organizationId;
  final String? fullName;
  final String? email;
  final String? phone;
  final UserRole? role;
  final String? verifiedStatus;

  // session
  final String? token;

  const UserModel({
    required this.id,
    this.organizationId,
    this.fullName,
    this.email,
    this.phone,
    this.role,
    this.verifiedStatus,
    this.token,
  });

  /// Supports:
  /// - { token, user }
  /// - { accessToken, user }
  /// - { data: { token, user } }
  /// - { data: { accessToken, user } }
  factory UserModel.fromAuthResponse(Map<String, dynamic> json) {
    Map<String, dynamic> root = json;

    if (json['data'] is Map) {
      root = Map<String, dynamic>.from(json['data'] as Map);
    }

    final token =
        (root['token'] ??
                root['accessToken'] ??
                json['token'] ??
                json['accessToken'])
            ?.toString();

    final userMap = (root['user'] is Map)
        ? Map<String, dynamic>.from(root['user'] as Map)
        : (json['user'] is Map)
        ? Map<String, dynamic>.from(json['user'] as Map)
        : <String, dynamic>{};

    return UserModel(
      id: (userMap['id'] ?? userMap['_id'] ?? '').toString(),
      organizationId: (userMap['organization_id'] ?? userMap['organizationId'])
          ?.toString(),
      fullName: (userMap['full_name'] ?? userMap['fullName'])?.toString(),
      email: userMap['email']?.toString(),
      phone: userMap['phone']?.toString(),
      role: _parseRole(userMap['role']),
      verifiedStatus: (userMap['verified_status'] ?? userMap['verifiedStatus'])
          ?.toString(),
      token: token,
    );
  }
}
