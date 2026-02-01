import 'package:flutter/material.dart';

import '../core/config/env.dart';
import '../features/auth/data/auth_di.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.load();
  AuthDI.init(); // ✅ important: must happen AFTER Env.load()

  runApp(const HomeSteadApp());
}
