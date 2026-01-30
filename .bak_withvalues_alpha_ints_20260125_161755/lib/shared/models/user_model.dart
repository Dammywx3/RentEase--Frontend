enum UserRole { tenant, landlord, agent, admin }

UserRole? _parseRole(dynamic v) {
  final s = v?.toString().toLowerCase();
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

  factory UserModel.fromAuthResponse(Map<String, dynamic> json) {
    final token = json['token']?.toString();
    final user = (json['user'] is Map)
        ? Map<String, dynamic>.from(json['user'])
        : <String, dynamic>{};

    return UserModel(
      id: (user['id'] ?? '').toString(),
      organizationId: (user['organization_id'] ?? user['organizationId'])
          ?.toString(),
      fullName: (user['full_name'] ?? user['fullName'])?.toString(),
      email: user['email']?.toString(),
      phone: user['phone']?.toString(),
      role: _parseRole(user['role']),
      verifiedStatus: (user['verified_status'] ?? user['verifiedStatus'])
          ?.toString(),
      token: token,
    );
  }
}
