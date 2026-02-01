// lib/core/storage/app_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const _kOnboardingDone = 'onboarding_done_v1';

  static Future<bool> isOnboardingDone() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kOnboardingDone) ?? false;
  }

  static Future<void> setOnboardingDone(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kOnboardingDone, v);
  }
}