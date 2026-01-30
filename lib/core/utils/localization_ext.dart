import 'package:flutter/material.dart';

extension MaterialLocalizationsX on MaterialLocalizations {
  /// Flutter does not provide formatShortWeekday. We supply a stable Mon..Sun mapping.
  String shortWeekday(DateTime d) {
    const w = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final idx = (d.weekday - 1) % 7;
    return w[idx];
  }
}
