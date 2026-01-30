import 'package:flutter/material.dart';

import '../core/config/env.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();

  runApp(const HomeSteadApp());
}
