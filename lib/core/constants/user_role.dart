enum UserRole { tenant, agent, landlord }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.tenant:
        return 'Tenant';
      case UserRole.agent:
        return 'Agent';
      case UserRole.landlord:
        return 'Landlord';
    }
  }

  String get pillLabel => label.toUpperCase();

  String get description {
    switch (this) {
      case UserRole.tenant:
        return 'Find homes, schedule viewings, apply & pay rent.';
      case UserRole.agent:
        return 'List properties, manage leads, schedule viewings.';
      case UserRole.landlord:
        return 'Manage properties, tenants, rent & maintenance.';
    }
  }

  String get welcomeLine {
    switch (this) {
      case UserRole.tenant:
        return "You're logged in as Tenant.";
      case UserRole.agent:
        return "You're logged in as Agent.";
      case UserRole.landlord:
        return "You're logged in as Landlord.";
    }
  }

  String get primaryCta {
    switch (this) {
      case UserRole.tenant:
        return 'Explore homes';
      case UserRole.agent:
      case UserRole.landlord:
        return 'Go to dashboard';
    }
  }

  String toRoute() {
    switch (this) {
      case UserRole.tenant:
        return '/tenant';
      case UserRole.agent:
        return '/agent';
      case UserRole.landlord:
        return '/landlord';
    }
  }

  static UserRole? fromString(String? raw) {
    final v = (raw ?? '').trim().toLowerCase();
    if (v == 'tenant') { return UserRole.tenant; }    if (v == 'agent') { return UserRole.agent; }    if (v == 'landlord') { return UserRole.landlord; }    return null;
  }
}
