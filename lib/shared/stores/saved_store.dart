import 'dart:collection';
import 'package:flutter/foundation.dart';

import '../models/listing_model.dart';

/// In-memory saved listings store (tenant).
/// - Single source of truth across Explore/Search/Detail/Saved.
/// - For persistence across app restart, you can later add SharedPreferences/Hive.
class SavedStore extends ChangeNotifier {
  SavedStore._();
  static final SavedStore I = SavedStore._();

  final Map<String, ListingModel> _savedByKey = <String, ListingModel>{};

  String _keyFor(ListingModel l) {
    final id = (l.id ?? '').trim();
    if (id.isNotEmpty) return id;

    // fallback key if id is missing (not ideal, but prevents crashes)
    final t = l.title.trim();
    final loc = l.location.trim();
    final p = (l.price ?? 0).toString();
    return '$t|$loc|$p';
  }

  bool isSaved(ListingModel l) => _savedByKey.containsKey(_keyFor(l));

  bool isSavedKey(String key) => _savedByKey.containsKey(key);

  UnmodifiableListView<ListingModel> get savedListings =>
      UnmodifiableListView(_savedByKey.values.toList().reversed);

  int get count => _savedByKey.length;

  void toggle(ListingModel l) {
    final k = _keyFor(l);
    if (_savedByKey.containsKey(k)) {
      _savedByKey.remove(k);
    } else {
      _savedByKey[k] = l;
    }
    notifyListeners();
  }

  void remove(ListingModel l) {
    final k = _keyFor(l);
    if (_savedByKey.remove(k) != null) notifyListeners();
  }

  void clear() {
    if (_savedByKey.isEmpty) return;
    _savedByKey.clear();
    notifyListeners();
  }
}