enum UserRole { tenant, landlord, agent, admin }

extension UserRoleX on UserRole {
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

  /// Backward-compat for existing UI code that uses `role.value`
  String get value => name;
}

/// Verified status for KYC/doc/property
enum VerifiedStatus { pending, verified, rejected, suspended }

/// Listing status
enum ListingStatus { draft, pendingOwnerApproval, active, rejected, paused, expired, cancelled }

/// Maintenance status
enum MaintenanceStatus { open, inProgress, onHold, resolved, cancelled }

/// Viewing status
enum ViewingStatus { pending, approved, rejected, completed, cancelled }

/// Property availability
enum PropertyStatus { available, occupied, pending, maintenance, unavailable }

/// Payments
enum PaymentStatus { pending, successful, failed }

/// Payout status
enum PayoutStatus { pending, processing, paid, failed, reversed, cancelled }

/// Purchase payment progress
enum PurchasePaymentStatus { unpaid, depositPaid, partiallyPaid, paid, refunded }

/// Purchase status (timeline)
enum PurchaseStatus {
  initiated,
  offerMade,
  offerAccepted,
  underContract,
  escrowOpened,
  depositPaid,
  inspection,
  financing,
  appraisal,
  titleSearch,
  closingScheduled,
  closed,
  cancelled,
  refunded,
}
