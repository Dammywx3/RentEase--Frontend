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
    required this.dateTime,
    required this.status,

    // people
    required this.agentName,
    this.landlordName,

    // pricing / media
    this.priceText,
    this.thumbnailUrl,

    // ids needed for apply / deep links
    this.listingId,
    this.propertyId,
  });

  final String id;
  final String listingTitle;
  final String location;
  final DateTime dateTime;
  final ViewingStatus status;

  final String agentName;
  final String? landlordName;

  final String? priceText;
  final String? thumbnailUrl;

  final String? listingId;
  final String? propertyId;

  ViewingModel copyWith({
    String? listingTitle,
    String? location,
    DateTime? dateTime,
    ViewingStatus? status,
    String? agentName,
    String? landlordName,
    String? priceText,
    String? thumbnailUrl,
    String? listingId,
    String? propertyId,
  }) {
    return ViewingModel(
      id: id,
      listingTitle: listingTitle ?? this.listingTitle,
      location: location ?? this.location,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      agentName: agentName ?? this.agentName,
      landlordName: landlordName ?? this.landlordName,
      priceText: priceText ?? this.priceText,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      listingId: listingId ?? this.listingId,
      propertyId: propertyId ?? this.propertyId,
    );
  }

  /// ✅ Robust parser: snake_case / camelCase / nested listing/property/agent/landlord
  factory ViewingModel.fromApi(Map<String, dynamic> m) {
    String pickStr(List<String> keys, {String fallback = ""}) {
      for (final k in keys) {
        final v = m[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
        if (v != null) return v.toString();
      }
      return fallback;
    }

    Map<String, dynamic>? pickMap(String key) {
      final v = m[key];
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return Map<String, dynamic>.from(v);
      return null;
    }

    String pickNestedStr(Map<String, dynamic>? obj, List<String> keys) {
      if (obj == null) return "";
      for (final k in keys) {
        final v = obj[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
        if (v != null) return v.toString();
      }
      return "";
    }

    final listing = pickMap("listing");
    final property = pickMap("property");
    final agent = pickMap("agent");
    final landlord = pickMap("landlord") ?? pickMap("owner");

    // id
    final id = pickStr(["id", "viewing_id", "referenceId"], fallback: "");

    // scheduledAt
    final scheduledRaw = pickStr(
      ["scheduled_at", "scheduledAt", "dateTime", "scheduled_time"],
      fallback: "",
    );
    DateTime scheduledAt;
    try {
      scheduledAt = scheduledRaw.isNotEmpty ? DateTime.parse(scheduledRaw) : DateTime.now();
    } catch (_) {
      scheduledAt = DateTime.now();
    }

    // status
    final statusRaw = pickStr(["status"], fallback: "pending");
    final status = ViewingStatusX.fromApi(statusRaw);

    // title/location
    final listingTitleNested = pickNestedStr(listing, ["title", "name"]);
    final locationNested =
        pickNestedStr(listing, ["location", "address", "city", "state"]);

    final flatTitle =
        pickStr(["listing_title", "listingTitle", "title"], fallback: "Viewing");
    final flatLoc = pickStr(
      ["location", "listing_location", "listingLocation", "address"],
      fallback: "",
    );

    // agent name
    final agentNameNested =
        pickNestedStr(agent, ["full_name", "fullName", "name"]);
    final agentNameFlat =
        pickStr(["agent_name", "agentName", "agent"], fallback: "");

    // landlord name (optional)
    final landlordNameNested =
        pickNestedStr(landlord, ["full_name", "fullName", "name"]);
    final landlordNameFlat =
        pickStr(["landlord_name", "landlordName", "owner_name"], fallback: "");

    // ids
    final listingId = pickNestedStr(listing, ["id"]).isNotEmpty
        ? pickNestedStr(listing, ["id"])
        : pickStr(["listing_id", "listingId"], fallback: "");
    final propertyId = pickNestedStr(property, ["id"]).isNotEmpty
        ? pickNestedStr(property, ["id"])
        : pickStr(["property_id", "propertyId"], fallback: "");

    // image
    final thumbNested = pickNestedStr(
      listing,
      ["thumbnail_url", "thumbnailUrl", "cover_url", "coverUrl", "image_url", "imageUrl"],
    );
    final thumbFlat = pickStr(
      ["thumbnail_url", "thumbnailUrl", "cover_url", "coverUrl", "image_url", "imageUrl"],
      fallback: "",
    );

    // price / amount (support many possible fields)
    final priceTextNested = pickNestedStr(
      listing,
      ["price_text", "priceText", "priceLine", "rent_text", "rentText"],
    );
    final priceTextFlat = pickStr(
      ["price_text", "priceText", "priceLine", "rent_text", "rentText"],
      fallback: "",
    );

    // numeric rent -> make text if no priceText was provided
    final rentNumeric = pickNestedStr(
      listing,
      ["rent_per_month", "rentPerMonth", "monthly_rent", "monthlyRent", "amount"],
    );
    String? computedPrice;
    if (priceTextNested.isEmpty && priceTextFlat.isEmpty && rentNumeric.trim().isNotEmpty) {
      final digits = rentNumeric.replaceAll(RegExp(r"[^0-9]"), "");
      if (digits.isNotEmpty) computedPrice = "₦$digits / month";
    }

    final priceFinal = (priceTextNested.isNotEmpty
            ? priceTextNested
            : (priceTextFlat.isNotEmpty ? priceTextFlat : (computedPrice ?? "")))
        .trim();

    final agentFinal = (agentNameNested.isNotEmpty ? agentNameNested : agentNameFlat).trim();
    final landlordFinal =
        (landlordNameNested.isNotEmpty ? landlordNameNested : landlordNameFlat).trim();

    return ViewingModel(
      id: id.isEmpty ? "unknown" : id,
      listingTitle: listingTitleNested.isNotEmpty ? listingTitleNested : flatTitle,
      location: locationNested.isNotEmpty ? locationNested : flatLoc,
      dateTime: scheduledAt,
      status: status,
      agentName: agentFinal.isNotEmpty ? agentFinal : "Agent",
      landlordName: landlordFinal.isEmpty ? null : landlordFinal,
      priceText: priceFinal.isEmpty ? null : priceFinal,
      thumbnailUrl: (thumbNested.isNotEmpty ? thumbNested : thumbFlat).trim().isEmpty
          ? null
          : (thumbNested.isNotEmpty ? thumbNested : thumbFlat).trim(),
      listingId: listingId.isEmpty ? null : listingId,
      propertyId: propertyId.isEmpty ? null : propertyId,
    );
  }
}