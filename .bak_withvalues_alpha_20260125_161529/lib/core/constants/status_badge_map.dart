enum StatusDomain {
  verified,
  listing,
  maintenance,
  viewing,
  property,
  payment,
  payout,
  purchasePayment,
  purchaseStatus,
}

/// Tone -> final colors are resolved inside StatusBadge widget from Theme
enum BadgeTone { neutral, info, success, warning, danger }

class BadgeSpec {
  const BadgeSpec({required this.label, required this.tone});

  final String label;
  final BadgeTone tone;
}

class StatusBadgeMap {
  static BadgeSpec forStatus(StatusDomain domain, String raw) {
    final s = raw.trim().toLowerCase();

    switch (domain) {
      case StatusDomain.verified:
        return _verified[s] ??
            const BadgeSpec(label: 'Unknown', tone: BadgeTone.neutral);
      case StatusDomain.listing:
        return _listing[s] ??
            const BadgeSpec(label: 'Unknown', tone: BadgeTone.neutral);
      case StatusDomain.maintenance:
        return _maintenance[s] ??
            const BadgeSpec(label: 'Unknown', tone: BadgeTone.neutral);
      case StatusDomain.viewing:
        return _viewing[s] ??
            const BadgeSpec(label: 'Unknown', tone: BadgeTone.neutral);
      case StatusDomain.property:
        return _property[s] ??
            const BadgeSpec(label: 'Unknown', tone: BadgeTone.neutral);
      case StatusDomain.payment:
        return _payment[s] ??
            const BadgeSpec(label: 'Unknown', tone: BadgeTone.neutral);
      case StatusDomain.payout:
        return _payout[s] ??
            const BadgeSpec(label: 'Unknown', tone: BadgeTone.neutral);
      case StatusDomain.purchasePayment:
        return _purchasePayment[s] ??
            const BadgeSpec(label: 'Unknown', tone: BadgeTone.neutral);
      case StatusDomain.purchaseStatus:
        return _purchaseStatus(s);
    }
  }

  static const Map<String, BadgeSpec> _verified = {
    'pending': BadgeSpec(label: 'Pending', tone: BadgeTone.warning),
    'verified': BadgeSpec(label: 'Verified', tone: BadgeTone.success),
    'rejected': BadgeSpec(label: 'Rejected', tone: BadgeTone.danger),
    'suspended': BadgeSpec(label: 'Suspended', tone: BadgeTone.danger),
  };

  static const Map<String, BadgeSpec> _listing = {
    'draft': BadgeSpec(label: 'Draft', tone: BadgeTone.neutral),
    'pending_owner_approval': BadgeSpec(
      label: 'Pending Approval',
      tone: BadgeTone.warning,
    ),
    'active': BadgeSpec(label: 'Active', tone: BadgeTone.success),
    'rejected': BadgeSpec(label: 'Rejected', tone: BadgeTone.danger),
    'paused': BadgeSpec(label: 'Paused', tone: BadgeTone.warning),
    'expired': BadgeSpec(label: 'Expired', tone: BadgeTone.warning),
    'cancelled': BadgeSpec(label: 'Cancelled', tone: BadgeTone.neutral),
  };

  static const Map<String, BadgeSpec> _maintenance = {
    'open': BadgeSpec(label: 'Open', tone: BadgeTone.info),
    'in_progress': BadgeSpec(label: 'In Progress', tone: BadgeTone.warning),
    'on_hold': BadgeSpec(label: 'On Hold', tone: BadgeTone.warning),
    'resolved': BadgeSpec(label: 'Resolved', tone: BadgeTone.success),
    'cancelled': BadgeSpec(label: 'Cancelled', tone: BadgeTone.neutral),
  };

  static const Map<String, BadgeSpec> _viewing = {
    'pending': BadgeSpec(label: 'Pending', tone: BadgeTone.warning),
    'approved': BadgeSpec(label: 'Approved', tone: BadgeTone.success),
    'rejected': BadgeSpec(label: 'Rejected', tone: BadgeTone.danger),
    'completed': BadgeSpec(label: 'Completed', tone: BadgeTone.success),
    'cancelled': BadgeSpec(label: 'Cancelled', tone: BadgeTone.neutral),
  };

  static const Map<String, BadgeSpec> _property = {
    'available': BadgeSpec(label: 'Available', tone: BadgeTone.success),
    'occupied': BadgeSpec(label: 'Occupied', tone: BadgeTone.danger),
    'pending': BadgeSpec(label: 'Pending', tone: BadgeTone.warning),
    'maintenance': BadgeSpec(label: 'Maintenance', tone: BadgeTone.warning),
    'unavailable': BadgeSpec(label: 'Unavailable', tone: BadgeTone.neutral),
  };

  static const Map<String, BadgeSpec> _payment = {
    'pending': BadgeSpec(label: 'Pending', tone: BadgeTone.warning),
    'successful': BadgeSpec(label: 'Successful', tone: BadgeTone.success),
    'failed': BadgeSpec(label: 'Failed', tone: BadgeTone.danger),
  };

  static const Map<String, BadgeSpec> _payout = {
    'pending': BadgeSpec(label: 'Pending', tone: BadgeTone.warning),
    'processing': BadgeSpec(label: 'Processing', tone: BadgeTone.info),
    'paid': BadgeSpec(label: 'Paid', tone: BadgeTone.success),
    'failed': BadgeSpec(label: 'Failed', tone: BadgeTone.danger),
    'reversed': BadgeSpec(label: 'Reversed', tone: BadgeTone.danger),
    'cancelled': BadgeSpec(label: 'Cancelled', tone: BadgeTone.neutral),
  };

  static const Map<String, BadgeSpec> _purchasePayment = {
    'unpaid': BadgeSpec(label: 'Unpaid', tone: BadgeTone.warning),
    'deposit_paid': BadgeSpec(label: 'Deposit Paid', tone: BadgeTone.info),
    'partially_paid': BadgeSpec(label: 'Partially Paid', tone: BadgeTone.info),
    'paid': BadgeSpec(label: 'Paid', tone: BadgeTone.success),
    'refunded': BadgeSpec(label: 'Refunded', tone: BadgeTone.neutral),
  };

  static BadgeSpec _purchaseStatus(String s) {
    // Timeline steps: mostly "info", terminal states special
    if (s == 'cancelled')
      return const BadgeSpec(label: 'Cancelled', tone: BadgeTone.neutral);
    if (s == 'refunded')
      return const BadgeSpec(label: 'Refunded', tone: BadgeTone.neutral);
    if (s == 'closed')
      return const BadgeSpec(label: 'Closed', tone: BadgeTone.success);

    // default: prettify label
    final label = s.replaceAll('_', ' ');
    final pretty = label.isEmpty
        ? 'Unknown'
        : label[0].toUpperCase() + label.substring(1);
    return BadgeSpec(label: pretty, tone: BadgeTone.info);
  }
}
