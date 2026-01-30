import 'package:flutter/material.dart';

class AppShadows {
  static List<BoxShadow> softLight = [
    BoxShadow(
      color: Colors.black.withAlpha(10),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> softDark = [
    BoxShadow(
      color: Colors.black.withAlpha(50),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];
}
