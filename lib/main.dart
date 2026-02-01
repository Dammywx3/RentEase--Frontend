import 'package:flutter/material.dart';

import 'app/bootstrap.dart';
import 'core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Loads .env so Env.organizationId and Env.baseUrl work
  await Env.load();

  // ✅ Continue with your existing app startup
  await bootstrap();
}