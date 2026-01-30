import 'package:flutter/material.dart';
import '../core/config/env.dart';
import 'app.dart';

Future<void> bootstrap() async {
  await Env.load();
  runApp(const HomeSteadApp());
}
