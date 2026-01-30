import "package:flutter/foundation.dart";

enum ViewingStatus { requested, confirmed, completed, cancelled }

extension ViewingStatusX on ViewingStatus {
  String get label {
    switch (this) {
      case ViewingStatus.requested:
        return "Requested";
      case ViewingStatus.confirmed:
        return "Confirmed";
      case ViewingStatus.completed:
        return "Completed";
      case ViewingStatus.cancelled:
        return "Cancelled";
    }
  }
}

@immutable
class ViewingModel {
  const ViewingModel({
    required this.id,
    required this.listingTitle,
    required this.location,
    required this.agentName,
    required this.dateTime,
    required this.status,
    this.priceText,
  });

  final String id;
  final String listingTitle;
  final String location;
  final String agentName;
  final DateTime dateTime;
  final ViewingStatus status;
  final String? priceText;
}
