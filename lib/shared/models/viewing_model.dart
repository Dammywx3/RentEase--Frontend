import "package:flutter/material.dart";

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

  Color tone(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (this) {
      case ViewingStatus.requested:
        return scheme.tertiary;
      case ViewingStatus.confirmed:
        return scheme.primary;
      case ViewingStatus.completed:
        return scheme.secondary;
      case ViewingStatus.cancelled:
        return scheme.outline;
    }
  }
}

class ViewingModel {
  const ViewingModel({
    required this.id,
    required this.listingTitle,
    required this.location,
    required this.agentName,
    required this.dateTime,
    required this.status,
    this.priceText,
    this.thumbnailUrl,
  });

  final String id;
  final String listingTitle;
  final String location;
  final String agentName;
  final DateTime dateTime;
  final ViewingStatus status;

  final String? priceText;
  final String? thumbnailUrl;
}
