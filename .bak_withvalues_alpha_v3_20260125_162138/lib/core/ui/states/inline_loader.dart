import 'package:flutter/material.dart';

class InlineLoader extends StatelessWidget {
  const InlineLoader({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(strokeWidth: 2.4),
    );
  }
}
