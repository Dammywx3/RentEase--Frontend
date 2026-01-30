import 'package:flutter/material.dart';

import '../../../core/ui/scaffold/app_scaffold.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      child: SafeArea(child: Center(child: Text('Messages (placeholder)'))),
    );
  }
}
