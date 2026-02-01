// lib/shared/models/viewing_model.dart
import "package:flutter/material.dart";

/// UI statuses (mapped to/from backend DB enum)
enum ViewingStatus { requested, confirmed, rejected, completed, cancelled }

extension ViewingStatusX on ViewingStatus {
  String get label {
    switch (this) {
      case ViewingStatus.requested:
        return "Requested";
      case ViewingStatus.confirmed:
        return "Confirmed";
      case ViewingStatus.rejected:
        return "Rejected";
      case ViewingStatus.completed:
        return "Completed";
      case ViewingStatus.cancelled:
        return "Cancelled";
    }
  }

  /// UI -> backend enum
  String toApi() {
    switch (this) {
      case ViewingStatus.requested:
        return "pending";
      case ViewingStatus.confirmed:
        return "approved";
      case ViewingStatus.rejected:
        return "rejected";
      case ViewingStatus.completed:
        return "completed";
      case ViewingStatus.cancelled:
        return "cancelled";
    }
  }

  /// backend enum -> UI
  static ViewingStatus fromApi(String s) {
    switch (s) {
      case "approved":
        return ViewingStatus.confirmed;
      case "rejected":
        return ViewingStatus.rejected;
      case "completed":
        return ViewingStatus.completed;
      case "cancelled":
        return ViewingStatus.cancelled;
      case "pending":
      default:
        return ViewingStatus.requested;
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

    /// backend identifiers (recommended)
    this.listingId,
    this.propertyId,
  });

  final String id;
  final String listingTitle;
  final String location;
  final String agentName;
  final DateTime dateTime;
  final ViewingStatus status;

  final String? priceText;
  final String? thumbnailUrl;

  final String? listingId;
  final String? propertyId;

  ViewingModel copyWith({
    String? listingTitle,
    String? location,
    String? agentName,
    DateTime? dateTime,
    ViewingStatus? status,
    String? priceText,
    String? thumbnailUrl,
    String? listingId,
    String? propertyId,
  }) {
    return ViewingModel(
      id: id,
      listingTitle: listingTitle ?? this.listingTitle,
      location: location ?? this.location,
      agentName: agentName ?? this.agentName,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      priceText: priceText ?? this.priceText,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      listingId: listingId ?? this.listingId,
      propertyId: propertyId ?? this.propertyId,
    );
  }
}