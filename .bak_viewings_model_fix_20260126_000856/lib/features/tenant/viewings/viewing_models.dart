enum ViewingStatus { requested, confirmed, completed, cancelled }

class ViewingModel {
  const ViewingModel({
    required this.id,
    required this.title,
    required this.whenText,
    required this.location,
    required this.agentName,
    required this.status,
    required this.priceText,
    this.cancelReason,
  });

  final String id;
  final String title; // short address/title
  final String whenText; // "Sat, May 4 • 2:00 PM" (or "Completed • ...")
  final String location; // "Lekki, Lagos"
  final String agentName;
  final ViewingStatus status;
  final String priceText; // "₦50,000/month"
  final String? cancelReason;
}
