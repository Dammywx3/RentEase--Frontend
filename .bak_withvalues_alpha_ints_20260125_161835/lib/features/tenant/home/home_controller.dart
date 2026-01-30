import 'package:flutter/foundation.dart';
import '../../../shared/models/listing_model.dart';

class TenantHomeController extends ChangeNotifier {
  bool loading = false;
  String? error;

  final List<ListingModel> listings = [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      listings
        ..clear()
        ..addAll([
          const ListingModel(
            id: 'l1',
            title: 'Modern 2 Bedroom Apartment',
            price: 1200000,
            currency: 'NGN',
            location: 'Lekki, Lagos',
            status: 'active',
            beds: 2,
            baths: 2,
            type: 'Apartment',
            mediaUrls: [],
            propertyStatus: 'available',
          ),
          const ListingModel(
            id: 'l2',
            title: 'Cozy Studio (Close to Main Road)',
            price: 450000,
            currency: 'NGN',
            location: 'Yaba, Lagos',
            status: 'active',
            beds: 1,
            baths: 1,
            type: 'Studio',
            mediaUrls: [],
            propertyStatus: 'maintenance',
          ),
          const ListingModel(
            id: 'l3',
            title: 'Family Duplex (4 Beds) - Promo',
            price: 3500000,
            currency: 'NGN',
            location: 'Ikeja, Lagos',
            status: 'paused',
            beds: 4,
            baths: 4,
            type: 'Duplex',
            mediaUrls: [],
            propertyStatus: 'available',
          ),
        ]);

      loading = false;
      notifyListeners();
    } catch (_) {
      loading = false;
      error = 'Failed to load listings.';
      notifyListeners();
    }
  }
}
