// lib/core/constants/user_role.dart
enum UserRole { tenant, landlord, agent, admin }

extension UserRoleX on UserRole {
  static UserRole fromApi(String? v) {
    final s = (v ?? '').trim().toLowerCase();
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
        return UserRole.tenant; // safe default
    }
  }

  String get label {
    switch (this) {
      case UserRole.tenant:
        return 'Tenant';
      case UserRole.landlord:
        return 'Landlord';
      case UserRole.agent:
        return 'Agent';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get description {
    switch (this) {
      case UserRole.tenant:
        return 'Find homes, pay rent, and manage your rentals.';
      case UserRole.agent:
        return 'List properties, manage clients, and close deals.';
      case UserRole.landlord:
        return 'Manage properties, tenants, and rent payments.';
      case UserRole.admin:
        return 'Manage the platform, users, and approvals.';
    }
  }

  String get pillLabel {
    switch (this) {
      case UserRole.tenant:
        return 'TENANT';
      case UserRole.agent:
        return 'AGENT';
      case UserRole.landlord:
        return 'LANDLORD';
      case UserRole.admin:
        return 'ADMIN';
    }
  }

  String get welcomeLine {
    switch (this) {
      case UserRole.tenant:
        return 'You’re logged in as a Tenant.';
      case UserRole.agent:
        return 'You’re logged in as an Agent.';
      case UserRole.landlord:
        return 'You’re logged in as a Landlord.';
      case UserRole.admin:
        return 'You’re logged in as an Admin.';
    }
  }

  String get primaryCta {
    switch (this) {
      case UserRole.tenant:
        return 'Explore';
      case UserRole.agent:
      case UserRole.landlord:
      case UserRole.admin:
        return 'Go to Dashboard';
    }
  }

  String toRoute() {
    switch (this) {
      case UserRole.tenant:
        return '/tenant/explore';
      case UserRole.agent:
        return '/agent/dashboard';
      case UserRole.landlord:
        return '/landlord/dashboard';
      case UserRole.admin:
        return '/admin/dashboard';
    }
  }

  /// Backward-compat for any old code using `role.value`
  String get value => name;
}
