class ViewingModel {
  const ViewingModel({
    required this.id,
    required this.listingTitle,
    required this.location,
    required this.agentName,
    required this.priceNgnPerMonth,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    this.imageUrl,
  });

  final String id;
  final String listingTitle;
  final String location;
  final String agentName;
  final int priceNgnPerMonth;
  final String dateLabel; // e.g. "Sat, May 4"
  final String timeLabel; // e.g. "2:00 PM"
  final ViewingStatus status;
  final String? imageUrl;
}

enum ViewingStatus { requested, confirmed, completed, cancelled }

extension ViewingStatusX on ViewingStatus {
  String get label {
    switch (this) {
      case ViewingStatus.requested:
        return 'Requested';
      case ViewingStatus.confirmed:
        return 'Confirmed';
      case ViewingStatus.completed:
        return 'Completed';
      case ViewingStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isUpcoming =>
      this == ViewingStatus.requested || this == ViewingStatus.confirmed;
}
